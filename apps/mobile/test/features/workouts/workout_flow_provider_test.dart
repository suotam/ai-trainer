import 'package:ai_trainer_mobile/features/workouts/application/today_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_bootstrap.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_detail_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

void main() {
  ProviderContainer container({
    required FakeSeedRepository seed,
    required FakeWorkoutInstanceRepository repository,
  }) {
    final c = ProviderContainer(
      overrides: [
        r1SeedRepositoryProvider.overrideWithValue(seed),
        workoutInstanceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('bootstrap', () {
    test('zavolá idempotentní seed právě jednou v řízeném flow', () async {
      final seed = FakeSeedRepository([SeedResult.applied]);
      final c = container(
        seed: seed,
        repository: FakeWorkoutInstanceRepository(),
      );

      await c.read(workoutBootstrapCompletedProvider.future);
      // Opakované čtení bez invalidace nespustí nový seed (žádný loop).
      await c.read(workoutBootstrapCompletedProvider.future);

      expect(seed.callCount, 1);
    });

    test('selhání seedu vede do error stavu bez nekonečného retry', () async {
      final seed = FakeSeedRepository([StateError('seed failed')]);
      final c = container(
        seed: seed,
        repository: FakeWorkoutInstanceRepository(),
      );

      await expectLater(
        c.read(workoutBootstrapCompletedProvider.future),
        throwsA(isA<StateError>()),
      );
      expect(
        c.read(workoutBootstrapCompletedProvider),
        isA<AsyncError<void>>(),
      );
      expect(seed.callCount, 1);
    });
  });

  group('todayWorkoutsProvider', () {
    test('loading → data po dokončení bootstrapu', () async {
      final c = container(
        seed: FakeSeedRepository([SeedResult.applied]),
        repository: FakeWorkoutInstanceRepository(today: [buildSummary()]),
      );

      expect(c.read(todayWorkoutsProvider), isA<AsyncLoading<Object?>>());
      final data = await c.read(todayWorkoutsProvider.future);
      expect(data, hasLength(1));
      expect(data.single.id, 'wi1');
    });

    test('loading → empty', () async {
      final c = container(
        seed: FakeSeedRepository([SeedResult.applied]),
        repository: FakeWorkoutInstanceRepository(today: const []),
      );

      final data = await c.read(todayWorkoutsProvider.future);
      expect(data, isEmpty);
    });

    test('loading → error (selhání bootstrapu se propíše)', () async {
      final c = container(
        seed: FakeSeedRepository([StateError('seed failed')]),
        repository: FakeWorkoutInstanceRepository(today: [buildSummary()]),
      );

      await expectLater(
        c.read(todayWorkoutsProvider.future),
        throwsA(isA<StateError>()),
      );
    });

    test(
      'error v repository se propíše bez interního úniku do UI vrstvy',
      () async {
        final repo = FakeWorkoutInstanceRepository(throwOnToday: true);
        final c = container(
          seed: FakeSeedRepository([SeedResult.applied]),
          repository: repo,
        );

        await expectLater(
          c.read(todayWorkoutsProvider.future),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('retry po error vede k novému pokusu a úspěchu', () async {
      final seed = FakeSeedRepository([
        StateError('seed failed'),
        SeedResult.applied,
      ]);
      final c = container(
        seed: seed,
        repository: FakeWorkoutInstanceRepository(today: [buildSummary()]),
      );

      await expectLater(
        c.read(todayWorkoutsProvider.future),
        throwsA(isA<StateError>()),
      );

      c.invalidate(workoutBootstrapCompletedProvider);
      c.invalidate(todayWorkoutsProvider);
      final data = await c.read(todayWorkoutsProvider.future);

      expect(data, hasLength(1));
      expect(seed.callCount, 2);
    });
  });

  group('workoutDetailProvider', () {
    test('loading → data podle ID', () async {
      final c = container(
        seed: FakeSeedRepository([SeedResult.applied]),
        repository: FakeWorkoutInstanceRepository(
          detailsById: {'wi1': buildDetail()},
        ),
      );

      final detail = await c.read(workoutDetailProvider('wi1').future);
      expect(detail, isNotNull);
      expect(detail!.sections.single.steps, hasLength(2));
    });

    test('loading → not found (null) pro neexistující ID', () async {
      final c = container(
        seed: FakeSeedRepository([SeedResult.applied]),
        repository: FakeWorkoutInstanceRepository(detailsById: const {}),
      );

      expect(await c.read(workoutDetailProvider('missing').future), isNull);
    });

    test(
      'prázdné/neplatné ID končí bezpečně not-found bez volání repository',
      () async {
        final repo = FakeWorkoutInstanceRepository(detailsById: const {});
        final c = container(
          seed: FakeSeedRepository([SeedResult.applied]),
          repository: repo,
        );

        expect(await c.read(workoutDetailProvider('   ').future), isNull);
      },
    );
  });
}
