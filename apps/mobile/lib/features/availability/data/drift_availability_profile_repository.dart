import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/availability_tables.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../domain/availability_profile.dart';
import '../domain/availability_profile_repository.dart';

/// Drift implementace dostupnosti a kontextu (R3-03, C19).
///
/// Owner stamping při zápisu aktuálním lokálním vlastníkem (C16 §6.2);
/// invarianty AVC-003/006 v transakci s typovanými výsledky.
class DriftAvailabilityProfileRepository
    implements AvailabilityProfileRepository {
  DriftAvailabilityProfileRepository(this._db);

  final AppDatabase _db;

  static const _dayOrder =
      "CASE day_of_week WHEN 'MON' THEN 0 WHEN 'TUE' THEN 1 "
      "WHEN 'WED' THEN 2 WHEN 'THU' THEN 3 WHEN 'FRI' THEN 4 "
      "WHEN 'SAT' THEN 5 ELSE 6 END";

  Future<String> _currentOwnerId() async {
    final row = await (_db.select(
      _db.localAppState,
    )..where((t) => t.key.equals(localOwnerStateKey))).getSingleOrNull();
    return row?.value ?? localAnonymousOwnerId;
  }

  // ---- Typický týden -------------------------------------------------

  @override
  Future<List<AvailabilityRule>> weekForCurrentOwner() async {
    final owner = await _currentOwnerId();
    final rows = await _db
        .customSelect(
          'SELECT * FROM local_availability_rules WHERE owner_id = ? '
          'ORDER BY $_dayOrder',
          variables: [Variable.withString(owner)],
          readsFrom: {_db.localAvailabilityRules},
        )
        .get();
    return [
      for (final row in rows)
        AvailabilityRule(
          id: row.data['id']! as String,
          dayOfWeek: row.data['day_of_week']! as String,
          level: row.data['level']! as String,
          budgetMinutes: row.data['budget_minutes'] as int?,
          preferredPartOfDay: row.data['preferred_part_of_day'] as String?,
          note: row.data['note'] as String?,
        ),
    ];
  }

  @override
  Future<AvailabilityWriteResult> upsertDay({
    required String dayOfWeek,
    required String level,
    int? budgetMinutes,
    String? preferredPartOfDay,
    String? note,
    required String newId,
    required DateTime now,
  }) {
    if (!weekDays.contains(dayOfWeek) ||
        !availabilityLevels.contains(level) ||
        (preferredPartOfDay != null &&
            !partsOfDay.contains(preferredPartOfDay)) ||
        (budgetMinutes ?? 0) < 0) {
      return Future.value(const AvailabilityWriteValidationFailed());
    }
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      final existing =
          await (_db.select(_db.localAvailabilityRules)..where(
                (t) => t.ownerId.equals(owner) & t.dayOfWeek.equals(dayOfWeek),
              ))
              .getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.localAvailabilityRules)
            .insert(
              LocalAvailabilityRulesCompanion.insert(
                id: newId,
                dayOfWeek: dayOfWeek,
                level: level,
                budgetMinutes: Value(budgetMinutes),
                preferredPartOfDay: Value(preferredPartOfDay),
                note: Value(note),
                createdAt: nowMillis,
                updatedAt: nowMillis,
                rowVersion: 1,
                ownerId: Value(owner),
              ),
            );
        return AvailabilityWriteSaved(newId);
      }
      await (_db.update(
        _db.localAvailabilityRules,
      )..where((t) => t.id.equals(existing.id))).write(
        LocalAvailabilityRulesCompanion(
          level: Value(level),
          budgetMinutes: Value(budgetMinutes),
          preferredPartOfDay: Value(preferredPartOfDay),
          note: Value(note),
          updatedAt: Value(nowMillis),
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return AvailabilityWriteSaved(existing.id);
    });
  }

  @override
  Future<AvailabilityWriteResult> removeDay(String dayOfWeek) {
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final removed =
          await (_db.delete(_db.localAvailabilityRules)..where(
                (t) => t.ownerId.equals(owner) & t.dayOfWeek.equals(dayOfWeek),
              ))
              .go();
      return removed == 0
          ? const AvailabilityWriteNotFound()
          : AvailabilityWriteSaved(dayOfWeek);
    });
  }

  // ---- Vybavení ------------------------------------------------------

  @override
  Future<List<EquipmentItem>> equipmentForCurrentOwner() async {
    final owner = await _currentOwnerId();
    final rows = await _db
        .customSelect(
          'SELECT * FROM local_equipment_items WHERE owner_id = ? '
          "ORDER BY CASE status WHEN 'ACTIVE' THEN 0 ELSE 1 END, "
          'COALESCE(equipment_code, custom_name), id',
          variables: [Variable.withString(owner)],
          readsFrom: {_db.localEquipmentItems},
        )
        .get();
    return [
      for (final row in rows)
        EquipmentItem(
          id: row.data['id']! as String,
          equipmentCode: row.data['equipment_code'] as String?,
          customName: row.data['custom_name'] as String?,
          status: row.data['status']! as String,
          note: row.data['note'] as String?,
        ),
    ];
  }

  @override
  Future<AvailabilityWriteResult> addEquipment({
    String? equipmentCode,
    String? customName,
    String? note,
    required String newId,
    required DateTime now,
  }) {
    final hasCatalog = equipmentCode != null;
    final hasCustom = customName?.trim().isNotEmpty ?? false;
    if (hasCatalog == hasCustom ||
        (hasCatalog && !equipmentCatalog.contains(equipmentCode))) {
      return Future.value(const AvailabilityWriteValidationFailed());
    }
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      if (hasCatalog) {
        final duplicate = await _db
            .customSelect(
              'SELECT 1 FROM local_equipment_items WHERE owner_id = ? '
              "AND equipment_code = ? AND status != '$equipmentStatusArchived' "
              'LIMIT 1',
              variables: [
                Variable.withString(owner),
                Variable.withString(equipmentCode),
              ],
            )
            .getSingleOrNull();
        if (duplicate != null) {
          return const AvailabilityWriteDuplicate();
        }
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      await _db
          .into(_db.localEquipmentItems)
          .insert(
            LocalEquipmentItemsCompanion.insert(
              id: newId,
              equipmentCode: Value(equipmentCode),
              customName: Value(hasCustom ? customName!.trim() : null),
              note: Value(note),
              createdAt: nowMillis,
              updatedAt: nowMillis,
              rowVersion: 1,
              ownerId: Value(owner),
            ),
          );
      return AvailabilityWriteSaved(newId);
    });
  }

  @override
  Future<AvailabilityWriteResult> setEquipmentStatus(
    String id,
    String status, {
    required DateTime now,
  }) {
    if (status != equipmentStatusActive && status != equipmentStatusArchived) {
      return Future.value(const AvailabilityWriteValidationFailed());
    }
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final existing = await (_db.select(
        _db.localEquipmentItems,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing == null || existing.ownerId != owner) {
        return const AvailabilityWriteNotFound();
      }
      if (existing.status == status) {
        return AvailabilityWriteSaved(id);
      }
      // Reaktivace katalogové položky kontroluje AVC-006 znovu.
      if (status == equipmentStatusActive && existing.equipmentCode != null) {
        final duplicate = await _db
            .customSelect(
              'SELECT 1 FROM local_equipment_items WHERE owner_id = ? '
              "AND equipment_code = ? AND status != '$equipmentStatusArchived' "
              'AND id != ? LIMIT 1',
              variables: [
                Variable.withString(owner),
                Variable.withString(existing.equipmentCode!),
                Variable.withString(id),
              ],
            )
            .getSingleOrNull();
        if (duplicate != null) {
          return const AvailabilityWriteDuplicate();
        }
      }
      await (_db.update(
        _db.localEquipmentItems,
      )..where((t) => t.id.equals(id))).write(
        LocalEquipmentItemsCompanion(
          status: Value(status),
          updatedAt: Value(now.toUtc().millisecondsSinceEpoch),
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return AvailabilityWriteSaved(id);
    });
  }

  // ---- Omezení -------------------------------------------------------

  @override
  Future<List<BasicConstraint>> constraintsForCurrentOwner() async {
    final owner = await _currentOwnerId();
    final rows = await _db
        .customSelect(
          'SELECT * FROM local_constraints WHERE owner_id = ? '
          "ORDER BY CASE status WHEN 'ACTIVE' THEN 0 ELSE 1 END, title, id",
          variables: [Variable.withString(owner)],
          readsFrom: {_db.localConstraints},
        )
        .get();
    return [
      for (final row in rows)
        BasicConstraint(
          id: row.data['id']! as String,
          title: row.data['title']! as String,
          status: row.data['status']! as String,
          note: row.data['note'] as String?,
        ),
    ];
  }

  @override
  Future<AvailabilityWriteResult> addConstraint({
    required String title,
    String? note,
    required String newId,
    required DateTime now,
  }) {
    if (title.trim().isEmpty) {
      return Future.value(const AvailabilityWriteValidationFailed());
    }
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      await _db
          .into(_db.localConstraints)
          .insert(
            LocalConstraintsCompanion.insert(
              id: newId,
              title: title.trim(),
              note: Value(note),
              createdAt: nowMillis,
              updatedAt: nowMillis,
              rowVersion: 1,
              ownerId: Value(owner),
            ),
          );
      return AvailabilityWriteSaved(newId);
    });
  }

  @override
  Future<AvailabilityWriteResult> setConstraintStatus(
    String id,
    String status, {
    required DateTime now,
  }) {
    if (status != constraintStatusActive &&
        status != constraintStatusResolved) {
      return Future.value(const AvailabilityWriteValidationFailed());
    }
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final existing = await (_db.select(
        _db.localConstraints,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing == null || existing.ownerId != owner) {
        return const AvailabilityWriteNotFound();
      }
      if (existing.status == status) {
        return AvailabilityWriteSaved(id);
      }
      await (_db.update(
        _db.localConstraints,
      )..where((t) => t.id.equals(id))).write(
        LocalConstraintsCompanion(
          status: Value(status),
          updatedAt: Value(now.toUtc().millisecondsSinceEpoch),
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return AvailabilityWriteSaved(id);
    });
  }
}
