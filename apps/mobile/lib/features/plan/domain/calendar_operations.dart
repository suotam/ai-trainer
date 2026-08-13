import 'package:flutter/foundation.dart';

import 'training_plan.dart';

/// Kalendářní operace nad ručně plánovanými workouty (R3-05, C21):
/// přesun, zrušení, nahrazení — jen na budoucích/nezapočatých USER_PLAN
/// instancích (CAL-001/002), s append-only evidencí (CAL-003).
@immutable
class CalendarChangeEntry {
  const CalendarChangeEntry({
    required this.id,
    required this.workoutInstanceId,
    required this.changeType,
    this.fromLocalDate,
    this.toLocalDate,
    this.replacementInstanceId,
  });

  final String id;
  final String workoutInstanceId;
  final String changeType;
  final String? fromLocalDate;
  final String? toLocalDate;
  final String? replacementInstanceId;
}

/// Typovaný výsledek operace — nikdy raw persistence výjimka (CAL-007).
sealed class CalendarOpResult {
  const CalendarOpResult();
}

final class CalendarOpSaved extends CalendarOpResult {
  const CalendarOpSaved(this.id);

  /// U nahrazení ID náhradní instance, jinak ID dotčené instance.
  final String id;
}

/// Guard (CAL-002/001): instance se session, dokončená, zrušená
/// (move/replace), cizí nebo mimo USER_PLAN.
final class CalendarOpNotAllowed extends CalendarOpResult {
  const CalendarOpNotAllowed();
}

final class CalendarOpValidationFailed extends CalendarOpResult {
  const CalendarOpValidationFailed();
}

final class CalendarOpNotFound extends CalendarOpResult {
  const CalendarOpNotFound();
}

/// Port kalendářních operací (C21 §4).
abstract interface class CalendarOperationsRepository {
  /// Přesun na cílový den (CAL: MOVED); stejné datum je idempotentní no-op.
  Future<CalendarOpResult> moveWorkout(
    String instanceId,
    String targetLocalDate, {
    required String changeId,
    required DateTime now,
  });

  /// Zrušení (status `CANCELLED`, CAL-004); opakované zrušení je no-op.
  Future<CalendarOpResult> cancelWorkout(
    String instanceId, {
    required String changeId,
    required DateTime now,
  });

  /// Atomické nahrazení (CAL-005): originál `CANCELLED` + nová instance
  /// C20 cestou + evidence s referencí.
  Future<CalendarOpResult> replaceWorkout(
    String instanceId,
    PlannedWorkoutInput replacement, {
    required String Function() newId,
    required DateTime now,
  });

  /// Append-only evidence instance řazená časem (CAL-012).
  Future<List<CalendarChangeEntry>> changesForInstance(String instanceId);
}
