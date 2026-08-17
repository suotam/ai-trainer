/// Mapping Drift řádků na doménové read modely (fyzický model §16).
///
/// Mapper odmítá neznámé enum kódy — žádné tiché defaulty, které by měnily
/// doménový význam. Drift typy tento soubor neopouštějí (PDR-008).
library;

import '../../../core/database/app_database.dart';
import '../domain/exercise_catalog.dart';
import '../domain/workout_read_model.dart';

T _decode<T extends Enum>(
  String field,
  String code,
  List<T> values,
  String Function(T) codeOf,
) {
  for (final value in values) {
    if (codeOf(value) == code) {
      return value;
    }
  }
  throw UnsupportedPersistedValue(field, code);
}

WorkoutInstanceStatus decodeInstanceStatus(String code) => _decode(
  'local_workout_instances.status',
  code,
  WorkoutInstanceStatus.values,
  (v) => v.code,
);

WorkoutSectionType decodeSectionType(String code) => _decode(
  'local_workout_sections.section_type',
  code,
  WorkoutSectionType.values,
  (v) => v.code,
);

WorkoutStepType decodeStepType(String code) => _decode(
  'local_workout_steps.step_type',
  code,
  WorkoutStepType.values,
  (v) => v.code,
);

StepPrescriptionType decodePrescriptionType(String code) => _decode(
  'local_workout_steps.prescription_type',
  code,
  StepPrescriptionType.values,
  (v) => v.code,
);

WorkoutPriority decodePriority(String field, String code) =>
    _decode(field, code, WorkoutPriority.values, (v) => v.code);

/// Vazba kroku na katalog C51: neznámý persistovaný kód je typovaná chyba
/// čtení, ne tichý default (EXC-011); `deprecated` položky se čtou.
String? decodeExerciseCode(String? code) {
  if (code == null) {
    return null;
  }
  if (!isKnownExerciseCode(code)) {
    throw UnsupportedPersistedValue('local_workout_steps.exercise_code', code);
  }
  return code;
}

WorkoutInstanceSummary mapInstanceSummary(LocalWorkoutInstanceRow row) =>
    WorkoutInstanceSummary(
      id: row.id,
      title: row.title,
      workoutType: row.workoutType,
      scheduledLocalDate: row.scheduledLocalDate,
      status: decodeInstanceStatus(row.status),
      description: row.description,
      plannedDurationSeconds: row.plannedDurationSeconds,
    );

WorkoutSetPlan mapSetPlan(LocalSetPlanRow row) => WorkoutSetPlan(
  id: row.id,
  position: row.position,
  plannedRepetitions: row.plannedRepetitions,
  minimumRepetitions: row.minimumRepetitions,
  maximumRepetitions: row.maximumRepetitions,
  plannedWeightKg: row.plannedWeightKg,
  plannedDurationSeconds: row.plannedDurationSeconds,
  restAfterSeconds: row.restAfterSeconds,
  targetRpe: row.targetRpe,
);

WorkoutStep mapStep(
  LocalWorkoutStepRow row, {
  required List<WorkoutSetPlan> setPlans,
  required List<WorkoutStep> childSteps,
}) => WorkoutStep(
  id: row.id,
  position: row.position,
  stepType: decodeStepType(row.stepType),
  title: row.title,
  priority: decodePriority('local_workout_steps.priority', row.priority),
  isSkippable: row.isSkippable,
  prescriptionType: decodePrescriptionType(row.prescriptionType),
  exerciseCode: decodeExerciseCode(row.exerciseCode),
  instructions: row.instructions,
  purpose: row.purpose,
  plannedDurationSeconds: row.plannedDurationSeconds,
  plannedDistanceMeters: row.plannedDistanceMeters,
  plannedRepetitions: row.plannedRepetitions,
  plannedWeightKg: row.plannedWeightKg,
  setPlans: setPlans,
  childSteps: childSteps,
);

WorkoutSection mapSection(
  LocalWorkoutSectionRow row, {
  required List<WorkoutStep> steps,
}) => WorkoutSection(
  id: row.id,
  position: row.position,
  title: row.title,
  sectionType: decodeSectionType(row.sectionType),
  priority: decodePriority('local_workout_sections.priority', row.priority),
  isOptional: row.isOptional,
  purpose: row.purpose,
  plannedDurationSeconds: row.plannedDurationSeconds,
  steps: steps,
);

WorkoutInstanceDetail mapInstanceDetail(
  LocalWorkoutInstanceRow row, {
  required List<WorkoutSection> sections,
}) => WorkoutInstanceDetail(
  id: row.id,
  title: row.title,
  workoutType: row.workoutType,
  scheduledLocalDate: row.scheduledLocalDate,
  status: decodeInstanceStatus(row.status),
  revisionNumber: row.revisionNumber,
  description: row.description,
  purpose: row.purpose,
  plannedDurationSeconds: row.plannedDurationSeconds,
  sections: sections,
);
