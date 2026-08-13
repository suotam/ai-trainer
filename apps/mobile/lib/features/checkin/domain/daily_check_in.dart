import 'package:flutter/foundation.dart';

/// Denní check-in — strukturovaný subjektivní stav (C33 §2).
///
/// Škály 1–5 s definovaným významem (DCI-003); bolest vždy strukturovaně
/// level + oblast (DCI-004); `note` je výhradně lokální (DCI-006).
@immutable
class DailyCheckIn {
  const DailyCheckIn({
    required this.id,
    required this.localDate,
    required this.energyLevel,
    required this.fatigueLevel,
    this.sleepQuality,
    this.painLevel,
    this.painAreaCode,
    this.note,
    required this.createdAtMillis,
    required this.updatedAtMillis,
  });

  final String id;
  final String localDate;
  final int energyLevel;
  final int fatigueLevel;
  final int? sleepQuality;
  final int? painLevel;
  final String? painAreaCode;
  final String? note;
  final int createdAtMillis;
  final int updatedAtMillis;

  bool get hasPain => painLevel != null;
}

/// Zadání check-inu (C33 §2) — bez data; den je klíč zápisu (DCI-002).
@immutable
class DailyCheckInInput {
  const DailyCheckInInput({
    required this.energyLevel,
    required this.fatigueLevel,
    this.sleepQuality,
    this.painLevel,
    this.painAreaCode,
    this.note,
  });

  final int energyLevel;
  final int fatigueLevel;
  final int? sleepQuality;
  final int? painLevel;
  final String? painAreaCode;
  final String? note;
}

/// Typovaný výsledek zápisu — nikdy raw persistence výjimka.
sealed class CheckInWriteResult {
  const CheckInWriteResult();
}

final class CheckInSaved extends CheckInWriteResult {
  const CheckInSaved(this.id);
  final String id;
}

/// Hodnoty mimo škály nebo bolest bez oblasti (DCI-003/004).
final class CheckInValidationFailed extends CheckInWriteResult {
  const CheckInValidationFailed();
}
