import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/sync_push_models.dart';

/// Výsledek aplikace jedné stažené změny (C42 §3).
enum PullApplyOutcome {
  appliedNew,
  appliedUpdate,
  noOp,

  /// Lokální LOCAL_ONLY/DIRTY — nikdy tiše (PMS-001); řešení = C12 push flow.
  conflictSkipped,

  /// Selhání řádku (např. chybějící FK prerekvizita) — typované, bez pádu
  /// běhu (PMS-009).
  skippedDependency,
}

/// Sloupcová specifikace typu: payload klíč → sloupec (PMS-003 — payload
/// jsou přesné sloupcové hodnoty z push strany, aplikace je inverz).
class _TypeSpec {
  const _TypeSpec(this.table, this.fields);

  final String table;
  final Map<String, String> fields;
}

/// P0 scope (C42 §2): ploché root typy bez FK závislosti na workout
/// hierarchii; rozšíření vlastní C43/C45 (PMS-007).
const List<String> pullSupportedTypes = [
  'USER_SPORT',
  'GOAL',
  'AVAILABILITY_RULE',
  'EQUIPMENT_ITEM',
  'CONSTRAINT_ITEM',
  'TRAINING_PLAN',
  'DAILY_CHECK_IN',
];

const Map<String, _TypeSpec> _specs = {
  'USER_SPORT': _TypeSpec('local_user_sports', {
    'sportCode': 'sport_code',
    'customName': 'custom_name',
    'customCategory': 'custom_category',
    'role': 'role',
    'priority': 'priority',
    'experienceLevel': 'experience_level',
    'lastRegularActivityDate': 'last_regular_activity_date',
    'returnAfterPause': 'return_after_pause',
    'note': 'note',
    'frequencyPerWeek': 'frequency_per_week',
    'typicalDurationMinutes': 'typical_duration_minutes',
    'typicalIntensity': 'typical_intensity',
    'environment': 'environment',
    'fixedDays': 'fixed_days',
    'status': 'status',
    'rowVersion': 'row_version',
  }),
  'GOAL': _TypeSpec('local_goals', {
    'title': 'title',
    'goalType': 'goal_type',
    'priority': 'priority',
    'horizon': 'horizon',
    'status': 'status',
    'userSportId': 'user_sport_id',
    'targetLocalDate': 'target_local_date',
    'note': 'note',
    'rowVersion': 'row_version',
  }),
  'AVAILABILITY_RULE': _TypeSpec('local_availability_rules', {
    'dayOfWeek': 'day_of_week',
    'level': 'level',
    'budgetMinutes': 'budget_minutes',
    'preferredPartOfDay': 'preferred_part_of_day',
    'note': 'note',
    'rowVersion': 'row_version',
  }),
  'EQUIPMENT_ITEM': _TypeSpec('local_equipment_items', {
    'equipmentCode': 'equipment_code',
    'customName': 'custom_name',
    'note': 'note',
    'status': 'status',
    'rowVersion': 'row_version',
  }),
  'CONSTRAINT_ITEM': _TypeSpec('local_constraints', {
    'title': 'title',
    'note': 'note',
    'status': 'status',
    'rowVersion': 'row_version',
  }),
  'TRAINING_PLAN': _TypeSpec('local_training_plans', {
    'title': 'title',
    'note': 'note',
    'status': 'status',
    'origin': 'origin',
    'rowVersion': 'row_version',
  }),
  'DAILY_CHECK_IN': _TypeSpec('local_daily_check_ins', {
    'localDate': 'local_date',
    'energyLevel': 'energy_level',
    'fatigueLevel': 'fatigue_level',
    'sleepQuality': 'sleep_quality',
    'painLevel': 'pain_level',
    'painAreaCode': 'pain_area_code',
    'rowVersion': 'row_version',
  }),
};

/// Aplikace stažených změn dle merge matice C42 §3: server přepisuje jen
/// čistý SYNCED stav, lokální nepushnutá pravda nikdy tiše (PMS-001);
/// idempotence přes evidenci server verzí (PMS-002/006).
class DriftPullApplier {
  DriftPullApplier(this._db);

  final AppDatabase _db;

  Future<PullApplyOutcome> apply(
    String ownerId,
    SyncPullItem item, {
    required DateTime now,
  }) async {
    final spec = _specs[item.entityType];
    if (spec == null) {
      return PullApplyOutcome.skippedDependency;
    }
    final nowMillis = now.toUtc().millisecondsSinceEpoch;

    final knownVersion =
        (await (_db.select(_db.localSyncedVersions)..where(
                  (t) =>
                      t.entityType.equals(item.entityType) &
                      t.entityId.equals(item.entityId),
                ))
                .getSingleOrNull())
            ?.serverVersion;

    final local = await _db
        .customSelect(
          'SELECT sync_state FROM ${spec.table} WHERE id = ?',
          variables: [Variable.withString(item.entityId)],
        )
        .getSingleOrNull();

    if (local != null) {
      final syncState = local.data['sync_state']! as String;
      if (syncState != 'SYNCED') {
        // Nikdy tiše (PMS-001); řešení = existující C12 push flow.
        return PullApplyOutcome.conflictSkipped;
      }
      if (knownVersion != null && item.serverVersion <= knownVersion) {
        return PullApplyOutcome.noOp;
      }
    }

    final columns = <String>[];
    final values = <Variable<Object>>[];
    for (final entry in spec.fields.entries) {
      if (!item.payload.containsKey(entry.key)) {
        continue;
      }
      columns.add(entry.value);
      values.add(Variable(item.payload[entry.key]));
    }

    try {
      if (local == null) {
        await _db.customStatement(
          'INSERT INTO ${spec.table} '
          '(id, owner_id, sync_state, created_at, updated_at, '
          '${columns.join(', ')}) '
          "VALUES (?, ?, 'SYNCED', ?, ?, "
          '${List.filled(columns.length, '?').join(', ')})',
          [
            item.entityId,
            ownerId,
            nowMillis,
            nowMillis,
            ...values.map((v) => v.value),
          ],
        );
      } else {
        await _db.customStatement(
          'UPDATE ${spec.table} SET '
          "sync_state = 'SYNCED', updated_at = ?, "
          '${columns.map((c) => '$c = ?').join(', ')} '
          'WHERE id = ?',
          [nowMillis, ...values.map((v) => v.value), item.entityId],
        );
      }
    } catch (_) {
      // Typované selhání řádku (PMS-009) — žádný částečný zápis (statement
      // je atomický), žádný pád běhu.
      return PullApplyOutcome.skippedDependency;
    }

    // Evidence server verze (PMS-006) — zdroj expectedServerVersion pro
    // push i no-op rozhodnutí dalšího pullu.
    await _db
        .into(_db.localSyncedVersions)
        .insertOnConflictUpdate(
          LocalSyncedVersionsCompanion.insert(
            entityType: item.entityType,
            entityId: item.entityId,
            serverVersion: item.serverVersion,
            updatedAt: nowMillis,
          ),
        );
    return local == null
        ? PullApplyOutcome.appliedNew
        : PullApplyOutcome.appliedUpdate;
  }
}
