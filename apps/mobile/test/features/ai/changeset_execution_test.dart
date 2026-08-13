import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/database/tables/workout_tables.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/ai/application/ai_providers.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_ai_proposal_repository.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_proposal_executor.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/ai_proposal.dart';
import 'package:ai_trainer_mobile/features/ai/domain/proposal_executor.dart';
import 'package:ai_trainer_mobile/features/ai/presentation/ai_proposals_screen.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/stored_auth_session.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_sync_snapshot_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_instance_repository.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R4-05 testy execution (C30): atomické provedení potvrzeného návrhu
/// výhradně C20 cestami, rollback bez částečného stavu, provenance,
/// terminalita a viditelnost v R1 read modelech + sync collection.
class _ScriptedAiApi implements AiApiClient {
  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required String accessToken,
    required Map<String, Object?> context,
  }) async => const PlanProposalResponse(
    proposal: {
      'summary': 'Silový týden podle profilu.',
      'planTitle': 'AI Silový týden',
      'workouts': [
        {
          'title': 'Full Body A',
          'workoutType': 'STRENGTH',
          'dayOffset': 0,
          'reason': 'Základní stimul.',
        },
      ],
    },
    promptVersion: 'plan-proposal-v1',
    schemaVersion: 'plan-proposal-schema-v1',
    modelId: 'fake-model',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Poledne UTC: lokální datum je stejné pro všechny běžné časové zóny.
  final now = DateTime.utc(2026, 8, 14, 12);
  final day0 = scheduledDateForOffset(now, 0);
  final day2 = scheduledDateForOffset(now, 2);

  String Function() counterIds(String prefix) {
    var next = 0;
    return () => '$prefix-${next++}';
  }

  Future<String> seedConfirmedProposal(
    DriftAiProposalRepository repo, {
    required String id,
    required Map<String, Object?> payload,
  }) async {
    await repo.saveProposed(
      id: id,
      requestType: 'PLAN_PROPOSAL',
      canonicalPayload: payload,
      summary: 's',
      promptVersion: 'plan-proposal-v1',
      schemaVersion: 'plan-proposal-schema-v1',
      modelId: 'fake-model',
      now: now,
    );
    expect(
      await repo.decide(id, ProposalDecision.confirm, now: now),
      isA<DecisionSaved>(),
    );
    return id;
  }

  const validPayload = {
    'summary': 'Silový týden.',
    'planTitle': 'AI Silový týden',
    'workouts': [
      {
        'title': 'Full Body A',
        'workoutType': 'STRENGTH',
        'dayOffset': 0,
        'reason': 'Základní stimul.',
        'plannedDurationMinutes': 45,
        'exercises': [
          {'title': 'Dřep', 'sets': 3, 'repetitions': 8, 'weightKg': 60},
          {'title': 'Kliky', 'sets': 2, 'repetitions': 12},
        ],
      },
      {
        'title': 'Lehký běh',
        'workoutType': 'ENDURANCE',
        'dayOffset': 2,
        'reason': 'Regenerace.',
      },
    ],
  };

  test('provedení: C20 struktura, dayOffset mapování, provenance, '
      'reference, R1 read model a sync collection (CSE-001/004/005/008/009), '
      'terminalita (CSE-010)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final proposals = DriftAiProposalRepository(db);
    final plans = DriftTrainingPlanRepository(db);
    final executor = DriftProposalExecutor(db, plans, proposals);

    await seedConfirmedProposal(proposals, id: 'p-1', payload: validPayload);

    final result = await executor.execute(
      'p-1',
      newId: counterIds('exec'),
      now: now,
    );
    expect(result, isA<ExecutionSaved>());
    final planId = (result as ExecutionSaved).planId;

    // dayOffset mapování: den 2 = den provedení + 2 dny (CSE-008).
    expect(DateTime.parse(day2).difference(DateTime.parse(day0)).inDays, 2);

    // Plán vznikl C20 cestou s provenance (CSE-001/004).
    final planList = await plans.plansForCurrentOwner();
    expect(planList, hasLength(1));
    expect(planList.single.id, planId);
    expect(planList.single.title, 'AI Silový týden');
    expect(planList.single.origin, 'AI_PROPOSAL');
    expect(planList.single.isActive, isTrue);

    // Návrh je EXECUTED s referencí (CSE-005, APL-010).
    final executed = (await proposals.proposalById('p-1'))!;
    expect(executed.status, 'EXECUTED');
    expect(executed.executedPlanId, planId);

    // Workouty: datumy z offsetů, plná R1 struktura (MPC-004).
    final workouts = await plans.workoutsForPlan(planId);
    expect(workouts, hasLength(2));
    expect(workouts[0].scheduledLocalDate, day0);
    expect(workouts[0].exerciseCount, 2);
    expect(workouts[1].scheduledLocalDate, day2);
    expect(workouts[1].exerciseCount, 0);

    Future<int> count(String table) async =>
        (await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle())
                .data['c']
            as int;
    expect(await count('local_workout_sections'), 2);
    expect(await count('local_workout_steps'), 2);
    expect(await count('local_set_plans'), 5);

    // AI workout žije běžným R1 lifecycle — Today read model (CSE-009).
    final todayList = await DriftWorkoutInstanceRepository(
      db,
    ).workoutsForLocalDate(day0);
    expect(todayList.map((w) => w.title), contains('Full Body A'));

    // Vzniklý plán sbírá existující push s provenance (CSE-004/009).
    final planned = await DriftSyncSnapshotRepository(
      db,
    ).collectPendingEntities(localAnonymousOwnerId);
    final planEntity = planned.singleWhere(
      (e) => e.entityType == 'TRAINING_PLAN' && e.entityId == planId,
    );
    expect(planEntity.payload['origin'], 'AI_PROPOSAL');
    expect(
      planned.where((e) => e.entityType == 'WORKOUT_INSTANCE'),
      hasLength(2),
    );

    // Terminalita: druhé provedení = typovaný InvalidState, žádný druhý
    // plán z téhož návrhu (CSE-010).
    expect(
      await executor.execute('p-1', newId: counterIds('again'), now: now),
      isA<ExecutionInvalidState>(),
    );
    expect(await plans.plansForCurrentOwner(), hasLength(1));
  });

  test('konflikt ACTIVE plánu: typované selhání, žádný částečný stav, '
      'retry po archivaci (CSE-002/003/007/013)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final proposals = DriftAiProposalRepository(db);
    final plans = DriftTrainingPlanRepository(db);
    final executor = DriftProposalExecutor(db, plans, proposals);

    expect(
      await plans.createPlan(title: 'Můj plán', newId: 'manual-1', now: now),
      isA<PlanWriteSaved>(),
    );
    await seedConfirmedProposal(proposals, id: 'p-2', payload: validPayload);

    // MPC-002 platí i pro AI (CSE-002).
    expect(
      await executor.execute('p-2', newId: counterIds('c'), now: now),
      isA<ExecutionActivePlanConflict>(),
    );
    expect((await proposals.proposalById('p-2'))!.status, 'EXECUTION_FAILED');
    expect(await plans.plansForCurrentOwner(), hasLength(1));

    // Ruční cesty nedegradované (CSE-013): běžná archivace + explicitní
    // retry (CSE-007).
    expect(
      await plans.setPlanStatus('manual-1', 'ARCHIVED', now: now),
      isA<PlanWriteSaved>(),
    );
    final retried = await executor.execute(
      'p-2',
      newId: counterIds('r'),
      now: now,
    );
    expect(retried, isA<ExecutionSaved>());
    expect((await proposals.proposalById('p-2'))!.status, 'EXECUTED');
  });

  test('nemapovatelný payload: rollback celého provedení — žádný částečný '
      'stav (CSE-003/012); PROPOSED se nikdy neprovádí (C30 §2)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final proposals = DriftAiProposalRepository(db);
    final plans = DriftTrainingPlanRepository(db);
    final executor = DriftProposalExecutor(db, plans, proposals);

    // První workout je validní — vloží se a rollback ho musí odvolat.
    await seedConfirmedProposal(
      proposals,
      id: 'p-3',
      payload: const {
        'summary': 's',
        'planTitle': 'AI Plán',
        'workouts': [
          {
            'title': 'Validní',
            'workoutType': 'STRENGTH',
            'dayOffset': 0,
            'reason': 'r',
          },
          {'workoutType': 'STRENGTH', 'dayOffset': 1, 'reason': 'r'},
        ],
      },
    );
    expect(
      await executor.execute('p-3', newId: counterIds('x'), now: now),
      isA<ExecutionInvalidPayload>(),
    );
    expect(await plans.plansForCurrentOwner(), isEmpty);
    Future<int> count(String table) async =>
        (await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle())
                .data['c']
            as int;
    expect(await count('local_workout_instances'), 0);
    expect(await count('local_workout_sections'), 0);
    expect((await proposals.proposalById('p-3'))!.status, 'EXECUTION_FAILED');

    // Nerozhodnutý návrh nikdy nejedná (APL-001).
    await proposals.saveProposed(
      id: 'p-proposed',
      requestType: 'PLAN_PROPOSAL',
      canonicalPayload: validPayload,
      summary: 's',
      promptVersion: 'plan-proposal-v1',
      schemaVersion: 'plan-proposal-schema-v1',
      modelId: 'fake-model',
      now: now,
    );
    expect(
      await executor.execute('p-proposed', newId: counterIds('p'), now: now),
      isA<ExecutionInvalidState>(),
    );
    expect(
      await executor.execute('missing', newId: counterIds('m'), now: now),
      isA<ExecutionNotFound>(),
    );
  });

  Widget app(AppDatabase database) {
    final storage = InMemorySecureSessionStorage()
      ..stored = StoredAuthSession(
        accountId: 'account-1',
        sessionId: 'session-1',
        accessToken: 'access-token',
        accessExpiresAt: now.add(const Duration(minutes: 15)),
        refreshToken: 'refresh-token',
        refreshExpiresAt: now.add(const Duration(days: 30)),
      );
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => now),
        secureSessionStorageProvider.overrideWithValue(storage),
        aiApiClientProvider.overrideWithValue(_ScriptedAiApi()),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AiProposalsScreen(),
      ),
    );
  }

  testWidgets('potvrzení provede návrh v témže kroku — viditelný stav '
      'Applied (C30 §2)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(AiProposalsScreen.requestButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI Silový týden'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai_review_confirm')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Applied'), findsOneWidget);
    // Plán skutečně vznikl s provenance (CSE-004).
    final plansList = await DriftTrainingPlanRepository(
      database,
    ).plansForCurrentOwner();
    expect(plansList.single.origin, 'AI_PROPOSAL');
  });

  testWidgets('konflikt při potvrzení: typovaný banner, Apply failed a '
      'explicitní retry po archivaci (CSE-006/007/013)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final database = createTestDatabase();
    addTearDown(database.close);
    final plans = DriftTrainingPlanRepository(database);
    expect(
      await plans.createPlan(title: 'Můj plán', newId: 'manual-1', now: now),
      isA<PlanWriteSaved>(),
    );

    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AiProposalsScreen.requestButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI Silový týden'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai_review_confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(AiProposalsScreen.errorBannerKey), findsOneWidget);
    expect(find.textContaining('Apply failed'), findsOneWidget);

    // Běžná archivace (CSE-013) a explicitní retry (CSE-007).
    expect(
      await plans.setPlanStatus('manual-1', 'ARCHIVED', now: now),
      isA<PlanWriteSaved>(),
    );
    await tester.tap(find.text('AI Silový týden'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai_review_retry')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Applied'), findsOneWidget);
  });
}
