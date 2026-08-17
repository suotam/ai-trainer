import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_ai_proposal_repository.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_proposal_executor.dart';
import 'package:ai_trainer_mobile/features/ai/data/plan_proposal_v2_validator.dart';
import 'package:ai_trainer_mobile/features/ai/domain/ai_proposal.dart';
import 'package:ai_trainer_mobile/features/ai/domain/proposal_executor.dart';
import 'package:ai_trainer_mobile/features/availability/data/drift_availability_profile_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/data/drift_daily_check_in_repository.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_calendar_operations_repository.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_instance_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_read_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';
import 'plan_proposal_v2_validator_test.dart' show validPlan;

/// R8-02 provedení plánu v2 (C52 §5, PS2-002/010/012): kanonický v2 payload
/// → existující fyzický model 1:1 (sekce WARM_UP/MAIN/COOLDOWN, EXERCISE s
/// exercise_code / vlastní s popisem, REST krok, set plany s časem, pauzou,
/// váhou); read model detailu to celé vrací; koexistence s v1 payloadem.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 8, 16, 12);

  DriftProposalExecutor buildExecutor(AppDatabase db) => DriftProposalExecutor(
    db,
    DriftTrainingPlanRepository(db),
    DriftAiProposalRepository(db),
    DriftCalendarOperationsRepository(db),
    DriftWorkoutInstanceRepository(db),
    DriftDailyCheckInRepository(db),
    DriftAvailabilityProfileRepository(db),
  );

  String Function() counterIds(String prefix) {
    var next = 0;
    return () => '$prefix-${next++}';
  }

  test('v2 návrh → sekce, kroky (katalog/vlastní/REST), set plany s časem a '
      'pauzou; detail read model vrací strukturu (PS2-002/010)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final proposals = DriftAiProposalRepository(db);
    final canonical = validatePlanProposalV2Payload(validPlan())!;
    await proposals.saveProposed(
      id: 'p-v2',
      requestType: 'PLAN_PROPOSAL',
      canonicalPayload: canonical,
      summary: 's',
      promptVersion: 'plan-proposal-v3',
      schemaVersion: 'plan-proposal-schema-v2',
      modelId: 'fake-model',
      now: now,
    );
    expect(
      await proposals.decide('p-v2', ProposalDecision.confirm, now: now),
      isA<DecisionSaved>(),
    );
    final result = await buildExecutor(
      db,
    ).execute('p-v2', newId: counterIds('x'), now: now);
    expect(result, isA<ExecutionSaved>());

    // Dva workouty (den 0 a 2), každý 3 sekce v pořadí.
    final instances = await db
        .customSelect(
          'SELECT id, scheduled_local_date FROM local_workout_instances '
          'ORDER BY scheduled_local_date',
        )
        .get();
    expect(instances, hasLength(2));
    final firstId = instances.first.data['id'] as String;
    final detail = await DriftWorkoutInstanceRepository(
      db,
    ).workoutInstanceById(firstId);
    expect(detail, isNotNull);
    final sections = detail!.sections;
    expect(sections.map((s) => s.sectionType).toList(), [
      WorkoutSectionType.warmUp,
      WorkoutSectionType.main,
      WorkoutSectionType.cooldown,
    ]);
    expect(sections[1].title, 'Hlavní část');
    expect(sections[0].title, 'Warm-up');

    final main = sections[1].steps;
    expect(main, hasLength(4));
    // Katalogový DURATION krok s pauzami.
    expect(main[0].exerciseCode, 'HANGBOARD_MAX_HANG');
    expect(main[0].stepType, WorkoutStepType.exercise);
    expect(main[0].prescriptionType, StepPrescriptionType.duration);
    expect(main[0].title, 'Hangboard max hang');
    expect(main[0].setPlans, hasLength(2));
    expect(main[0].setPlans.first.plannedDurationSeconds, 10);
    expect(main[0].setPlans.first.restAfterSeconds, 180);
    expect(main[0].setPlans.first.plannedRepetitions, isNull);
    // REST krok.
    expect(main[1].stepType, WorkoutStepType.rest);
    expect(main[1].plannedDurationSeconds, 120);
    expect(main[1].isSkippable, isTrue);
    expect(main[1].setPlans, isEmpty);
    // Vlastní cvik s popisem.
    expect(main[2].exerciseCode, isNull);
    expect(main[2].title, 'Kampus lehce');
    expect(main[2].instructions, contains('stupačkách'));
    expect(main[2].setPlans.single.plannedRepetitions, 5);
    expect(main[2].setPlans.single.restAfterSeconds, 90);
    // Katalogový SET_REP s váhou.
    expect(main[3].exerciseCode, 'RING_DIP');
    expect(main[3].setPlans.single.plannedWeightKg, 0);
    // Rozcvička: note → purpose.
    expect(sections[0].steps[1].purpose, 'Pomalu.');
    expect(sections[0].steps[0].setPlans.single.plannedDurationSeconds, 60);
    // Vyklidnění.
    expect(sections[2].steps.single.exerciseCode, 'FOREARM_MASSAGE');
  });

  test('koexistence: uložený v1 payload (exercises) se provede dosavadní '
      'cestou — jedna sekce MAIN, SET_REP (PS2-012)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final proposals = DriftAiProposalRepository(db);
    await proposals.saveProposed(
      id: 'p-v1',
      requestType: 'PLAN_PROPOSAL',
      canonicalPayload: const {
        'summary': 's',
        'planTitle': 'v1',
        'workouts': [
          {
            'title': 'Full Body A',
            'workoutType': 'STRENGTH',
            'dayOffset': 0,
            'reason': 'r',
            'exercises': [
              {'title': 'Dřep', 'sets': 2, 'repetitions': 8},
            ],
          },
        ],
      },
      summary: 's',
      promptVersion: 'plan-proposal-v2',
      schemaVersion: 'plan-proposal-schema-v1',
      modelId: 'fake-model',
      now: now,
    );
    await proposals.decide('p-v1', ProposalDecision.confirm, now: now);
    final result = await buildExecutor(
      db,
    ).execute('p-v1', newId: counterIds('y'), now: now);
    expect(result, isA<ExecutionSaved>());
    final steps = await db
        .customSelect(
          'SELECT st.title, st.exercise_code, sec.section_type FROM '
          'local_workout_steps st JOIN local_workout_sections sec '
          'ON st.section_id = sec.id',
        )
        .get();
    expect(steps, hasLength(1));
    expect(steps.single.data['title'], 'Dřep');
    expect(steps.single.data['exercise_code'], isNull);
    expect(steps.single.data['section_type'], 'MAIN');
  });
}
