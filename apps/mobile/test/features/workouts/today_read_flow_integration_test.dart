import 'package:ai_trainer_mobile/features/workouts/application/today_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_detail_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// End-to-end read flow nad skutečnou SQLite (bez sítě, QTR-004): bootstrap
/// seed → Today read model → detail. Doplňuje R1-01 persistence testy.
void main() {
  test('bootstrap seed se promítne do Today read modelu a detailu', () async {
    final container = createWorkoutContainer(
      database: createTestDatabase(),
      now: DateTime(2026, 7, 20, 8),
    );

    final today = await container.read(todayWorkoutsProvider.future);
    expect(today, hasLength(1));
    expect(today.single.id, 'demo-w1-instance');
    expect(today.single.title, 'Full Body Strength (Demo)');

    final detail = await container.read(
      workoutDetailProvider('demo-w1-instance').future,
    );
    expect(detail, isNotNull);
    expect(detail!.sections, hasLength(3));
    expect(detail.sections[1].steps.first.title, 'Goblet squat');
    expect(detail.sections[1].steps.first.setPlans, hasLength(3));
  });

  test(
    'opakované čtení Today read modelu je stabilní (idempotentní seed)',
    () async {
      final container = createWorkoutContainer(
        database: createTestDatabase(),
        now: DateTime(2026, 7, 20, 8),
      );

      final first = await container.read(todayWorkoutsProvider.future);
      container.invalidate(todayWorkoutsProvider);
      final second = await container.read(todayWorkoutsProvider.future);

      expect(first.map((w) => w.id), second.map((w) => w.id));
      expect(second, hasLength(1));
    },
  );
}
