import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/ai/application/ai_providers.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_ai_proposal_repository.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/ai_proposal.dart';
import 'package:ai_trainer_mobile/features/ai/presentation/ai_proposals_screen.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/stored_auth_session.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R4-04 testy review (C29): decide přechody (potvrzení/odmítnutí/
/// expirace/terminalita) a widget flow žádost → review → rozhodnutí.
class _ScriptedAiApi implements AiApiClient {
  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required Map<String, Object?> context,
    String requestType = 'PLAN_PROPOSAL',
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

  final now = DateTime.utc(2026, 8, 14, 20);

  Future<void> seedProposal(
    DriftAiProposalRepository repo, {
    required String id,
    required DateTime createdAt,
  }) => repo.saveProposed(
    id: id,
    requestType: 'PLAN_PROPOSAL',
    canonicalPayload: const {
      'summary': 's',
      'planTitle': 'p',
      'workouts': [
        {
          'title': 'W',
          'workoutType': 'STRENGTH',
          'dayOffset': 0,
          'reason': 'r',
        },
      ],
    },
    summary: 's',
    promptVersion: 'plan-proposal-v1',
    schemaVersion: 'plan-proposal-schema-v1',
    modelId: 'fake-model',
    now: createdAt,
  );

  test('decide: confirm/reject jen z PROPOSED; expirace po 7 dnech; '
      'terminalita (APL-004/006/007/009)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftAiProposalRepository(db);

    await seedProposal(repo, id: 'p-confirm', createdAt: now);
    await seedProposal(repo, id: 'p-reject', createdAt: now);
    await seedProposal(
      repo,
      id: 'p-old',
      createdAt: now.subtract(const Duration(days: 8)),
    );

    // Potvrzení a odmítnutí.
    expect(
      await repo.decide('p-confirm', ProposalDecision.confirm, now: now),
      isA<DecisionSaved>(),
    );
    expect((await repo.proposalById('p-confirm'))!.status, 'CONFIRMED');
    expect(
      await repo.decide('p-reject', ProposalDecision.reject, now: now),
      isA<DecisionSaved>(),
    );
    // Odmítnutí je zachovaný viditelný stav (APL-006).
    expect((await repo.proposalById('p-reject'))!.status, 'REJECTED');

    // Terminalita: druhé rozhodnutí je typovaně odmítnuto (APL-009).
    expect(
      await repo.decide('p-confirm', ProposalDecision.reject, now: now),
      isA<DecisionInvalidState>(),
    );

    // Expirace při potvrzení po 7 dnech (APL-007).
    expect(
      await repo.decide('p-old', ProposalDecision.confirm, now: now),
      isA<DecisionExpired>(),
    );
    expect((await repo.proposalById('p-old'))!.status, 'EXPIRED');

    // Neexistující návrh.
    expect(
      await repo.decide('missing', ProposalDecision.confirm, now: now),
      isA<DecisionNotFound>(),
    );
    // Žádné mazání — všechny návrhy zůstávají (APL-008).
    expect(await repo.proposalsForCurrentOwner(), hasLength(3));
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

  testWidgets('žádost → návrh v seznamu → review s důvody → přijetí '
      '(APL-005) a viditelný stav', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    expect(find.byKey(AiProposalsScreen.emptyKey), findsOneWidget);

    await tester.tap(find.byKey(AiProposalsScreen.requestButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(AiProposalsScreen.emptyKey), findsNothing);
    expect(find.text('AI Silový týden'), findsOneWidget);

    // Review: důvody a dopady viditelné.
    await tester.tap(find.text('AI Silový týden'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Základní stimul.'), findsOneWidget);
    expect(find.textContaining('Day 0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ai_review_confirm')));
    await tester.pumpAndSettle();
    // Od R4-05 (C30 §2) potvrzení = souhlas s provedením: návrh se v témže
    // kroku provede a viditelný stav je Applied.
    expect(find.textContaining('Applied'), findsOneWidget);
  });

  testWidgets('odmítnutí je viditelný stav (RSR-012) a rozhodovací akce '
      'zmizí', (tester) async {
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
    await tester.tap(find.byKey(const Key('ai_review_reject')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Rejected'), findsOneWidget);
    // Terminální návrh už rozhodovací akce nenabízí.
    await tester.tap(find.text('AI Silový týden'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai_review_confirm')), findsNothing);
    expect(find.byKey(const Key('ai_review_reject')), findsNothing);
  });
}
