import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/today_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

void main() {
  Widget appWith({
    required R1SeedRepository seed,
    required FakeWorkoutInstanceRepository repository,
  }) => ProviderScope(
    overrides: [
      r1SeedRepositoryProvider.overrideWithValue(seed),
      workoutInstanceRepositoryProvider.overrideWithValue(repository),
    ],
    child: const AiTrainerApp(),
  );

  FakeSeedRepository okSeed() => FakeSeedRepository([SeedResult.applied]);

  testWidgets('loading stav se stabilním klíčem, UI nezamrzá', (tester) async {
    final hangingSeed = HangingSeedRepository();
    await tester.pumpWidget(
      appWith(seed: hangingSeed, repository: FakeWorkoutInstanceRepository()),
    );
    await tester.pump();

    expect(find.byKey(TodayScreen.loadingKey), findsOneWidget);

    // Dokončit seed, aby test neskončil s pending future.
    hangingSeed.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(TodayScreen.loadingKey), findsNothing);
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

    expect(find.byKey(TodayScreen.emptyKey), findsOneWidget);
    expect(find.byKey(TodayScreen.listKey), findsNothing);
    // Empty stav nesmí nabízet start/přidání workoutu (pozdější slice).
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('error stav s bezpečnou zprávou a retry, bez raw výjimky', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        seed: FakeSeedRepository([StateError('internal seed failure')]),
        repository: FakeWorkoutInstanceRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(TodayScreen.errorKey), findsOneWidget);
    expect(find.byKey(TodayScreen.retryKey), findsOneWidget);
    expect(find.textContaining('internal seed failure'), findsNothing);
    expect(find.textContaining('StateError'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('retry po error znovu spustí flow a zobrazí data', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        seed: FakeSeedRepository([StateError('boom'), SeedResult.applied]),
        repository: FakeWorkoutInstanceRepository(today: [buildSummary()]),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(TodayScreen.errorKey), findsOneWidget);

    await tester.tap(find.byKey(TodayScreen.retryKey));
    await tester.pumpAndSettle();

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

    // Název workoutu je vystaven jako sémantický label (karta merge-uje
    // title + subtitle do jednoho tap-able uzlu).
    expect(find.bySemanticsLabel(RegExp('Full Body Strength')), findsOneWidget);
    handle.dispose();
  });
}
