import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_read_model.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/workout_detail_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

void main() {
  Widget harness({
    required FakeSeedRepository seed,
    required FakeWorkoutInstanceRepository repository,
    required String workoutId,
  }) => ProviderScope(
    overrides: [
      r1SeedRepositoryProvider.overrideWithValue(seed),
      workoutInstanceRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: WorkoutDetailScreen(workoutId: workoutId),
    ),
  );

  FakeSeedRepository okSeed() => FakeSeedRepository([SeedResult.applied]);

  testWidgets('zobrazí snapshot workoutu a cviky ve správném pořadí', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        seed: okSeed(),
        repository: FakeWorkoutInstanceRepository(
          detailsById: {'wi1': buildDetail(id: 'wi1')},
        ),
        workoutId: 'wi1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(WorkoutDetailScreen.contentKey), findsOneWidget);
    expect(find.text('Goblet squat'), findsOneWidget);
    expect(find.text('Bench press'), findsOneWidget);

    // Cviky jsou v pořadí position (squat před press).
    final squatY = tester.getTopLeft(find.text('Goblet squat')).dy;
    final pressY = tester.getTopLeft(find.text('Bench press')).dy;
    expect(squatY, lessThan(pressY));
  });

  testWidgets('katalogový krok ukazuje název, popis provedení a cue z '
      'katalogu; vlastní bez popisu poctivě „bez popisu" (C51 §10)', (
    tester,
  ) async {
    final base = buildDetail(id: 'wi2');
    final detail = WorkoutInstanceDetail(
      id: base.id,
      title: base.title,
      workoutType: base.workoutType,
      scheduledLocalDate: base.scheduledLocalDate,
      status: base.status,
      revisionNumber: base.revisionNumber,
      sections: [
        WorkoutSection(
          id: 'wi2-main',
          position: 0,
          title: 'Main',
          sectionType: WorkoutSectionType.main,
          priority: WorkoutPriority.required,
          isOptional: false,
          steps: [
            WorkoutStep(
              id: 'wi2-plank',
              position: 0,
              stepType: WorkoutStepType.exercise,
              // Snapshot title se u katalogového kroku nezobrazuje —
              // zdroj pravdy je katalog (C51 §7).
              title: 'Prkno (snapshot)',
              exerciseCode: 'SIDE_PLANK',
              priority: WorkoutPriority.required,
              isSkippable: false,
              prescriptionType: StepPrescriptionType.duration,
              setPlans: const [
                WorkoutSetPlan(
                  id: 'sp0',
                  position: 0,
                  plannedDurationSeconds: 30,
                  restAfterSeconds: 20,
                ),
              ],
              childSteps: const [],
            ),
            WorkoutStep(
              id: 'wi2-custom',
              position: 1,
              stepType: WorkoutStepType.exercise,
              title: 'Můj cvik',
              priority: WorkoutPriority.required,
              isSkippable: false,
              prescriptionType: StepPrescriptionType.setRep,
              setPlans: const [],
              childSteps: const [],
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      harness(
        seed: okSeed(),
        repository: FakeWorkoutInstanceRepository(detailsById: {'wi2': detail}),
        workoutId: 'wi2',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Side plank'), findsOneWidget);
    expect(find.text('Prkno (snapshot)'), findsNothing);
    expect(find.textContaining('Lie on one side'), findsOneWidget);
    expect(find.text('Hips stacked, do not sag.'), findsOneWidget);
    expect(find.textContaining('Each side separately'), findsOneWidget);
    expect(find.textContaining('30 s'), findsOneWidget);
    expect(find.textContaining('rest 20 s'), findsOneWidget);
    // Vlastní cvik bez popisu (EXC-009).
    expect(find.text('Můj cvik'), findsOneWidget);
    expect(
      find.text('No description of how to perform this exercise.'),
      findsOneWidget,
    );
  });

  testWidgets('neexistující ID končí bezpečným not-found stavem', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        seed: okSeed(),
        repository: FakeWorkoutInstanceRepository(detailsById: const {}),
        workoutId: 'missing',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(WorkoutDetailScreen.notFoundKey), findsOneWidget);
    expect(find.byKey(WorkoutDetailScreen.contentKey), findsNothing);
  });

  testWidgets('prázdné ID je bezpečně zobrazeno jako not-found', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        seed: okSeed(),
        repository: FakeWorkoutInstanceRepository(detailsById: const {}),
        workoutId: '',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(WorkoutDetailScreen.notFoundKey), findsOneWidget);
  });

  testWidgets('error stav bez raw výjimky a se safe retry', (tester) async {
    await tester.pumpWidget(
      harness(
        seed: FakeSeedRepository([StateError('internal detail failure')]),
        repository: FakeWorkoutInstanceRepository(detailsById: const {}),
        workoutId: 'wi1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(WorkoutDetailScreen.errorKey), findsOneWidget);
    expect(find.byKey(WorkoutDetailScreen.retryKey), findsOneWidget);
    expect(find.textContaining('internal detail failure'), findsNothing);
    expect(find.textContaining('StateError'), findsNothing);
  });
}
