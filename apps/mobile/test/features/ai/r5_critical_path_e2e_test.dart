import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/ai/application/ai_providers.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_proposal_executor.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/ai_proposal.dart';
import 'package:ai_trainer_mobile/features/ai/domain/proposal_executor.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_results.dart';
import 'package:ai_trainer_mobile/features/availability/application/availability_providers.dart';
import 'package:ai_trainer_mobile/features/checkin/application/checkin_providers.dart';
import 'package:ai_trainer_mobile/features/checkin/domain/daily_check_in.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/notifications/application/notification_providers.dart';
import 'package:ai_trainer_mobile/features/notifications/domain/reminder_plan.dart';
import 'package:ai_trainer_mobile/features/plan/application/plan_providers.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/recommendation/application/recommendation_providers.dart';
import 'package:ai_trainer_mobile/features/recommendation/domain/today_recommendation.dart';
import 'package:ai_trainer_mobile/features/sports/application/sports_profile_providers.dart';
import 'package:ai_trainer_mobile/features/sports/domain/user_sport.dart';
import 'package:ai_trainer_mobile/features/summary/application/summary_providers.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/fake_workout_repositories.dart';
import '../../support/workout_test_scope.dart';

/// R5-08 – kritický end-to-end důkaz hlavní hodnoty R5 (VSP R5 §9.8/§13)
/// a jádro beta baseline scénáře (release scope §10, kroky 8–9).
///
/// Jeden deterministický scénář nad skutečnou SQLite (reálné repository,
/// safety engine, doporučení, adjustment pipeline, executor; fake jen
/// síť/AI API/storage/clock):
/// 1. účet + profil + ruční týden,
/// 2. denní check-in (únava) → deterministická safety → doporučení dne,
/// 3. žádost o AI úpravu týdne → validovaný PROPOSED s adjustment trojicí,
/// 4. odmítnutí je viditelný zachovaný stav,
/// 5. potvrzení = atomické provedení C21 cestami (MOVE + CANCEL),
/// 6. týdenní souhrn a reminder relevance,
/// 7. push existujícím mechanismem (check-in, plán, změny) + replay no-op.
/// Negativní větve v druhém testu: safety veto a nedostupnost AI.
class _ScriptedAdjustmentApi implements AiApiClient {
  _ScriptedAdjustmentApi(this.operations);

  final List<Map<String, Object?>> operations;
  int calls = 0;

  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required Map<String, Object?> context,
    String requestType = 'PLAN_PROPOSAL',
  }) async {
    calls++;
    expect(requestType, 'ADJUSTMENT_PROPOSAL');
    return PlanProposalResponse(
      proposal: {
        'summary': 'Lehčí týden kvůli únavě.',
        'operations': operations,
      },
      promptVersion: 'adjustment-proposal-v1',
      schemaVersion: 'adjustment-proposal-schema-v1',
      modelId: 'fake-model',
    );
  }
}

class _UnavailableAiApi implements AiApiClient {
  int calls = 0;

  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required Map<String, Object?> context,
    String requestType = 'PLAN_PROPOSAL',
  }) async {
    calls++;
    throw const AiApiFailure(AiApiFailureKind.unavailable);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Poledne UTC: lokální datum stejné pro všechny běžné časové zóny.
  final fixedNow = DateTime.utc(2026, 8, 14, 12);

  ProviderContainer buildContainer(AiApiClient aiApi, FakeSyncApiClient sync) {
    final database = createTestDatabase();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => fixedNow),
        secureSessionStorageProvider.overrideWithValue(
          InMemorySecureSessionStorage(),
        ),
        authApiClientProvider.overrideWithValue(FakeAuthApiClient()),
        installationIdentityProvider.overrideWithValue(
          FakeInstallationIdentity('installation-r5-e2e'),
        ),
        syncApiClientProvider.overrideWithValue(sync),
        aiApiClientProvider.overrideWithValue(aiApi),
        // Bez demo seedu — týden staví scénář ručně (R3 vzor).
        r1SeedRepositoryProvider.overrideWithValue(
          FakeSeedRepository([SeedResult.applied]),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    return container;
  }

  Future<void> registerAndSeedWeek(ProviderContainer container) async {
    await container.read(authSessionManagerProvider.future);
    expect(
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'r5@example.com', password: 'password-123'),
      isA<AuthFlowSuccess>(),
    );
    await container
        .read(userSportRepositoryProvider)
        .saveSport(
          const UserSportInput(
            sportCode: 'CLIMBING',
            role: 'PRIMARY',
            priority: 'HIGH',
            experienceLevel: 'INTERMEDIATE',
          ),
          newId: 'us1',
          now: fixedNow,
        );
    await container
        .read(availabilityProfileRepositoryProvider)
        .addConstraint(title: 'Bolavé rameno', newId: 'c1', now: fixedNow);
    final plans = container.read(trainingPlanRepositoryProvider);
    await plans.createPlan(title: 'Můj týden', newId: 'p1', now: fixedNow);
    var seq = 0;
    for (final (title, offset) in [('Full Body A', 0), ('Intervals', 1)]) {
      expect(
        await plans.addWorkout(
          'p1',
          PlannedWorkoutInput(
            title: title,
            workoutType: 'STRENGTH',
            scheduledLocalDate: scheduledDateForOffset(fixedNow, offset),
          ),
          newId: () => 'w-${seq++}',
          now: fixedNow,
        ),
        isA<PlanWriteSaved>(),
      );
    }
  }

  test('kritická R5 cesta: check-in → safety → doporučení → AI úprava → '
      'odmítnutí/potvrzení → provedení → souhrn → push', () async {
    final aiApi = _ScriptedAdjustmentApi([
      {
        'operation': 'MOVE',
        'reason': 'Den regenerace navíc.',
        'target': {'dayOffset': 0, 'title': 'Full Body A'},
        'toDayOffset': 2,
      },
      {
        'operation': 'CANCEL',
        'reason': 'Vysoká hlášená únava.',
        'target': {'dayOffset': 1, 'title': 'Intervals'},
      },
    ]);
    final syncApi = FakeSyncApiClient();
    final container = buildContainer(aiApi, syncApi);
    await registerAndSeedWeek(container);

    // ---- 2. Check-in → deterministická safety → doporučení dne. ----
    await container
        .read(dailyCheckInRepositoryProvider)
        .saveForDate(
          scheduledDateForOffset(fixedNow, 0),
          const DailyCheckInInput(energyLevel: 3, fatigueLevel: 4),
          newId: 'ci1',
          now: fixedNow,
        );
    final recommendation = await container.read(
      todayRecommendationProvider.future,
    );
    expect(recommendation.state, TodayRecommendationState.considerLighterDay);
    expect(
      recommendation.reasons.map((f) => f.code),
      containsAll(['HIGH_FATIGUE', 'ACTIVE_CONSTRAINT']),
    );

    // ---- 3. Žádost o AI úpravu → PROPOSED s adjustment trojicí verzí. ----
    final controller = container.read(aiScreenControllerProvider.notifier);
    await controller.requestAdjustment();
    expect(container.read(aiScreenControllerProvider), isA<AiDone>());
    await controller.requestAdjustment();
    final proposals = await container
        .read(aiProposalRepositoryProvider)
        .proposalsForCurrentOwner();
    expect(proposals, hasLength(2));
    expect(proposals.first.schemaVersion, 'adjustment-proposal-schema-v1');

    // ---- 4. Odmítnutí je viditelný zachovaný stav (APL-006). ----
    final rejectedId = proposals.first.id;
    final confirmedId = proposals.last.id;
    await controller.decide(rejectedId, ProposalDecision.reject);
    expect(
      (await container
              .read(aiProposalRepositoryProvider)
              .proposalById(rejectedId))!
          .status,
      'REJECTED',
    );

    // ---- 5. Potvrzení = atomické provedení C21 cestami (C38). ----
    await controller.decide(confirmedId, ProposalDecision.confirm);
    expect(container.read(aiScreenControllerProvider), isA<AiDone>());
    expect(
      (await container
              .read(aiProposalRepositoryProvider)
              .proposalById(confirmedId))!
          .status,
      'EXECUTED',
    );
    final movedDay = await container
        .read(workoutInstanceRepositoryProvider)
        .workoutsForLocalDate(scheduledDateForOffset(fixedNow, 2));
    expect(movedDay.map((w) => w.title), contains('Full Body A'));

    // ---- 6. Týdenní souhrn + reminder relevance (C39/C40). ----
    final summary = await container.read(weeklySummaryProvider.future);
    expect(summary.checkIns.checkInCount, 1);
    expect(summary.checkIns.averageFatigue, 4.0);
    await container
        .read(reminderSettingsControllerProvider.notifier)
        .setCheckInEnabled(true);
    final reminders = await container.read(todayReminderPlanProvider.future);
    // Dnešní check-in existuje → check-in připomínka se neplánuje (NTF-004).
    expect(reminders.where((r) => r.type == ReminderType.checkIn), isEmpty);

    // ---- 7. Push existujícím mechanismem + replay no-op. ----
    final push = await container.read(syncEngineProvider).pushPending();
    expect(push, isA<SyncRunCompleted>());
    expect((push as SyncRunCompleted).conflicts + push.rejected, 0);
    final types = syncApi.pushedBatches.single
        .map((op) => op.entityType)
        .toSet();
    expect(
      types,
      containsAll([
        'DAILY_CHECK_IN',
        'TRAINING_PLAN',
        'WORKOUT_INSTANCE',
        'CALENDAR_CHANGE',
        'USER_SPORT',
        'CONSTRAINT_ITEM',
      ]),
    );
    expect(types.contains('AI_PROPOSAL'), isFalse);
    final replay = await container.read(syncEngineProvider).pushPending();
    expect((replay as SyncRunCompleted).synced, 0);
  });

  test('negativní větve: safety veto blokuje ADD při STOP; nedostupná AI je '
      'typovaná bez retry (AJE-005, AIS-001/002)', () async {
    // Safety veto: STOP check-in + adjustment s ADD.
    final vetoApi = _ScriptedAdjustmentApi([
      {
        'operation': 'ADD',
        'reason': 'Přidat trénink.',
        'workout': {
          'title': 'Extra Session',
          'workoutType': 'STRENGTH',
          'dayOffset': 3,
        },
      },
    ]);
    final container = buildContainer(vetoApi, FakeSyncApiClient());
    await registerAndSeedWeek(container);
    await container
        .read(dailyCheckInRepositoryProvider)
        .saveForDate(
          scheduledDateForOffset(fixedNow, 0),
          const DailyCheckInInput(
            energyLevel: 3,
            fatigueLevel: 3,
            painLevel: 5,
            painAreaCode: 'KNEE',
          ),
          newId: 'ci1',
          now: fixedNow,
        );
    expect(
      (await container.read(todayRecommendationProvider.future)).state,
      TodayRecommendationState.considerRest,
    );

    final controller = container.read(aiScreenControllerProvider.notifier);
    await controller.requestAdjustment();
    final proposal =
        (await container
                .read(aiProposalRepositoryProvider)
                .proposalsForCurrentOwner())
            .single;
    await controller.decide(proposal.id, ProposalDecision.confirm);
    final state = container.read(aiScreenControllerProvider);
    expect(state, isA<AiExecutionFailure>());
    expect(
      (state as AiExecutionFailure).result,
      isA<ExecutionSafetyConflict>(),
    );
    final extra = await container
        .read(appDatabaseProvider)
        .customSelect(
          "SELECT COUNT(*) AS c FROM local_workout_instances "
          "WHERE title = 'Extra Session'",
        )
        .getSingle();
    expect(extra.data['c'], 0);

    // Nedostupná AI: typovaný stav, jediné volání (žádný auto-retry).
    final unavailable = _UnavailableAiApi();
    final offline = buildContainer(unavailable, FakeSyncApiClient());
    await registerAndSeedWeek(offline);
    final offlineController = offline.read(aiScreenControllerProvider.notifier);
    await offlineController.requestAdjustment();
    expect(offline.read(aiScreenControllerProvider), isA<AiRequestFailure>());
    expect(unavailable.calls, 1);
    // Manuální cesty nedegradované: doporučení dne dál funguje offline.
    expect(
      (await offline.read(todayRecommendationProvider.future)).state,
      TodayRecommendationState.checkInMissing,
    );
  });
}
