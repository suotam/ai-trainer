import 'dart:async';

import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/activity/data/drift_activity_repository.dart';
import 'package:ai_trainer_mobile/features/ai/application/ai_providers.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/byok_key_store.dart';
import 'package:ai_trainer_mobile/features/calendar/presentation/calendar_screen.dart';
import 'package:ai_trainer_mobile/features/chat/application/chat_providers.dart';
import 'package:ai_trainer_mobile/features/chat/domain/chat_ai_client.dart';
import 'package:ai_trainer_mobile/features/chat/presentation/chat_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/application/guided_session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/active_session_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/exercise_illustration.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/feedback_confirm_dialog.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/guided_session_card.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/history_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/workout_detail_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// R8-05 – kritický E2E důkaz hlavní hodnoty R8 (plán §9.5, §13):
/// chat → **plán v2 s plnou strukturou** (C52: sekce, katalogové kroky
/// C51, vlastní krok s popisem, REST krok, sady reps/čas s pauzami) →
/// přijetí → kalendář → detail (názvy z katalogu + ilustrace C54) →
/// Spustit → **průvodce krok za krokem** (C53: časovka DURATION, sady s
/// odpočtem pauzy, REST krok, přeskočení) → dokončení se skutečnými
/// výkony → statistiky/historie odpovídají (aktivní čas poctivě z časovačů).
/// Deterministicky: fake chat i fake proposal API, skutečná SQLite,
/// injektovaný clock, ticker řízený testem (GSP-005).
class _ScriptedChatClient implements ChatAiClient {
  int calls = 0;

  @override
  Future<String> chat({
    required List<ChatTurn> turns,
    required Map<String, Object?> profileContext,
  }) async {
    calls++;
    return '{"reply":"Připravím ti trénink — návrh potvrď níže.",'
        '"actions":[{"action":"REQUEST_PLAN"}]}';
  }
}

class _ScriptedProposalApiV2 implements AiApiClient {
  int calls = 0;

  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required Map<String, Object?> context,
    String requestType = 'PLAN_PROPOSAL',
  }) async {
    calls++;
    return PlanProposalResponse(
      proposal: {
        'summary': 'Krátký silový trénink s rozcvičkou a vyklidněním.',
        'planTitle': 'Vedený týden',
        'workouts': [
          {
            'title': 'Silový základ',
            'workoutType': 'STRENGTH',
            'dayOffset': 0,
            'reason': 'Základ síly horní poloviny těla.',
            'plannedDurationMinutes': 25,
            'sections': [
              {
                'sectionType': 'WARM_UP',
                'steps': [
                  {
                    'stepType': 'EXERCISE',
                    'exerciseCode': 'JUMPING_JACKS',
                    'prescription': 'DURATION',
                    'sets': [
                      {'durationSeconds': 20},
                    ],
                  },
                ],
              },
              {
                'sectionType': 'MAIN',
                'steps': [
                  {
                    'stepType': 'EXERCISE',
                    'exerciseCode': 'PUSH_UP',
                    'prescription': 'SET_REP',
                    'sets': [
                      {'repetitions': 8, 'restAfterSeconds': 30},
                      {'repetitions': 8, 'restAfterSeconds': 30},
                    ],
                    'note': 'Kolena dolů, když forma padá.',
                  },
                  {'stepType': 'REST', 'durationSeconds': 15},
                  {
                    'stepType': 'EXERCISE',
                    'customTitle': 'Farmářská chůze',
                    'instructions':
                        'Vezmi těžké činky podél těla a choď vzpřímeně, '
                        'ramena dole, po celou dobu.',
                    'prescription': 'DURATION',
                    'sets': [
                      {'durationSeconds': 30},
                    ],
                  },
                ],
              },
              {
                'sectionType': 'COOLDOWN',
                'steps': [
                  {
                    'stepType': 'EXERCISE',
                    'exerciseCode': 'CAT_COW',
                    'prescription': 'SET_REP',
                    'sets': [
                      {'repetitions': 10},
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
      promptVersion: 'plan-proposal-v3',
      schemaVersion: 'plan-proposal-schema-v2',
      modelId: 'fake-model',
    );
  }
}

class _KeyStore implements ByokKeyStore {
  String? key = 'sk-ant-e2e-1234';

  @override
  Future<String?> read() async => key;

  @override
  Future<void> write(String value) async => key = value;

  @override
  Future<void> clear() async => key = null;
}

class _Ids implements IdGenerator {
  int _next = 0;

  @override
  String newId() => 'r8-id-${_next++}';
}

void main() {
  final t0 = DateTime.utc(2026, 8, 17, 9);
  var now = t0;
  final today = formatLocalDate(t0);

  testWidgets('R8 E2E: chat → plán v2 → přijetí → kalendář → detail → '
      'Spustit → průvodce (časovka, sady + pauzy, REST, přeskočení) → '
      'dokončení → statistiky', (tester) async {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Průvodce animuje ilustrace nekonečně (C54); test respektuje systémové
    // `disableAnimations` (EXI-009), aby `pumpAndSettle` byl deterministický.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    now = t0;

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final chatClient = _ScriptedChatClient();
    final proposalApi = _ScriptedProposalApiV2();
    // Ticker řízený testem: čas posouvá jen injektovaný clock, tik jen
    // překreslí (GSP-005).
    final ticker = StreamController<int>.broadcast();
    addTearDown(ticker.close);
    var tick = 0;
    Future<void> advance(Duration by) async {
      now = now.add(by);
      ticker.add(++tick);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          r1SeedRepositoryProvider.overrideWithValue(
            FakeSeedRepository([SeedResult.applied]),
          ),
          clockProvider.overrideWithValue(() => now),
          idGeneratorProvider.overrideWithValue(_Ids()),
          chatAiClientProvider.overrideWithValue(chatClient),
          aiApiClientProvider.overrideWithValue(proposalApi),
          byokKeyStoreProvider.overrideWithValue(_KeyStore()),
          guidedTickerProvider.overrideWith((ref) => ticker.stream),
        ],
        child: const AiTrainerApp(),
      ),
    );
    await tester.pumpAndSettle();

    Future<int> count(String sql) async =>
        (await db.customSelect(sql).getSingle()).data.values.first as int;

    // ── Chat → plán v2 (C52) → karta návrhu se strukturou → přijetí.
    expect(find.byKey(ChatScreen.screenKey), findsOneWidget);
    await tester.enterText(
      find.byKey(ChatScreen.inputKey),
      'Postav mi krátký silový trénink na dnes.',
    );
    await tester.tap(find.byKey(ChatScreen.sendButtonKey));
    await tester.pumpAndSettle();
    expect(proposalApi.calls, 1);
    expect(find.text('Vedený týden'), findsOneWidget);
    // Karta návrhu ukazuje strukturu v2 (katalogové názvy, REST).
    expect(find.textContaining('Push-up'), findsWidgets);
    expect(await count('SELECT COUNT(*) AS c FROM local_training_plans'), 0);
    await tester.tap(find.text('Accept proposal'));
    await tester.pumpAndSettle();
    expect(await count('SELECT COUNT(*) AS c FROM local_training_plans'), 1);
    expect(await count('SELECT COUNT(*) AS c FROM local_workout_instances'), 1);
    expect(await count('SELECT COUNT(*) AS c FROM local_workout_sections'), 3);
    expect(await count('SELECT COUNT(*) AS c FROM local_workout_steps'), 5);
    expect(
      await count(
        "SELECT COUNT(*) AS c FROM local_workout_steps WHERE exercise_code IS NOT NULL",
      ),
      3,
    );
    expect(await count('SELECT COUNT(*) AS c FROM local_set_plans'), 5);

    // ── Kalendář (C50) → dnešek → detail: katalogové názvy, popis, ilustrace.
    await tester.tap(find.byIcon(Icons.calendar_month_outlined).first);
    await tester.pumpAndSettle();
    expect(find.byKey(CalendarScreen.screenKey), findsOneWidget);
    await tester.tap(find.byKey(CalendarScreen.dayKey(today)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Silový základ'));
    await tester.pumpAndSettle();
    expect(find.byKey(WorkoutDetailScreen.screenKey), findsOneWidget);
    expect(find.text('Push-up'), findsOneWidget);
    expect(find.text('Farmářská chůze'), findsOneWidget);
    expect(find.textContaining('Hands under the shoulders'), findsOneWidget);
    expect(find.textContaining('Vezmi těžké činky'), findsOneWidget);
    expect(
      find.byKey(ExerciseIllustration.illustrationKey('PUSH_UP')),
      findsOneWidget,
    );

    // ── Spustit → průvodce (C53): krok 1/5 Jumping jacks DURATION 20 s.
    await tester.tap(find.byKey(WorkoutDetailScreen.startButtonKey));
    await tester.pumpAndSettle();
    expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);
    expect(find.byKey(GuidedSessionCard.cardKey), findsOneWidget);
    expect(find.text('Step 1/5 · sets 0/5'), findsOneWidget);
    expect(find.text('Jumping jacks'), findsWidgets);
    expect(find.text('Set 1 of 1'), findsOneWidget);
    expect(
      find.byKey(ExerciseIllustration.illustrationKey('JUMPING_JACKS')),
      findsOneWidget,
    );
    expect(find.text('Start'), findsOneWidget);
    await tester.tap(find.byKey(GuidedSessionCard.primaryActionKey));
    await tester.pumpAndSettle();
    expect(find.text('0:20'), findsOneWidget);
    await advance(const Duration(seconds: 12));
    expect(find.text('0:08'), findsOneWidget);
    await advance(const Duration(seconds: 8));
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('Time is up'), findsOneWidget);
    await tester.tap(find.byKey(GuidedSessionCard.primaryActionKey)); // Done
    await tester.pumpAndSettle();
    expect(find.text('Step 1/5 · sets 1/5'), findsOneWidget);
    expect(find.text('Step completed.'), findsOneWidget);
    await tester.tap(find.byKey(GuidedSessionCard.nextKey));
    await tester.pumpAndSettle();

    // ── Krok 2/5 Push-up: 2 sady × 8 s pauzou 30 s.
    expect(find.text('Step 2/5 · sets 1/5'), findsOneWidget);
    expect(find.text('Set 1 of 2'), findsOneWidget);
    expect(find.text('rest 30 s'), findsOneWidget);
    expect(
      find.byKey(ExerciseIllustration.illustrationKey('PUSH_UP')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(GuidedSessionCard.primaryActionKey)); // Done
    await tester.pumpAndSettle();
    expect(find.text('Rest before the next set'), findsOneWidget);
    expect(find.text('0:30'), findsOneWidget);
    await advance(const Duration(seconds: 30));
    expect(find.text('Time is up'), findsOneWidget);
    await tester.tap(
      find.byKey(GuidedSessionCard.primaryActionKey),
    ); // Next set
    await tester.pumpAndSettle();
    expect(find.text('Set 2 of 2'), findsOneWidget);
    await tester.tap(find.byKey(GuidedSessionCard.primaryActionKey)); // Done
    await tester.pumpAndSettle();
    expect(find.text('Rest before the next set'), findsOneWidget);
    await advance(const Duration(seconds: 10));
    expect(find.text('0:20'), findsOneWidget);
    await tester.tap(find.byKey(GuidedSessionCard.primaryActionKey)); // dřív
    await tester.pumpAndSettle();
    expect(find.text('Step 2/5 · sets 3/5'), findsOneWidget);
    expect(find.text('Step completed.'), findsOneWidget);
    await tester.tap(find.byKey(GuidedSessionCard.nextKey));
    await tester.pumpAndSettle();

    // ── Krok 3/5 REST 15 s (bez výkonů).
    expect(find.text('Step 3/5 · sets 3/5'), findsOneWidget);
    expect(find.text('Start rest'), findsOneWidget);
    await tester.tap(find.byKey(GuidedSessionCard.primaryActionKey));
    await tester.pumpAndSettle();
    expect(find.text('0:15'), findsOneWidget);
    await advance(const Duration(seconds: 15));
    expect(find.text('Time is up'), findsOneWidget);
    await tester.tap(find.byKey(GuidedSessionCard.primaryActionKey)); // Next
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(GuidedSessionCard.nextKey));
    await tester.pumpAndSettle();

    // ── Krok 4/5 vlastní cvik s popisem, bez ilustrace → přeskočit.
    expect(find.text('Step 4/5 · sets 3/5'), findsOneWidget);
    expect(find.text('Farmářská chůze'), findsWidgets);
    expect(find.textContaining('Vezmi těžké činky'), findsOneWidget);
    expect(find.byType(ExerciseIllustration), findsNothing);
    await tester.tap(find.byKey(GuidedSessionCard.skipKey));
    await tester.pumpAndSettle();
    expect(find.text('Step skipped.'), findsOneWidget);
    await tester.tap(find.byKey(GuidedSessionCard.nextKey));
    await tester.pumpAndSettle();

    // ── Krok 5/5 Cat-cow 1×10 → Hotovo → vše hotovo.
    expect(find.text('Step 5/5 · sets 3/5'), findsOneWidget);
    expect(find.text('Cat-cow'), findsWidgets);
    await tester.tap(find.byKey(GuidedSessionCard.primaryActionKey)); // Done
    await tester.pumpAndSettle();
    expect(find.text('Step 5/5 · sets 4/5'), findsOneWidget);
    expect(
      find.text('All steps done — finish the workout below.'),
      findsOneWidget,
    );
    // Uplynulý aktivní čas = 12+8+30+10+15 = 75 s.
    expect(find.text('1:15'), findsOneWidget);

    // ── Dokončení (C22) se skutečnými výkony.
    await tester.dragUntilVisible(
      find.byKey(ActiveSessionScreen.completeButtonKey),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    await tester.tap(find.byKey(ActiveSessionScreen.completeButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(FeedbackConfirmDialog.confirmKey));
    await tester.pumpAndSettle();
    expect(find.byKey(HistoryScreen.screenKey), findsOneWidget);
    expect(find.text('Silový základ'), findsOneWidget);

    // ── Data: výkony poctivé, přeskočení zachováno, aktivní čas z časovačů.
    expect(
      await count(
        "SELECT COUNT(*) AS c FROM local_set_performances WHERE status = 'COMPLETED'",
      ),
      4,
    );
    expect(
      await count(
        "SELECT COUNT(*) AS c FROM local_set_performances WHERE status = 'SKIPPED'",
      ),
      1,
    );
    expect(
      await count(
        "SELECT COUNT(*) AS c FROM local_step_performances WHERE status = 'SKIPPED'",
      ),
      1,
    );
    expect(
      await count(
        "SELECT COUNT(*) AS c FROM local_step_performances WHERE status = 'COMPLETED'",
      ),
      3,
    );
    expect(
      await count(
        'SELECT COALESCE(SUM(actual_repetitions), 0) AS c FROM local_set_performances',
      ),
      8 + 8 + 10,
    );
    expect(
      await count(
        'SELECT COALESCE(SUM(actual_duration_seconds), 0) AS c FROM local_set_performances',
      ),
      20,
    );
    expect(
      await count(
        'SELECT elapsed_active_seconds AS c FROM local_workout_sessions',
      ),
      75,
    );
    expect(
      await count(
        'SELECT active_duration_seconds AS c FROM local_activity_summaries',
      ),
      75,
    );
    final statistics = await DriftActivityRepository(
      db,
    ).statisticsForPeriod(fromLocalDate: today, toLocalDate: today);
    expect(statistics.completedCount, 1);
    expect(chatClient.calls, 1);
    expect(proposalApi.calls, 1);
  });
}
