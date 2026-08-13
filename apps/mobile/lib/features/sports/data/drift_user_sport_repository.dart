import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/sports_tables.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../domain/sport_catalog.dart';
import '../domain/user_sport.dart';
import '../domain/user_sport_repository.dart';

/// Drift implementace sportovního profilu (R3-01, C17).
///
/// Owner stamping při zápisu aktuálním lokálním vlastníkem (C16 §6.2);
/// invarianty ASP-003/004 se vynucují v téže transakci — DB partial unique
/// index by kolidoval s C15 attach přepisem vlastníka (C17 §8).
class DriftUserSportRepository implements UserSportRepository {
  DriftUserSportRepository(this._db);

  final AppDatabase _db;

  static const _statusOrder =
      "CASE status WHEN 'ACTIVE' THEN 0 "
      "WHEN 'PAUSED' THEN 1 ELSE 2 END";
  static const _roleOrder =
      "CASE role WHEN 'PRIMARY' THEN 0 "
      "WHEN 'SECONDARY' THEN 1 WHEN 'SUPPORTING' THEN 2 "
      "WHEN 'RECREATIONAL' THEN 3 WHEN 'OCCASIONAL' THEN 4 ELSE 5 END";
  static const _priorityOrder =
      "CASE priority WHEN 'CRITICAL' THEN 0 "
      "WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END";

  Future<String> _currentOwnerId() async {
    final row = await (_db.select(
      _db.localAppState,
    )..where((t) => t.key.equals(localOwnerStateKey))).getSingleOrNull();
    return row?.value ?? localAnonymousOwnerId;
  }

  @override
  Future<List<UserSport>> sportsForCurrentOwner() async {
    final owner = await _currentOwnerId();
    final rows = await _db
        .customSelect(
          'SELECT * FROM local_user_sports WHERE owner_id = ? '
          'ORDER BY $_statusOrder, $_roleOrder, $_priorityOrder, '
          'COALESCE(sport_code, custom_name), id',
          variables: [Variable.withString(owner)],
          readsFrom: {_db.localUserSports},
        )
        .get();
    return [for (final row in rows) _toDomain(row.data)];
  }

  @override
  Future<SaveUserSportResult> saveSport(
    UserSportInput input, {
    String? existingId,
    required String newId,
    required DateTime now,
  }) {
    if (!_isValid(input)) {
      return Future.value(const UserSportValidationFailed());
    }
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final excludeId = existingId ?? '';
      LocalUserSportRow? existing;
      if (existingId != null) {
        existing = await (_db.select(
          _db.localUserSports,
        )..where((t) => t.id.equals(existingId))).getSingleOrNull();
        if (existing == null || existing.ownerId != owner) {
          return const UserSportNotFound();
        }
      }
      final status = existing?.status ?? userSportStatusActive;
      if (status != userSportStatusEnded) {
        final conflict = await _findConflicts(
          owner: owner,
          sportCode: input.sportCode,
          isActivePrimary:
              input.role == 'PRIMARY' && status == userSportStatusActive,
          excludeId: excludeId,
        );
        if (conflict != null) {
          return conflict;
        }
      }

      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      final companion = LocalUserSportsCompanion(
        sportCode: Value(input.sportCode),
        customName: Value(input.customName),
        customCategory: Value(input.customCategory),
        role: Value(input.role),
        priority: Value(input.priority),
        experienceLevel: Value(input.experienceLevel),
        lastRegularActivityDate: Value(input.lastRegularActivityDate),
        returnAfterPause: Value(input.returnAfterPause),
        note: Value(input.note),
        frequencyPerWeek: Value(input.frequencyPerWeek),
        typicalDurationMinutes: Value(input.typicalDurationMinutes),
        typicalIntensity: Value(input.typicalIntensity),
        environment: Value(input.environment),
        fixedDays: Value(
          input.fixedDays.isEmpty ? null : input.fixedDays.join(','),
        ),
        updatedAt: Value(nowMillis),
      );

      if (existing == null) {
        await _db
            .into(_db.localUserSports)
            .insert(
              companion.copyWith(
                id: Value(newId),
                status: const Value(userSportStatusActive),
                createdAt: Value(nowMillis),
                rowVersion: const Value(1),
                ownerId: Value(owner),
                syncState: const Value(syncStateLocalOnly),
              ),
            );
        return UserSportSaved(newId);
      }

      // Úprava current-state (ASP-007): verze +1, SYNCED → DIRTY.
      await (_db.update(
        _db.localUserSports,
      )..where((t) => t.id.equals(existing!.id))).write(
        companion.copyWith(
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return UserSportSaved(existing.id);
    });
  }

  @override
  Future<SaveUserSportResult> changeStatus(
    String id,
    String newStatus, {
    required DateTime now,
  }) {
    const allowed = [
      userSportStatusActive,
      userSportStatusPaused,
      userSportStatusEnded,
    ];
    if (!allowed.contains(newStatus)) {
      return Future.value(const UserSportValidationFailed());
    }
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final existing = await (_db.select(
        _db.localUserSports,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing == null || existing.ownerId != owner) {
        return const UserSportNotFound();
      }
      if (existing.status == newStatus) {
        return UserSportSaved(id);
      }
      // Návrat mezi ne-ENDED stavy kontroluje invarianty účtu znovu
      // (resume PRIMARY → ASP-003; reaktivace katalogového sportu →
      // ASP-004).
      if (newStatus != userSportStatusEnded) {
        final conflict = await _findConflicts(
          owner: owner,
          sportCode: existing.sportCode,
          isActivePrimary:
              existing.role == 'PRIMARY' && newStatus == userSportStatusActive,
          excludeId: id,
        );
        if (conflict != null) {
          return conflict;
        }
      }
      await (_db.update(
        _db.localUserSports,
      )..where((t) => t.id.equals(id))).write(
        LocalUserSportsCompanion(
          status: Value(newStatus),
          updatedAt: Value(now.toUtc().millisecondsSinceEpoch),
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return UserSportSaved(id);
    });
  }

  /// Kontrola ASP-004 (duplicitní ne-ENDED katalogový sport) a ASP-003
  /// (jeden ACTIVE PRIMARY) pro daného vlastníka.
  Future<SaveUserSportResult?> _findConflicts({
    required String owner,
    required String? sportCode,
    required bool isActivePrimary,
    required String excludeId,
  }) async {
    if (sportCode != null) {
      final duplicate = await _db
          .customSelect(
            'SELECT 1 FROM local_user_sports WHERE owner_id = ? '
            "AND sport_code = ? AND status != '$userSportStatusEnded' "
            'AND id != ? LIMIT 1',
            variables: [
              Variable.withString(owner),
              Variable.withString(sportCode),
              Variable.withString(excludeId),
            ],
          )
          .getSingleOrNull();
      if (duplicate != null) {
        return const UserSportDuplicate();
      }
    }
    if (isActivePrimary) {
      final primary = await _db
          .customSelect(
            'SELECT 1 FROM local_user_sports WHERE owner_id = ? '
            "AND role = 'PRIMARY' AND status = '$userSportStatusActive' "
            'AND id != ? LIMIT 1',
            variables: [
              Variable.withString(owner),
              Variable.withString(excludeId),
            ],
          )
          .getSingleOrNull();
      if (primary != null) {
        return const UserSportPrimaryConflict();
      }
    }
    return null;
  }

  bool _isValid(UserSportInput input) {
    final hasCatalog = input.sportCode != null;
    final hasCustom = input.customName?.trim().isNotEmpty ?? false;
    if (hasCatalog == hasCustom) {
      return false;
    }
    if (hasCatalog && !isKnownSportCode(input.sportCode!)) {
      return false;
    }
    if (!userSportRoles.contains(input.role) ||
        !userSportPriorities.contains(input.priority) ||
        !experienceLevels.contains(input.experienceLevel)) {
      return false;
    }
    if (input.typicalIntensity != null &&
        !typicalIntensities.contains(input.typicalIntensity)) {
      return false;
    }
    if (input.environment != null &&
        !sportEnvironments.contains(input.environment)) {
      return false;
    }
    if ((input.frequencyPerWeek ?? 0) < 0 ||
        (input.typicalDurationMinutes ?? 0) < 0) {
      return false;
    }
    return true;
  }

  UserSport _toDomain(Map<String, Object?> row) => UserSport(
    id: row['id']! as String,
    sportCode: row['sport_code'] as String?,
    customName: row['custom_name'] as String?,
    customCategory: row['custom_category'] as String?,
    role: row['role']! as String,
    priority: row['priority']! as String,
    experienceLevel: row['experience_level']! as String,
    status: row['status']! as String,
    lastRegularActivityDate: row['last_regular_activity_date'] as String?,
    returnAfterPause: (row['return_after_pause']! as int) != 0,
    note: row['note'] as String?,
    frequencyPerWeek: row['frequency_per_week'] as int?,
    typicalDurationMinutes: row['typical_duration_minutes'] as int?,
    typicalIntensity: row['typical_intensity'] as String?,
    environment: row['environment'] as String?,
    fixedDays: switch (row['fixed_days'] as String?) {
      null || '' => const [],
      final days => days.split(','),
    },
  );
}
