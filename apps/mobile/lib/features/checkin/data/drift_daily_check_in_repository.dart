import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/checkin_tables.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../domain/daily_check_in.dart';
import '../domain/daily_check_in_repository.dart';

/// Drift implementace denního check-inu (R5-01, C33 §3).
///
/// Denní klíč vynucuje transakce (DCI-002, vzor MPC-002 — DB unique by
/// kolidoval s C15 attach přepisem vlastníka). Owner stamping při zápisu
/// (C16 §6.2); editace značí SYNCED → DIRTY.
class DriftDailyCheckInRepository implements DailyCheckInRepository {
  DriftDailyCheckInRepository(this._db);

  final AppDatabase _db;

  static final _dateFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  Future<String> _currentOwnerId() async {
    final row = await (_db.select(
      _db.localAppState,
    )..where((t) => t.key.equals(localOwnerStateKey))).getSingleOrNull();
    return row?.value ?? localAnonymousOwnerId;
  }

  @override
  Future<CheckInWriteResult> saveForDate(
    String localDate,
    DailyCheckInInput input, {
    required String newId,
    required DateTime now,
  }) {
    if (!_isValid(localDate, input)) {
      return Future.value(const CheckInValidationFailed());
    }
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      final existing =
          await (_db.select(_db.localDailyCheckIns)..where(
                (t) => t.ownerId.equals(owner) & t.localDate.equals(localDate),
              ))
              .getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.localDailyCheckIns)
            .insert(
              LocalDailyCheckInsCompanion.insert(
                id: newId,
                localDate: localDate,
                energyLevel: input.energyLevel,
                fatigueLevel: input.fatigueLevel,
                sleepQuality: Value(input.sleepQuality),
                painLevel: Value(input.painLevel),
                painAreaCode: Value(input.painAreaCode),
                note: Value(input.note),
                createdAt: nowMillis,
                updatedAt: nowMillis,
                rowVersion: 1,
                ownerId: Value(owner),
              ),
            );
        return CheckInSaved(newId);
      }
      // Editace dne (DCI-002/008): tentýž záznam, rowVersion+1.
      await (_db.update(
        _db.localDailyCheckIns,
      )..where((t) => t.id.equals(existing.id))).write(
        LocalDailyCheckInsCompanion(
          energyLevel: Value(input.energyLevel),
          fatigueLevel: Value(input.fatigueLevel),
          sleepQuality: Value(input.sleepQuality),
          painLevel: Value(input.painLevel),
          painAreaCode: Value(input.painAreaCode),
          note: Value(input.note),
          updatedAt: Value(nowMillis),
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return CheckInSaved(existing.id);
    });
  }

  @override
  Future<DailyCheckIn?> checkInForDate(String localDate) async {
    final owner = await _currentOwnerId();
    final row =
        await (_db.select(_db.localDailyCheckIns)..where(
              (t) => t.ownerId.equals(owner) & t.localDate.equals(localDate),
            ))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<DailyCheckIn>> historyForCurrentOwner() async {
    final owner = await _currentOwnerId();
    final rows =
        await (_db.select(_db.localDailyCheckIns)
              ..where((t) => t.ownerId.equals(owner))
              ..orderBy([
                (t) => OrderingTerm.desc(t.localDate),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return [for (final row in rows) _toDomain(row)];
  }

  bool _isValid(String localDate, DailyCheckInInput input) {
    bool inScale(int? value) => value == null || (value >= 1 && value <= 5);
    if (!_dateFormat.hasMatch(localDate) ||
        !inScale(input.energyLevel) ||
        !inScale(input.fatigueLevel) ||
        !inScale(input.sleepQuality) ||
        !inScale(input.painLevel)) {
      return false;
    }
    // Bolest vždy strukturovaně spolu s oblastí (DCI-004).
    if ((input.painLevel == null) != (input.painAreaCode == null)) {
      return false;
    }
    return input.painAreaCode == null ||
        painAreaCodes.contains(input.painAreaCode);
  }

  DailyCheckIn _toDomain(LocalDailyCheckInRow row) => DailyCheckIn(
    id: row.id,
    localDate: row.localDate,
    energyLevel: row.energyLevel,
    fatigueLevel: row.fatigueLevel,
    sleepQuality: row.sleepQuality,
    painLevel: row.painLevel,
    painAreaCode: row.painAreaCode,
    note: row.note,
    createdAtMillis: row.createdAt,
    updatedAtMillis: row.updatedAt,
  );
}
