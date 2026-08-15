import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/ai/application/ai_providers.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/ai_proposal.dart';
import 'package:ai_trainer_mobile/features/ai/presentation/ai_proposals_screen.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/stored_auth_session.dart';
import 'package:ai_trainer_mobile/features/plan/application/plan_providers.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R4-06 fallback testy (C31): selhání AI je typovaný stav bez auto-retry
/// (AIS-001/002) a manuální cesty zůstávají plně funkční (AIS-003).
class _FailingAiApi implements AiApiClient {
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

  final now = DateTime.utc(2026, 8, 14, 12);

  ProviderContainer container(_FailingAiApi api) {
    final storage = InMemorySecureSessionStorage()
      ..stored = StoredAuthSession(
        accountId: 'account-1',
        sessionId: 'session-1',
        accessToken: 'access-token',
        accessExpiresAt: now.add(const Duration(minutes: 15)),
        refreshToken: 'refresh-token',
        refreshExpiresAt: now.add(const Duration(days: 30)),
      );
    final db = createTestDatabase();
    final scope = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        secureSessionStorageProvider.overrideWithValue(storage),
        aiApiClientProvider.overrideWithValue(api),
      ],
    );
    addTearDown(() async {
      scope.dispose();
      await db.close();
    });
    return scope;
  }

  test('nedostupná AI: typovaný výsledek, jediné volání (žádný auto-retry), '
      'nic se nepersistuje (AIS-001/002)', () async {
    final api = _FailingAiApi();
    final scope = container(api);

    final result = await scope.read(requestPlanProposalProvider)();
    expect(result, isA<ProposalUnavailable>());
    // Žádný automatický retry v celém řetězu (AIS-002).
    expect(api.calls, 1);
    expect(
      await scope.read(aiProposalRepositoryProvider).proposalsForCurrentOwner(),
      isEmpty,
    );
  });

  test(
    'po selhání AI jsou manuální cesty plně funkční (AIS-003, R4P-010)',
    () async {
      final api = _FailingAiApi();
      final scope = container(api);
      expect(
        await scope.read(requestPlanProposalProvider)(),
        isA<ProposalUnavailable>(),
      );

      // Ruční plánování běží beze změny — C20 cesta nezávisí na AI.
      final plans = scope.read(trainingPlanRepositoryProvider);
      expect(
        await plans.createPlan(
          title: 'Ruční plán',
          newId: 'manual-1',
          now: now,
        ),
        isA<PlanWriteSaved>(),
      );
      expect(
        await plans.addWorkout(
          'manual-1',
          const PlannedWorkoutInput(
            title: 'Ruční workout',
            workoutType: 'STRENGTH',
            scheduledLocalDate: '2026-08-14',
          ),
          newId: () => 'manual-workout-1',
          now: now,
        ),
        isA<PlanWriteSaved>(),
      );
      final workouts = await plans.workoutsForPlan('manual-1');
      expect(workouts.single.title, 'Ruční workout');
    },
  );

  testWidgets('nedostupná AI v UI: typovaný banner, poctivý empty stav, '
      'žádný pád (AIS-001)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final api = _FailingAiApi();
    final storage = InMemorySecureSessionStorage()
      ..stored = StoredAuthSession(
        accountId: 'account-1',
        sessionId: 'session-1',
        accessToken: 'access-token',
        accessExpiresAt: now.add(const Duration(minutes: 15)),
        refreshToken: 'refresh-token',
        refreshExpiresAt: now.add(const Duration(days: 30)),
      );
    final db = createTestDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          secureSessionStorageProvider.overrideWithValue(storage),
          aiApiClientProvider.overrideWithValue(api),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AiProposalsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(AiProposalsScreen.requestButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(AiProposalsScreen.errorBannerKey), findsOneWidget);
    expect(find.byKey(AiProposalsScreen.emptyKey), findsOneWidget);
    expect(api.calls, 1);
  });
}
