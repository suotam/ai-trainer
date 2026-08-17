/// Doménové read modely workout snapshotu pro R1 (PDR-002, PDR-008).
///
/// Nejsou to Drift row typy ani transportní DTO — vznikají výhradně přes
/// mappery v data vrstvě. Enum kódy odpovídají
/// `docs/12-data/r1-physical-data-model.md`; neznámý kód je chyba dat,
/// nikoli tichý default.
library;

enum WorkoutInstanceStatus {
  ready('READY'),
  inProgress('IN_PROGRESS'),
  paused('PAUSED'),
  completed('COMPLETED'),
  partiallyCompleted('PARTIALLY_COMPLETED'),
  skipped('SKIPPED'),
  cancelled('CANCELLED');

  const WorkoutInstanceStatus(this.code);
  final String code;
}

enum WorkoutSectionType {
  warmUp('WARM_UP'),
  main('MAIN'),
  cooldown('COOLDOWN');

  const WorkoutSectionType(this.code);
  final String code;
}

enum WorkoutStepType {
  exercise('EXERCISE'),
  duration('DURATION'),
  rest('REST'),
  mobilityPosition('MOBILITY_POSITION'),
  instruction('INSTRUCTION'),
  custom('CUSTOM');

  const WorkoutStepType(this.code);
  final String code;
}

enum StepPrescriptionType {
  setRep('SET_REP'),
  duration('DURATION'),
  completionOnly('COMPLETION_ONLY');

  const StepPrescriptionType(this.code);
  final String code;
}

enum WorkoutPriority {
  required('REQUIRED'),
  high('HIGH'),
  normal('NORMAL'),
  optional('OPTIONAL');

  const WorkoutPriority(this.code);
  final String code;
}

/// Chyba mapování persistence dat na doménu — nepodporovaná nebo poškozená
/// hodnota (fyzický model §16: mapper odmítne neznámou variantu).
class UnsupportedPersistedValue implements Exception {
  UnsupportedPersistedValue(this.field, this.value);

  final String field;
  final Object? value;

  @override
  String toString() =>
      'UnsupportedPersistedValue(field: $field, value: $value)';
}

class WorkoutSetPlan {
  const WorkoutSetPlan({
    required this.id,
    required this.position,
    this.plannedRepetitions,
    this.minimumRepetitions,
    this.maximumRepetitions,
    this.plannedWeightKg,
    this.plannedDurationSeconds,
    this.restAfterSeconds,
    this.targetRpe,
  });

  final String id;
  final int position;
  final int? plannedRepetitions;
  final int? minimumRepetitions;
  final int? maximumRepetitions;
  final double? plannedWeightKg;
  final int? plannedDurationSeconds;
  final int? restAfterSeconds;
  final double? targetRpe;
}

class WorkoutStep {
  const WorkoutStep({
    required this.id,
    required this.position,
    required this.stepType,
    required this.title,
    required this.priority,
    required this.isSkippable,
    required this.prescriptionType,
    required this.setPlans,
    required this.childSteps,
    this.instructions,
    this.purpose,
    this.plannedDurationSeconds,
    this.plannedDistanceMeters,
    this.plannedRepetitions,
    this.plannedWeightKg,
    this.exerciseCode,
  });

  final String id;
  final int position;
  final WorkoutStepType stepType;
  final String title;
  final WorkoutPriority priority;
  final bool isSkippable;
  final StepPrescriptionType prescriptionType;

  /// Vazba na katalog cviků C51 (`null` = vlastní cvik / krok bez cviku).
  final String? exerciseCode;
  final String? instructions;
  final String? purpose;
  final int? plannedDurationSeconds;
  final double? plannedDistanceMeters;
  final int? plannedRepetitions;
  final double? plannedWeightKg;
  final List<WorkoutSetPlan> setPlans;

  /// R1 podporuje maximálně jednu úroveň vnoření (fyzický model §7).
  final List<WorkoutStep> childSteps;
}

class WorkoutSection {
  const WorkoutSection({
    required this.id,
    required this.position,
    required this.title,
    required this.sectionType,
    required this.priority,
    required this.isOptional,
    required this.steps,
    this.purpose,
    this.plannedDurationSeconds,
  });

  final String id;
  final int position;
  final String title;
  final WorkoutSectionType sectionType;
  final WorkoutPriority priority;
  final bool isOptional;
  final String? purpose;
  final int? plannedDurationSeconds;
  final List<WorkoutStep> steps;
}

/// Přehledová položka pro Today a týdenní dotazy — bez plné struktury.
class WorkoutInstanceSummary {
  const WorkoutInstanceSummary({
    required this.id,
    required this.title,
    required this.workoutType,
    required this.scheduledLocalDate,
    required this.status,
    this.description,
    this.plannedDurationSeconds,
  });

  final String id;
  final String title;
  final String workoutType;

  /// Lokální datum `YYYY-MM-DD` (fyzický model §4).
  final String scheduledLocalDate;
  final WorkoutInstanceStatus status;
  final String? description;
  final int? plannedDurationSeconds;
}

/// Kompletní stabilní snapshot jedné instance (PDR-002, PDR-011).
class WorkoutInstanceDetail {
  const WorkoutInstanceDetail({
    required this.id,
    required this.title,
    required this.workoutType,
    required this.scheduledLocalDate,
    required this.status,
    required this.revisionNumber,
    required this.sections,
    this.description,
    this.purpose,
    this.plannedDurationSeconds,
  });

  final String id;
  final String title;
  final String workoutType;
  final String scheduledLocalDate;
  final WorkoutInstanceStatus status;
  final int revisionNumber;
  final String? description;
  final String? purpose;
  final int? plannedDurationSeconds;
  final List<WorkoutSection> sections;
}
