import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/ai/application/ai_providers.dart';
import 'package:ai_trainer_mobile/features/ai/data/adjustment_proposal_client_validator.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/presentation/ai_proposals_screen.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_proposal_executor.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/stored_auth_session.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R5-05 testy adjustment návrhu (C37): klientský validátor (tvarová
/// tabulka, ASJ-002/003), persistence s adjustment trojicí verzí a widget
/// review operací s potvrzením bez execution (ASJ-009).
class _ScriptedAdjustmentApi implements AiApiClient {
  String? lastRequestType;

  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required String accessToken,
    required Map<String, Object?> context,
    String requestType = 'PLAN_PROPOSAL',
  }) async {
    lastRequestType = requestType;
    return const PlanProposalResponse(
      proposal: {
        'summary': 'Lehčí týden kvůli únavě.',
        'operations': [
          {
            'operation': 'MOVE',
            'reason': 'Den regenerace navíc.',
            'target': {'dayOffset': 0, 'title': 'Full Body A'},
            'toDayOffset': 2,
          },
          {
            'operation': 'CANCEL',
            'reason': 'Vysoká hlášená únava.',
            'target': {'dayOffset': 1, 'title': 'Intervaly'},
          },
        ],
      },
      promptVersion: 'adjustment-proposal-v1',
      schemaVersion: 'adjustment-proposal-schema-v1',
      modelId: 'fake-model',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 12);

  test('klientský validátor: tvarová tabulka operací přesně (ASJ-002/003)', () {
    const valid = {
      'summary': 's',
      'operations': [
        {
          'operation': 'REPLACE',
          'reason': 'r',
          'target': {'dayOffset': 3, 'title': 'Heavy'},
          'workout': {'title': 'Light', 'workoutType': 'MOBILITY'},
          'ignoredField': true,
        },
      ],
    };
    final canonical = validateAdjustmentProposalPayload(valid)!;
    final operation = (canonical['operations']! as List).single as Map;
    expect(operation.containsKey('ignoredField'), isFalse);
    expect((operation['workout']! as Map).containsKey('dayOffset'), isFalse);

    const invalidCases = [
      // Bez reason.
      {
        'summary': 's',
        'operations': [
          {
            'operation': 'CANCEL',
            'target': {'dayOffset': 0, 'title': 'W'},
          },
        ],
      },
      // MOVE bez toDayOffset.
      {
        'summary': 's',
        'operations': [
          {
            'operation': 'MOVE',
            'reason': 'r',
            'target': {'dayOffset': 0, 'title': 'W'},
          },
        ],
      },
      // REPLACE workout s dayOffset (den dědí z targetu).
      {
        'summary': 's',
        'operations': [
          {
            'operation': 'REPLACE',
            'reason': 'r',
            'target': {'dayOffset': 0, 'title': 'W'},
            'workout': {
              'title': 'X',
              'workoutType': 'MOBILITY',
              'dayOffset': 1,
            },
          },
        ],
      },
      // Target mimo kontextový týden.
      {
        'summary': 's',
        'operations': [
          {
            'operation': 'CANCEL',
            'reason': 'r',
            'target': {'dayOffset': 7, 'title': 'W'},
          },
        ],
      },
      // Prázdné operace.
      {'summary': 's', 'operations': <Object?>[]},
    ];
    for (final invalid in invalidCases) {
      expect(
        validateAdjustmentProposalPayload(invalid),
        isNull,
        reason: '$invalid mělo být nevalidní',
      );
    }
  });

  Widget app(AppDatabase database, AiApiClient api) {
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
        aiApiClientProvider.overrideWithValue(api),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AiProposalsScreen(),
      ),
    );
  }

  testWidgets('žádost o úpravu → PROPOSED s adjustment trojicí verzí → '
      'review operací s důvody → potvrzení = provedení C21 cestami '
      '(ASJ-008/014, C38 §2)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final database = createTestDatabase();
    addTearDown(database.close);
    // Týden odpovídající fixture targetům (resolvace dle C38 §3).
    final plans = DriftTrainingPlanRepository(database);
    await plans.createPlan(title: 'Můj plán', newId: 'p1', now: now);
    var seq = 0;
    for (final (title, offset) in [('Full Body A', 0), ('Intervaly', 1)]) {
      await plans.addWorkout(
        'p1',
        PlannedWorkoutInput(
          title: title,
          workoutType: 'STRENGTH',
          scheduledLocalDate: scheduledDateForOffset(now, offset),
        ),
        newId: () => 'w-${seq++}',
        now: now,
      );
    }
    final api = _ScriptedAdjustmentApi();
    await tester.pumpWidget(app(database, api));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(AiProposalsScreen.adjustmentButtonKey));
    await tester.pumpAndSettle();
    expect(api.lastRequestType, 'ADJUSTMENT_PROPOSAL');

    // Návrh v seznamu → review: operace s dopady a důvody (ASJ-014).
    await tester.tap(find.text('Lehčí týden kvůli únavě.'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Move · Full Body A'), findsOneWidget);
    expect(find.textContaining('Day 0 → Day 2'), findsOneWidget);
    expect(find.textContaining('Vysoká hlášená únava.'), findsOneWidget);

    // Potvrzení = souhlas s provedením (C38 §2): MOVE + CANCEL proběhly
    // C21 cestami, návrh je EXECUTED s viditelným stavem Applied.
    await tester.tap(find.byKey(const Key('ai_review_confirm')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Applied'), findsOneWidget);
    final moved = await database
        .customSelect(
          'SELECT scheduled_local_date, status FROM local_workout_instances '
          "WHERE title = 'Full Body A'",
        )
        .getSingle();
    expect(moved.data['scheduled_local_date'], scheduledDateForOffset(now, 2));
    final cancelled = await database
        .customSelect(
          "SELECT status FROM local_workout_instances WHERE title = 'Intervaly'",
        )
        .getSingle();
    expect(cancelled.data['status'], 'CANCELLED');
    final status = await database
        .customSelect('SELECT status, request_type FROM local_ai_proposals')
        .getSingle();
    expect(status.data['status'], 'EXECUTED');
    expect(status.data['request_type'], 'ADJUSTMENT_PROPOSAL');
  });
}
