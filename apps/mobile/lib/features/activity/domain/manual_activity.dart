import 'package:flutter/foundation.dart';

/// Ruční aktivita — P0 podmnožina dle C22: fakt po skutečnosti (MAC-004),
/// zdroj výhradně `MANUAL` (MAC-003). Immutable doménové modely (PDR-008).
@immutable
class ManualActivity {
  const ManualActivity({
    required this.id,
    required this.title,
    required this.localDate,
    this.durationMinutes,
    this.userSportId,
    this.workoutInstanceId,
    this.note,
  });

  final String id;
  final String title;
  final String localDate;
  final int? durationMinutes;
  final String? userSportId;
  final String? workoutInstanceId;
  final String? note;
}

/// Vstup pro vytvoření/úpravu ruční aktivity (MAC-002).
@immutable
class ManualActivityInput {
  const ManualActivityInput({
    required this.title,
    required this.localDate,
    this.durationMinutes,
    this.userSportId,
    this.workoutInstanceId,
    this.note,
  });

  final String title;
  final String localDate;
  final int? durationMinutes;
  final String? userSportId;
  final String? workoutInstanceId;
  final String? note;
}

/// Typovaný výsledek zápisu — nikdy raw persistence výjimka.
sealed class ActivityWriteResult {
  const ActivityWriteResult();
}

final class ActivityWriteSaved extends ActivityWriteResult {
  const ActivityWriteSaved(this.id);
  final String id;
}

final class ActivityWriteValidationFailed extends ActivityWriteResult {
  const ActivityWriteValidationFailed();
}

final class ActivityWriteNotFound extends ActivityWriteResult {
  const ActivityWriteNotFound();
}

/// Základní progres/completion statistiky za období (C23 §3) —
/// deterministický read model bez perzistence (PST-001/002).
@immutable
class ProgressStatistics {
  const ProgressStatistics({
    required this.fromLocalDate,
    required this.toLocalDate,
    required this.plannedCount,
    required this.completedCount,
    required this.manualActivityCount,
    required this.manualMinutes,
  });

  final String fromLocalDate;
  final String toLocalDate;
  final int plannedCount;
  final int completedCount;
  final int manualActivityCount;
  final int manualMinutes;

  /// Definován jen pro plannedCount > 0 (PST-004 — jinak „—", ne 0/100 %).
  double? get completionRate =>
      plannedCount > 0 ? completedCount / plannedCount : null;
}
