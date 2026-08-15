import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/app/navigation/app_routes.dart';
import 'package:ai_trainer_mobile/app/startup/recovery_gate_screen.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/features/chat/presentation/chat_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/today_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_workout_repositories.dart';
import '../../support/workout_test_scope.dart';

void main() {
  // Startup recovery gate (R1-05) je initial route. Bez aktivní session
  // recovery vyhodnotí NoActiveSession a přejde na domov (chat, CQC-009);
  // Today zůstává plnohodnotný a testuje se navigací z domova.
  Widget appWith({
    required R1SeedRepository seed,
    required FakeWorkoutInstanceRepository repository,
  }) {
    final db = createTestDatabase();
    addTearDown(db.close);
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        r1SeedRepositoryProvider.overrideWithValue(seed),
        workoutInstanceRepositoryProvider.overrideWithValue(repository),
        workoutSessionRepositoryProvider.overrideWithValue(
          FakeWorkoutSessionRepository(),
        ),
        workoutPerformanceRepositoryProvider.overrideWithValue(
          FakeWorkoutPerformanceRepository(),
        ),
      ],
      child: const AiTrainerApp(),
    );
  }

  FakeSeedRepository okSeed() => FakeSeedRepository([SeedResult.applied]);

  Future<void> goToday(WidgetTester tester) async {
    final home = tester.element(find.byKey(ChatScreen.screenKey));
    GoRouter.of(home).go(AppRoutes.todayPath);
    await tester.pumpAndSettle();
  }

  testWidgets('startup recovery loading stav, UI nezamrzá', (tester) async {
    final hangingSeed = HangingSeedRepository();
    await tester.pumpWidget(
      appWith(seed: hangingSeed, repository: FakeWorkoutInstanceRepository()),
    );
    await tester.pump();

    // Startup recovery gate (R1-05) je initial route; dokud bootstrap běží,
    // zobrazuje konečný recovery loading, nikoli krátce domov.
    expect(find.byKey(RecoveryGateScreen.loadingKey), findsOneWidget);
    expect(find.byKey(ChatScreen.screenKey), findsNothing);

    // Dokončit seed → recovery vyhodnotí NoActiveSession → domov → Today.
    hangingSeed.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(RecoveryGateScreen.loadingKey), findsNothing);
    await goToday(tester);
    expect(find.byKey(TodayScreen.emptyKey), findsOneWidget);
  });

  testWidgets('data stav zobrazí dnešní workout jako kartu', (tester) async {
    await tester.pumpWidget(
      appWith(
        seed: okSeed(),
        repository: FakeWorkoutInstanceRepository(
          today: [buildSummary(title: 'Full Body Strength')],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await goToday(tester);

    expect(find.byKey(TodayScreen.listKey), findsOneWidget);
    expect(find.byKey(TodayScreen.cardKey('wi1')), findsOneWidget);
    expect(find.text('Full Body Strength'), findsOneWidget);
  });

  testWidgets('empty stav pravdivě, bez akce pozdějšího slice', (tester) async {
    await tester.pumpWidget(
      appWith(
        seed: okSeed(),
        repository: FakeWorkoutInstanceRepository(today: const []),
      ),
    );
    await tester.pumpAndSettle();
    await goToday(tester);

    expect(find.byKey(TodayScreen.emptyKey), findsOneWidget);
    expect(find.byKey(TodayScreen.listKey), findsNothing);
    // Empty stav nesmí nabízet start/přidání workoutu (pozdější slice).
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets(
    'bootstrap selhání vede na bezpečný gate fallback, bez raw výjimky',
    (tester) async {
      await tester.pumpWidget(
        appWith(
          seed: FakeSeedRepository([StateError('internal seed failure')]),
          repository: FakeWorkoutInstanceRepository(),
        ),
      );
      await tester.pumpAndSettle();

      // Selhání otevření/seedu DB zachytí startup recovery gate (R1-05),
      // ne domov — bezpečná zpráva + Retry, žádný raw detail.
      expect(find.byKey(RecoveryGateScreen.fallbackKey), findsOneWidget);
      expect(find.byKey(RecoveryGateScreen.retryButtonKey), findsOneWidget);
      expect(find.byKey(ChatScreen.screenKey), findsNothing);
      expect(find.textContaining('internal seed failure'), findsNothing);
      expect(find.textContaining('StateError'), findsNothing);
      expect(find.textContaining('Exception'), findsNothing);
    },
  );

  testWidgets('Retry po bootstrap selhání znovu spustí flow a zobrazí Today', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        seed: FakeSeedRepository([StateError('boom'), SeedResult.applied]),
        repository: FakeWorkoutInstanceRepository(today: [buildSummary()]),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(RecoveryGateScreen.fallbackKey), findsOneWidget);

    await tester.tap(find.byKey(RecoveryGateScreen.retryButtonKey));
    await tester.pumpAndSettle();

    // Recovery vyhodnotí NoActiveSession → domov → Today s daty.
    await goToday(tester);
    expect(find.byKey(TodayScreen.listKey), findsOneWidget);
  });

  testWidgets('navigace z Today na detail workoutu', (tester) async {
    await tester.pumpWidget(
      appWith(
        seed: okSeed(),
        repository: FakeWorkoutInstanceRepository(
          today: [buildSummary(id: 'wi1')],
          detailsById: {'wi1': buildDetail(id: 'wi1')},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await goToday(tester);

    await tester.tap(find.byKey(TodayScreen.cardKey('wi1')));
    await tester.pumpAndSettle();

    expect(find.byKey(WorkoutDetailScreen.screenKey), findsOneWidget);
    expect(find.byKey(WorkoutDetailScreen.contentKey), findsOneWidget);
  });

  testWidgets('hlavní stavy mají čitelný accessibility význam', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      appWith(
        seed: okSeed(),
        repository: FakeWorkoutInstanceRepository(
          today: [buildSummary(title: 'Full Body Strength')],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await goToday(tester);

    // Název workoutu je vystaven jako sémantický label (karta merge-uje
    // title + subtitle do jednoho tap-able uzlu).
    expect(find.bySemanticsLabel(RegExp('Full Body Strength')), findsOneWidget);
    handle.dispose();
  });
}
