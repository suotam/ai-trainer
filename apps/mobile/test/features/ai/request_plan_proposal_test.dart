import 'package:ai_trainer_mobile/features/ai/application/request_plan_proposal.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_ai_context_builder.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_ai_proposal_repository.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/data/plan_proposal_client_validator.dart';
import 'package:ai_trainer_mobile/features/ai/domain/ai_proposal.dart';
import 'package:ai_trainer_mobile/features/auth/domain/stored_auth_session.dart';
import 'package:ai_trainer_mobile/features/activity/data/drift_activity_repository.dart';
import 'package:ai_trainer_mobile/features/availability/data/drift_availability_profile_repository.dart';
import 'package:ai_trainer_mobile/features/goals/data/drift_goal_repository.dart';
import 'package:ai_trainer_mobile/features/sports/data/drift_user_sport_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R4-03 testy use case + klientské validace + persistence návrhu
/// (C28/C29): PROPOSED s trojicí verzí, nevalidní odpověď se nepersistuje,
/// anonymní stav typovaný, nedostupnost typovaná.
class _FakeAiApiClient implements AiApiClient {
  _FakeAiApiClient(this._behavior);

  final Future<PlanProposalResponse> Function() _behavior;
  int calls = 0;

  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required String accessToken,
    required Map<String, Object?> context,
  }) {
    calls += 1;
    return _behavior();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 19);

  const validProposal = {
    'summary': 'Týdenní silový plán.',
    'planTitle': 'Silový týden',
    'workouts': [
      {
        'title': 'Full Body A',
        'workoutType': 'STRENGTH',
        'dayOffset': 0,
        'reason': 'Základní stimul.',
        'exercises': [
          {'title': 'Dřep', 'sets': 3, 'repetitions': 5, 'weightKg': 80},
        ],
      },
    ],
  };

  PlanProposalResponse response(Map<String, Object?> proposal) =>
      PlanProposalResponse(
        proposal: proposal,
        promptVersion: 'plan-proposal-v1',
        schemaVersion: 'plan-proposal-schema-v1',
        modelId: 'fake-model',
      );

  ({RequestPlanProposal useCase, DriftAiProposalRepository repo}) harness(
    db, {
    required AiApiClient api,
    bool signedIn = true,
  }) {
    final storage = InMemorySecureSessionStorage();
    if (signedIn) {
      // Minimální uložená session — use case čte jen accessToken.
      storage.stored = StoredAuthSession(
        accountId: 'account-1',
        sessionId: 'session-1',
        accessToken: 'access-token',
        accessExpiresAt: now.add(const Duration(minutes: 15)),
        refreshToken: 'refresh-token',
        refreshExpiresAt: now.add(const Duration(days: 30)),
      );
    }
    final repo = DriftAiProposalRepository(db);
    var seq = 0;
    return (
      useCase: RequestPlanProposal(
        storage: storage,
        contextBuilder: DriftAiContextBuilder(
          DriftUserSportRepository(db),
          DriftGoalRepository(db),
          DriftAvailabilityProfileRepository(db),
          DriftActivityRepository(db),
        ),
        apiClient: api,
        proposals: repo,
        newId: () => 'proposal-${seq++}',
        clock: () => now,
      ),
      repo: repo,
    );
  }

  test('úspěch: validovaný návrh se uloží jako PROPOSED s trojicí verzí '
      '(APL-002/003)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final api = _FakeAiApiClient(() async => response(validProposal));
    final h = harness(db, api: api);

    final result = await h.useCase();

    expect(result, isA<ProposalCreated>());
    final proposal = (await h.repo.proposalsForCurrentOwner()).single;
    expect(proposal.status, 'PROPOSED');
    expect(proposal.promptVersion, 'plan-proposal-v1');
    expect(proposal.schemaVersion, 'plan-proposal-schema-v1');
    expect(proposal.modelId, 'fake-model');
    expect(proposal.summary, 'Týdenní silový plán.');
    expect((proposal.payload['workouts']! as List), hasLength(1));
  });

  test('nevalidní odpověď serveru se nepersistuje — obrana do hloubky '
      '(SOV-003/005)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    // Chybí povinné reason → klientská validace odmítne.
    final api = _FakeAiApiClient(
      () async => response({
        'summary': 's',
        'planTitle': 'p',
        'workouts': [
          {'title': 'W', 'workoutType': 'STRENGTH', 'dayOffset': 0},
        ],
      }),
    );
    final h = harness(db, api: api);

    expect(await h.useCase(), isA<ProposalInvalidOutput>());
    expect(await h.repo.proposalsForCurrentOwner(), isEmpty);
  });

  test(
    'anonymní stav je typovaný SignInRequired bez volání API (AGW-008)',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final api = _FakeAiApiClient(() async => response(validProposal));
      final h = harness(db, api: api, signedIn: false);

      expect(await h.useCase(), isA<ProposalSignInRequired>());
      expect(api.calls, 0);
      expect(await h.repo.proposalsForCurrentOwner(), isEmpty);
    },
  );

  test(
    'nedostupnost i nevalidní výstup serveru jsou typované (R4P-010)',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final unavailable = _FakeAiApiClient(
        () async => throw const AiApiFailure(AiApiFailureKind.unavailable),
      );
      expect(
        await harness(db, api: unavailable).useCase(),
        isA<ProposalUnavailable>(),
      );
      final invalid = _FakeAiApiClient(
        () async => throw const AiApiFailure(AiApiFailureKind.invalidOutput),
      );
      expect(
        await harness(db, api: invalid).useCase(),
        isA<ProposalInvalidOutput>(),
      );
    },
  );

  test('klientský validátor: kanonizace zahazuje neznámá pole a meze jsou '
      'závazné (SOV-008/009)', () {
    final withUnknown = {...validProposal, 'unknownField': 'ignore'};
    final canonical = validatePlanProposalPayload(withUnknown);
    expect(canonical, isNotNull);
    expect(canonical!.containsKey('unknownField'), isFalse);

    expect(
      validatePlanProposalPayload({
        'summary': 's',
        'planTitle': 'p',
        'workouts': [
          {
            'title': 'W',
            'workoutType': 'STRENGTH',
            'dayOffset': 99,
            'reason': 'r',
          },
        ],
      }),
      isNull,
    );
    expect(validatePlanProposalPayload('not a map'), isNull);
  });
}
