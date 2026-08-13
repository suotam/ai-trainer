import 'dart:convert';

import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/ai/application/ai_providers.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_proposal_executor.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/ai_proposal.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_results.dart';
import 'package:ai_trainer_mobile/features/availability/application/availability_providers.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/goals/application/goals_providers.dart';
import 'package:ai_trainer_mobile/features/goals/domain/goal.dart';
import 'package:ai_trainer_mobile/features/plan/application/plan_providers.dart';
import 'package:ai_trainer_mobile/features/sports/application/sports_profile_providers.dart';
import 'package:ai_trainer_mobile/features/sports/domain/user_sport.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_completion_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/complete_workout_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R4-08 – kritický end-to-end důkaz hlavní hodnoty R4 (VSP R4 §9.8/§13).
///
/// Jeden deterministický scénář nad skutečnou SQLite (reálné repository,
/// context builder, validace, executor; fake jen síť/AI API/storage/clock):
/// 1. účet + strukturovaný profil,
/// 2. minimalizovaný AIContext bez ID/poznámek (C27),
/// 3. žádost → validovaný návrh PROPOSED s trojicí verzí,
/// 4. odmítnutí je viditelný zachovaný stav (APL-006),
/// 5. potvrzení = provedení: atomicky přes C20 s provenance (C30),
/// 6. AI workout v Today → celý R1 flow (start → zápis → completion),
/// 7. push: AI plán s origin, návrhy se nesynchronizují (APL-011),
/// 8. fallback větve: nedostupnost a nevalidní výstup (samostatný test).
class _ScriptedAiApi implements AiApiClient {
  int calls = 0;

  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required String accessToken,
    required Map<String, Object?> context,
  }) async {
    calls++;
    return const PlanProposalResponse(
      proposal: {
        'summary': 'Týden postavený na lezeckém profilu a dostupnosti.',
        'planTitle': 'AI Lezecký týden',
        'workouts': [
          {
            'title': 'Silový blok A',
            'workoutType': 'STRENGTH',
            'dayOffset': 0,
            'reason': 'Hlavní silový stimul pro lezecký cíl.',
            'plannedDurationMinutes': 60,
            'exercises': [
              {'title': 'Dřep', 'sets': 3, 'repetitions': 5, 'weightKg': 80},
            ],
          },
          {
            'title': 'Mobilita ramen',
            'workoutType': 'MOBILITY',
            'dayOffset': 2,
            'reason': 'Prevence s ohledem na omezení ramene.',
          },
        ],
      },
      promptVersion: 'plan-proposal-v1',
      schemaVersion: 'plan-proposal-schema-v1',
      modelId: 'fake-model',
    );
  }
}

class _InvalidOutputAiApi implements AiApiClient {
  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required String accessToken,
    required Map<String, Object?> context,
  }) async => const PlanProposalResponse(
    // Chybí reason — klientská re-validace to musí odmítnout (SOV-003).
    proposal: {
      'summary': 's',
      'planTitle': 'p',
      'workouts': [
        {'title': 'W', 'workoutType': 'STRENGTH', 'dayOffset': 0},
      ],
    },
    promptVersion: 'plan-proposal-v1',
    schemaVersion: 'plan-proposal-schema-v1',
    modelId: 'fake-model',
  );
}

class _UnavailableAiApi implements AiApiClient {
  int calls = 0;

  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required String accessToken,
    required Map<String, Object?> context,
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
          FakeInstallationIdentity('installation-r4-e2e'),
        ),
        syncApiClientProvider.overrideWithValue(sync),
        aiApiClientProvider.overrideWithValue(aiApi),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    return container;
  }

  test('kritická R4 cesta: profil → kontext → návrh → odmítnutí → '
      'potvrzení+provedení → Today → R1 flow → push', () async {
    final aiApi = _ScriptedAiApi();
    final syncApi = FakeSyncApiClient();
    final container = buildContainer(aiApi, syncApi);
    final day0 = scheduledDateForOffset(fixedNow, 0);
    final day2 = scheduledDateForOffset(fixedNow, 2);

    // ---- 1. Účet (AI vyžaduje přihlášení, AGW-008) + profil. ----
    await container.read(authSessionManagerProvider.future);
    expect(
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'r4@example.com', password: 'password-123'),
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
        .read(goalRepositoryProvider)
        .saveGoal(
          const GoalInput(
            title: '7a na laně',
            goalType: 'PERFORMANCE',
            priority: 'PRIMARY',
            userSportId: 'us1',
          ),
          newId: 'g1',
          now: fixedNow,
        );
    final availability = container.read(availabilityProfileRepositoryProvider);
    await availability.upsertDay(
      dayOfWeek: 'MON',
      level: 'AVAILABLE',
      budgetMinutes: 90,
      newId: 'av1',
      now: fixedNow,
    );
    await availability.addConstraint(
      title: 'Bolavé rameno',
      newId: 'c1',
      now: fixedNow,
    );

    // ---- 2. Minimalizovaný AIContext (C27): sport ano, ID/owner ne. ----
    final context = await container
        .read(aiContextBuilderProvider)
        .buildPlanProposalContext(now: fixedNow);
    final serialized = jsonEncode(context.payload);
    expect(serialized, contains('CLIMBING'));
    for (final forbidden in ['us1', 'g1', 'account-1', 'rowVersion']) {
      expect(
        serialized.contains(forbidden),
        isFalse,
        reason: 'kontext nese zakázaný obsah: $forbidden',
      );
    }

    // ---- 3. Žádost → validovaný návrh PROPOSED s trojicí verzí. ----
    final firstRequest = await container.read(requestPlanProposalProvider)();
    final rejectedId = (firstRequest as ProposalCreated).proposalId;
    final secondRequest = await container.read(requestPlanProposalProvider)();
    final confirmedId = (secondRequest as ProposalCreated).proposalId;
    final proposals = container.read(aiProposalRepositoryProvider);
    final stored = (await proposals.proposalById(confirmedId))!;
    expect(stored.status, 'PROPOSED');
    expect(stored.promptVersion, 'plan-proposal-v1');
    expect(stored.schemaVersion, 'plan-proposal-schema-v1');
    expect(stored.modelId, 'fake-model');

    // ---- 4. Odmítnutí je viditelný zachovaný stav (APL-006, RSR-012). ----
    final controller = container.read(aiScreenControllerProvider.notifier);
    await controller.decide(rejectedId, ProposalDecision.reject);
    expect((await proposals.proposalById(rejectedId))!.status, 'REJECTED');

    // ---- 5. Potvrzení = provedení (C30): atomicky přes C20 s provenance. ----
    await controller.decide(confirmedId, ProposalDecision.confirm);
    expect(container.read(aiScreenControllerProvider), isA<AiDone>());
    final executed = (await proposals.proposalById(confirmedId))!;
    expect(executed.status, 'EXECUTED');
    final aiPlan =
        (await container
                .read(trainingPlanRepositoryProvider)
                .plansForCurrentOwner())
            .single;
    expect(aiPlan.id, executed.executedPlanId);
    expect(aiPlan.origin, 'AI_PROPOSAL');
    expect(aiPlan.title, 'AI Lezecký týden');
    final planWorkouts = await container
        .read(trainingPlanRepositoryProvider)
        .workoutsForPlan(aiPlan.id);
    expect(planWorkouts.map((w) => w.scheduledLocalDate), [day0, day2]);

    // ---- 6. AI workout v Today → celý R1 flow (CSE-009). ----
    final inToday = await container
        .read(workoutInstanceRepositoryProvider)
        .workoutsForLocalDate(day0);
    final aiWorkout = inToday.single;
    expect(aiWorkout.title, 'Silový blok A');
    expect(
      await container
          .read(workoutSessionRepositoryProvider)
          .startSession(
            workoutInstanceId: aiWorkout.id,
            newSessionId: 'ses-r4-1',
            now: fixedNow,
          ),
      isA<SessionCreated>(),
    );
    final performance = container.read(workoutPerformanceRepositoryProvider);
    await performance.initializePerformances(
      sessionId: 'ses-r4-1',
      now: fixedNow,
    );
    final tracker = await performance.loadTracker('ses-r4-1');
    await performance.recordSetActuals(
      setPerformanceId: tracker!.exercises.single.sets.first.setPerformanceId,
      actualRepetitions: 5,
      actualWeightKg: 82.5,
      now: fixedNow,
    );
    expect(
      await container.read(completeWorkoutProvider)(sessionId: 'ses-r4-1'),
      isA<WorkoutCompleted>(),
    );
    final history = await container
        .read(workoutHistoryRepositoryProvider)
        .completedWorkouts();
    expect(history.single.title, 'Silový blok A');

    // ---- 7. Push: AI plán s provenance; návrhy mimo sync (APL-011). ----
    final push = await container.read(syncEngineProvider).pushPending();
    expect(push, isA<SyncRunCompleted>());
    expect((push as SyncRunCompleted).conflicts + push.rejected, 0);
    final operations = syncApi.pushedBatches.single;
    final types = operations.map((op) => op.entityType).toSet();
    expect(
      types,
      containsAll(['TRAINING_PLAN', 'WORKOUT_INSTANCE', 'WORKOUT_SESSION']),
    );
    expect(types.contains('AI_PROPOSAL'), isFalse);
    final planOp = operations.singleWhere(
      (op) => op.entityType == 'TRAINING_PLAN',
    );
    expect(planOp.payload['origin'], 'AI_PROPOSAL');
    // Replay je no-op (idempotence trvá).
    final replay = await container.read(syncEngineProvider).pushPending();
    expect((replay as SyncRunCompleted).synced, 0);
  });

  test('fallback větve: nedostupnost i nevalidní výstup jsou typované, nic '
      'se nepersistuje a neopakuje (AIS-001/002, SOV-005)', () async {
    final unavailable = _UnavailableAiApi();
    final containerA = buildContainer(unavailable, FakeSyncApiClient());
    await containerA.read(authSessionManagerProvider.future);
    expect(
      await containerA
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'r4b@example.com', password: 'password-123'),
      isA<AuthFlowSuccess>(),
    );
    expect(
      await containerA.read(requestPlanProposalProvider)(),
      isA<ProposalUnavailable>(),
    );
    expect(unavailable.calls, 1);
    expect(
      await containerA
          .read(aiProposalRepositoryProvider)
          .proposalsForCurrentOwner(),
      isEmpty,
    );

    final containerB = buildContainer(
      _InvalidOutputAiApi(),
      FakeSyncApiClient(),
    );
    await containerB.read(authSessionManagerProvider.future);
    expect(
      await containerB
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'r4c@example.com', password: 'password-123'),
      isA<AuthFlowSuccess>(),
    );
    expect(
      await containerB.read(requestPlanProposalProvider)(),
      isA<ProposalInvalidOutput>(),
    );
    expect(
      await containerB
          .read(aiProposalRepositoryProvider)
          .proposalsForCurrentOwner(),
      isEmpty,
    );
  });
}
