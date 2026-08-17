import 'package:flutter/foundation.dart';

/// Ruční tréninkový plán — P0 podmnožina dle C20.
///
/// Plán je záměr; konkrétní workout je existující `WorkoutInstance`
/// (MPC-001) se `source_type = USER_PLAN`. Immutable doménové modely
/// (PDR-008).
@immutable
class TrainingPlan {
  const TrainingPlan({
    required this.id,
    required this.title,
    required this.status,
    this.origin = 'MANUAL',
    this.note,
  });

  final String id;
  final String title;
  final String status;

  /// Provenance (C30 CSE-004): MANUAL | AI_PROPOSAL.
  final String origin;
  final String? note;

  bool get isActive => status == 'ACTIVE';
}

/// Read model workoutu plánu pro editor (MPC-013).
@immutable
class PlannedWorkoutSummary {
  const PlannedWorkoutSummary({
    required this.instanceId,
    required this.title,
    required this.workoutType,
    required this.scheduledLocalDate,
    required this.status,
    required this.exerciseCount,
  });

  final String instanceId;
  final String title;
  final String workoutType;
  final String scheduledLocalDate;
  final String status;
  final int exerciseCount;
}

/// Zadání cviku ručního workoutu (C20 §5.1; C51 §6/§7).
///
/// [exerciseCode] = katalogový cvik (C51) — pak je [title] jen záložní
/// snapshot názvu; `null` = vlastní cvik s [instructions] (povinné u
/// ručního zadání, EXC-008). Předpis: [durationSeconds] → DURATION sady,
/// jinak SET_REP s [repetitions].
@immutable
class PlannedExerciseInput {
  const PlannedExerciseInput({
    required this.title,
    required this.sets,
    this.repetitions = 0,
    this.durationSeconds,
    this.weightKg,
    this.exerciseCode,
    this.instructions,
    this.restAfterSeconds,
  });

  final String title;
  final int sets;
  final int repetitions;
  final int? durationSeconds;
  final double? weightKg;
  final String? exerciseCode;
  final String? instructions;
  final int? restAfterSeconds;

  bool get isDuration => durationSeconds != null;
}

/// Sada kroku plánu v2 (C52 §5): opakování (SET_REP) nebo čas (DURATION).
@immutable
class PlannedSetInput {
  const PlannedSetInput({
    this.repetitions,
    this.durationSeconds,
    this.weightKg,
    this.restAfterSeconds,
  });

  final int? repetitions;
  final int? durationSeconds;
  final double? weightKg;
  final int? restAfterSeconds;
}

/// Krok sekce plánu v2 (C52 §2/§5): EXERCISE (katalog C51 XOR vlastní
/// s popisem) nebo REST (jen čas).
@immutable
class PlannedStepInput {
  const PlannedStepInput({
    required this.stepType,
    this.exerciseCode,
    this.customTitle,
    this.instructions,
    this.prescription,
    this.sets = const [],
    this.note,
    this.durationSeconds,
  });

  /// `EXERCISE` | `REST`.
  final String stepType;
  final String? exerciseCode;
  final String? customTitle;
  final String? instructions;

  /// `SET_REP` | `DURATION` (jen EXERCISE).
  final String? prescription;
  final List<PlannedSetInput> sets;

  /// Krátký koučovací záměr kroku → `purpose`.
  final String? note;

  /// Jen REST.
  final int? durationSeconds;

  bool get isRest => stepType == 'REST';
}

/// Sekce plánu v2 (C52 §2/§5): WARM_UP | MAIN | COOLDOWN.
@immutable
class PlannedSectionInput {
  const PlannedSectionInput({
    required this.sectionType,
    required this.steps,
    this.title,
  });

  final String sectionType;
  final String? title;
  final List<PlannedStepInput> steps;
}

/// Zadání ručního workoutu (C20 §5.1). Cviky jsou volitelné (MPC-011).
@immutable
class PlannedWorkoutInput {
  const PlannedWorkoutInput({
    required this.title,
    required this.workoutType,
    required this.scheduledLocalDate,
    this.plannedDurationMinutes,
    this.description,
    this.exercises = const [],
    this.sections,
  });

  final String title;
  final String workoutType;
  final String scheduledLocalDate;
  final int? plannedDurationMinutes;
  final String? description;

  /// Legacy v1 cviky (jedna sekce MAIN, SET_REP) — použito, když [sections]
  /// chybí (koexistence C52 §6).
  final List<PlannedExerciseInput> exercises;

  /// Plán v2 (C52 §5): sekce → kroky → sady; má přednost před [exercises].
  final List<PlannedSectionInput>? sections;
}

/// Typovaný výsledek zápisu — nikdy raw persistence výjimka.
sealed class PlanWriteResult {
  const PlanWriteResult();
}

final class PlanWriteSaved extends PlanWriteResult {
  const PlanWriteSaved(this.id);
  final String id;
}

/// Vlastník už má jiný ACTIVE plán (MPC-002).
final class PlanWriteActiveConflict extends PlanWriteResult {
  const PlanWriteActiveConflict();
}

final class PlanWriteValidationFailed extends PlanWriteResult {
  const PlanWriteValidationFailed();
}

final class PlanWriteNotFound extends PlanWriteResult {
  const PlanWriteNotFound();
}

/// Stabilní kódy workout typů pro ruční vytváření (C20 §5.2).
const List<String> manualWorkoutTypes = [
  'STRENGTH',
  'ENDURANCE',
  'MOBILITY',
  'TECHNIQUE',
  'GENERAL',
];
