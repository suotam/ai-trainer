import 'availability_profile.dart';

/// Port dostupnosti a tréninkového kontextu (R3-03, C19).
///
/// Offline-first (AVC-012), data aktuálního lokálního vlastníka.
/// Invarianty AVC-003/006 vynucuje implementace v transakci.
abstract interface class AvailabilityProfileRepository {
  /// Deklarace typického týdne v pořadí MON..SUN (jen deklarované dny,
  /// AVC-004/014).
  Future<List<AvailabilityRule>> weekForCurrentOwner();

  /// Upsert deklarace dne (AVC-003: jedna na den a vlastníka) — existující
  /// den se edituje current-state (AVC-011).
  Future<AvailabilityWriteResult> upsertDay({
    required String dayOfWeek,
    required String level,
    int? budgetMinutes,
    String? preferredPartOfDay,
    String? note,
    required String newId,
    required DateTime now,
  });

  /// Zpětvzetí deklarace dne (AVC-008) — legitimní odstranění
  /// current-state preference.
  Future<AvailabilityWriteResult> removeDay(String dayOfWeek);

  Future<List<EquipmentItem>> equipmentForCurrentOwner();

  /// Přidá vybavení (katalogový kód XOR custom název); duplicitní
  /// ne-ARCHIVED katalogový kód je odmítnut (AVC-006).
  Future<AvailabilityWriteResult> addEquipment({
    String? equipmentCode,
    String? customName,
    String? note,
    required String newId,
    required DateTime now,
  });

  /// Archivace/reaktivace vybavení — stavová změna, ne mazání (AVC-007).
  Future<AvailabilityWriteResult> setEquipmentStatus(
    String id,
    String status, {
    required DateTime now,
  });

  Future<List<BasicConstraint>> constraintsForCurrentOwner();

  /// Přidá omezení (povinný title; bez interpretace, AVC-009).
  Future<AvailabilityWriteResult> addConstraint({
    required String title,
    String? note,
    required String newId,
    required DateTime now,
  });

  /// Vyřešení/reaktivace omezení — stavová změna, ne mazání (AVC-007).
  Future<AvailabilityWriteResult> setConstraintStatus(
    String id,
    String status, {
    required DateTime now,
  });
}
