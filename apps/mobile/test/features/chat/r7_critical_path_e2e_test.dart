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
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/active_session_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/feedback_confirm_dialog.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/history_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/workout_detail_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// R7-06 – kritický E2E důkaz hlavní hodnoty R7 (plán §9.6, §13):
/// prázdná aplikace → **chat je domov** → profil potvrzenými akcemi
/// (C48) → plán chatem přes existující pipeline (C49) → potvrzení →
/// kalendář (C50) → quick-complete i plná session → statistiky.
/// Deterministicky: fake chat klient i fake proposal pipeline (CHP-010),
/// skutečná SQLite; jediná mutační cesta = potvrzené akce a C20–C22
/// operace (R7P-001/003).
class _ScriptedChatClient implements ChatAiClient {
  _ScriptedChatClient(this.replies);

  final List<String> replies;
  int calls = 0;

  @override
  Future<String> chat({
    required List<ChatTurn> turns,
    required Map<String, Object?> profileContext,
  }) async {
    // Kontext je minimalizovaný C27 base (bez ID a poznámek) — marker.
    if (profileContext.toString().contains('note')) {
      throw StateError('PII v kontextu');
    }
    return replies[calls++ < replies.length ? calls - 1 : replies.length - 1];
  }
}

class _ScriptedProposalApi implements AiApiClient {
  int calls = 0;

  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required Map<String, Object?> context,
    String requestType = 'PLAN_PROPOSAL',
  }) async {
    calls++;
    return PlanProposalResponse(
      proposal: {
        'summary': 'Týden podle florbalu a hubnutí.',
        'planTitle': 'Chat týden',
        'workouts': [
          {
            'title': 'Silový A',
            'workoutType': 'STRENGTH',
            'dayOffset': 0,
            'reason': 'Základ síly pro florbal.',
            'exercises': [
              {'title': 'Dřep', 'sets': 1, 'repetitions': 8},
            ],
          },
          {
            'title': 'Mobilita B',
            'workoutType': 'MOBILITY',
            'dayOffset': 1,
            'reason': 'Regenerace kolene.',
          },
        ],
      },
      promptVersion: 'plan-proposal-v2',
      schemaVersion: 'plan-proposal-schema-v1',
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
  String newId() => 'r7-id-${_next++}';
}

void main() {
  final now = DateTime.utc(2026, 8, 15, 12);
  final today = formatLocalDate(now);
  final tomorrow = formatLocalDate(now.add(const Duration(days: 1)));

  testWidgets('R7 E2E: chat domov → profil akcemi → plán chatem → kalendář '
      '→ quick-complete i plná session → statistiky', (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final chatClient = _ScriptedChatClient([
      // 1. tah: profilové akce (C48).
      '{"reply":"Zapsal jsem si florbal, cíl, úterky a koleno — potvrď.",'
          '"actions":['
          '{"action":"UPSERT_SPORT","customName":"Florbal","role":"PRIMARY",'
          '"priority":"HIGH","frequencyPerWeek":2},'
          '{"action":"ADD_GOAL","title":"Zhubnout 5 kg","goalType":"HABIT",'
          '"priority":"PRIMARY"},'
          '{"action":"SET_AVAILABILITY","dayOfWeek":"TUE","level":"AVAILABLE",'
          '"budgetMinutes":90},'
          '{"action":"ADD_CONSTRAINT","title":"Citlivé koleno"}]}',
      // 2. tah: žádost o plán (C49).
      '{"reply":"Připravím ti týden — návrh potvrď níže.",'
          '"actions":[{"action":"REQUEST_PLAN"}]}',
    ]);
    final proposalApi = _ScriptedProposalApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          // Prázdná aplikace — bez R1 demo seedu.
          r1SeedRepositoryProvider.overrideWithValue(
            FakeSeedRepository([SeedResult.applied]),
          ),
          clockProvider.overrideWithValue(() => now),
          idGeneratorProvider.overrideWithValue(_Ids()),
          chatAiClientProvider.overrideWithValue(chatClient),
          aiApiClientProvider.overrideWithValue(proposalApi),
          byokKeyStoreProvider.overrideWithValue(_KeyStore()),
        ],
        child: const AiTrainerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // ── Chat je domov (CQC-009) s prázdným poctivým stavem.
    expect(find.byKey(ChatScreen.screenKey), findsOneWidget);
    expect(find.byKey(ChatScreen.emptyKey), findsOneWidget);

    // ── Profil chatem: akce → potvrzení všech čtyř (CHA-005/006).
    await tester.enterText(
      find.byKey(ChatScreen.inputKey),
      'Hraju florbal 2× týdně, chci zhubnout, mám čas v úterý a bolí mě '
      'koleno.',
    );
    await tester.tap(find.byKey(ChatScreen.sendButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('Confirm'), findsNWidgets(4));
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Confirm').first);
      await tester.pumpAndSettle();
    }
    expect(find.text('Applied to your profile.'), findsNWidgets(4));

    Future<int> count(String sql) async =>
        (await db.customSelect(sql).getSingle()).data.values.first as int;
    expect(await count('SELECT COUNT(*) AS c FROM local_user_sports'), 1);
    expect(await count('SELECT COUNT(*) AS c FROM local_goals'), 1);
    expect(
      await count('SELECT COUNT(*) AS c FROM local_availability_rules'),
      1,
    );
    expect(await count('SELECT COUNT(*) AS c FROM local_constraints'), 1);

    // ── Plán chatem (C49): REQUEST_PLAN → karta návrhu → potvrzení →
    // provedení C30 (před potvrzením žádný plán, CHP-004).
    await tester.enterText(find.byKey(ChatScreen.inputKey), 'Postav mi týden.');
    await tester.tap(find.byKey(ChatScreen.sendButtonKey));
    await tester.pumpAndSettle();
    expect(proposalApi.calls, 1);
    expect(find.text('Chat týden'), findsOneWidget);
    expect(await count('SELECT COUNT(*) AS c FROM local_training_plans'), 0);
    await tester.tap(find.text('Accept proposal'));
    await tester.pumpAndSettle();
    expect(await count('SELECT COUNT(*) AS c FROM local_training_plans'), 1);
    expect(await count('SELECT COUNT(*) AS c FROM local_workout_instances'), 2);

    // ── Kalendář (C50): dnešek → quick-complete „Silový A" poctivě.
    await tester.tap(find.byIcon(Icons.calendar_month_outlined).first);
    await tester.pumpAndSettle();
    expect(find.byKey(CalendarScreen.screenKey), findsOneWidget);
    await tester.tap(find.byKey(CalendarScreen.dayKey(today)));
    await tester.pumpAndSettle();
    expect(find.text('Silový A'), findsOneWidget);
    await tester.tap(find.text('Mark done'));
    await tester.pumpAndSettle();
    expect(find.textContaining('no measured steps'), findsOneWidget);
    expect(
      await count('SELECT COUNT(*) AS c FROM local_activity_summaries'),
      1,
    );
    expect(await count('SELECT COUNT(*) AS c FROM local_step_performances'), 0);

    // ── Plná session na druhém workoutu (R1 flow z kalendáře).
    await tester.tap(find.byKey(CalendarScreen.dayKey(tomorrow)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mobilita B'));
    await tester.pumpAndSettle();
    expect(find.byKey(WorkoutDetailScreen.screenKey), findsOneWidget);
    await tester.tap(find.byKey(WorkoutDetailScreen.startButtonKey));
    await tester.pumpAndSettle();
    expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);
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

    // ── Statistiky (C23) drží obě dokončení; žádné vymyšlené metriky.
    final statistics = await DriftActivityRepository(
      db,
    ).statisticsForPeriod(fromLocalDate: today, toLocalDate: tomorrow);
    expect(statistics.completedCount, 2);
    expect(
      await count('SELECT COUNT(*) AS c FROM local_activity_summaries'),
      2,
    );
    // Chat volání bounded: 2 uživatelská zadání ⇒ 2 chat + 1 pipeline
    // volání (CHP-006).
    expect(chatClient.calls, 2);
    expect(proposalApi.calls, 1);
  });
}
