import 'package:flutter/foundation.dart';

/// Dostupnost a tréninkový kontext — P0 podmnožina dle C19.
///
/// Tři deklarativní oblasti: typický týden, vybavení, základní omezení.
/// Deklarace, ne vynucení (AVC-005); immutable doménové modely (PDR-008).
@immutable
class AvailabilityRule {
  const AvailabilityRule({
    required this.id,
    required this.dayOfWeek,
    required this.level,
    this.budgetMinutes,
    this.preferredPartOfDay,
    this.note,
  });

  final String id;
  final String dayOfWeek;
  final String level;
  final int? budgetMinutes;
  final String? preferredPartOfDay;
  final String? note;
}

@immutable
class EquipmentItem {
  const EquipmentItem({
    required this.id,
    required this.equipmentCode,
    required this.customName,
    required this.status,
    this.note,
  });

  final String id;
  final String? equipmentCode;
  final String? customName;
  final String status;
  final String? note;

  bool get isCustom => equipmentCode == null;
}

@immutable
class BasicConstraint {
  const BasicConstraint({
    required this.id,
    required this.title,
    required this.status,
    this.note,
  });

  final String id;
  final String title;
  final String status;
  final String? note;
}

/// Typovaný výsledek zápisu — nikdy raw persistence výjimka.
sealed class AvailabilityWriteResult {
  const AvailabilityWriteResult();
}

final class AvailabilityWriteSaved extends AvailabilityWriteResult {
  const AvailabilityWriteSaved(this.id);
  final String id;
}

/// Duplicitní ne-ARCHIVED katalogové vybavení (AVC-006).
final class AvailabilityWriteDuplicate extends AvailabilityWriteResult {
  const AvailabilityWriteDuplicate();
}

final class AvailabilityWriteValidationFailed extends AvailabilityWriteResult {
  const AvailabilityWriteValidationFailed();
}

final class AvailabilityWriteNotFound extends AvailabilityWriteResult {
  const AvailabilityWriteNotFound();
}

/// Stabilní kódy (C19 §7).
const List<String> weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

const List<String> availabilityLevels = ['AVAILABLE', 'LIMITED', 'UNAVAILABLE'];

const List<String> partsOfDay = ['MORNING', 'AFTERNOON', 'EVENING'];

/// Minimální katalog vybavení (C19 §5) — stabilní kanonické kódy.
const List<String> equipmentCatalog = [
  'GYM_ACCESS',
  'BARBELL',
  'DUMBBELLS',
  'KETTLEBELL',
  'RESISTANCE_BANDS',
  'PULL_UP_BAR',
  'BENCH',
  'TREADMILL',
  'STATIONARY_BIKE',
  'BIKE',
  'CLIMBING_WALL_ACCESS',
  'POOL_ACCESS',
  'YOGA_MAT',
];
