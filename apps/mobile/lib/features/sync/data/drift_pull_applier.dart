import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/sync_push_models.dart';

/// Výsledek aplikace jedné stažené změny (C42 §3).
enum PullApplyOutcome {
  appliedNew,
  appliedUpdate,

  /// Tombstone aplikován — lokální SYNCED řádek smazán (C44 §3).
  appliedDelete,
  noOp,

  /// Lokální LOCAL_ONLY/DIRTY — nikdy tiše (PMS-001); řešení = C12 push flow.
  conflictSkipped,

  /// Selhání řádku (např. chybějící FK prerekvizita) — typované, bez pádu
  /// běhu (PMS-009).
  skippedDependency,
}

/// Sloupcová specifikace typu: payload klíč → sloupec (PMS-003 — payload
/// jsou přesné sloupcové hodnoty z push strany, aplikace je inverz).
/// `timestamps: false` pro tabulky bez lokálních meta časů (nese payload);
/// `owned: false` pro children bez owner/sync sloupců (tranzitivní
/// vlastnictví přes session, C2/DRS-011).
class _TypeSpec {
  const _TypeSpec(
    this.table,
    this.fields, {
    this.timestamps = true,
    this.owned = true,
  });

  final String table;
  final Map<String, String> fields;
  final bool timestamps;
  final bool owned;
}

/// Pull scope (C42 §2 + C43 §3 + C45 §2): všech 15 registrových typů
/// v pořadí FK prerekvizit — ploché roots, instance se strukturou,
/// R1 historie, závislé typy.
const List<String> pullSupportedTypes = [
  'USER_SPORT',
  'GOAL',
  'AVAILABILITY_RULE',
  'EQUIPMENT_ITEM',
  'CONSTRAINT_ITEM',
  'TRAINING_PLAN',
  'DAILY_CHECK_IN',
  'WORKOUT_INSTANCE',
  'WORKOUT_SESSION',
  'STEP_PERFORMANCE',
  'SET_PERFORMANCE',
  'WORKOUT_FEEDBACK',
  'ACTIVITY_SUMMARY',
  'MANUAL_ACTIVITY',
  'CALENDAR_CHANGE',
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
  // C43 §3: instance nese v payloadu created/updated časy původního
  // zařízení — aplikují se beze změny (timestamps: false).
  'WORKOUT_INSTANCE': _TypeSpec('local_workout_instances', {
    'title': 'title',
    'description': 'description',
    'purpose': 'purpose',
    'workoutType': 'workout_type',
    'scheduledLocalDate': 'scheduled_local_date',
    'scheduledStartAt': 'scheduled_start_at',
    'timeZoneId': 'time_zone_id',
    'plannedDurationSeconds': 'planned_duration_seconds',
    'status': 'status',
    'sourceType': 'source_type',
    'sourceReference': 'source_reference',
    'revisionNumber': 'revision_number',
    'completedAt': 'completed_at',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'rowVersion': 'row_version',
  }, timestamps: false),
  // C45 §2: R1 historie — payloady nesou původní časy zařízení.
  'WORKOUT_SESSION': _TypeSpec('local_workout_sessions', {
    'workoutInstanceId': 'workout_instance_id',
    'instanceRevisionNumber': 'instance_revision_number',
    'status': 'status',
    'startedAt': 'started_at',
    'lastResumedAt': 'last_resumed_at',
    'pausedAt': 'paused_at',
    'completedAt': 'completed_at',
    'activeStepId': 'active_step_id',
    'elapsedActiveSeconds': 'elapsed_active_seconds',
    'notes': 'notes',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'rowVersion': 'row_version',
  }, timestamps: false),
  'STEP_PERFORMANCE': _TypeSpec(
    'local_step_performances',
    {
      'workoutSessionId': 'workout_session_id',
      'workoutStepId': 'workout_step_id',
      'status': 'status',
      'startedAt': 'started_at',
      'completedAt': 'completed_at',
      'actualRepetitions': 'actual_repetitions',
      'actualDurationSeconds': 'actual_duration_seconds',
      'actualDistanceMeters': 'actual_distance_meters',
      'actualWeightKg': 'actual_weight_kg',
      'perceivedExertion': 'perceived_exertion',
      'notes': 'notes',
      'updatedAt': 'updated_at',
      'rowVersion': 'row_version',
    },
    timestamps: false,
    owned: false,
  ),
  'SET_PERFORMANCE': _TypeSpec(
    'local_set_performances',
    {
      'stepPerformanceId': 'step_performance_id',
      'setPlanId': 'set_plan_id',
      'position': 'position',
      'status': 'status',
      'actualRepetitions': 'actual_repetitions',
      'actualWeightKg': 'actual_weight_kg',
      'actualDurationSeconds': 'actual_duration_seconds',
      'actualRpe': 'actual_rpe',
      'completedAt': 'completed_at',
      'notes': 'notes',
      'updatedAt': 'updated_at',
      'rowVersion': 'row_version',
    },
    timestamps: false,
    owned: false,
  ),
  'WORKOUT_FEEDBACK': _TypeSpec(
    'local_workout_feedback',
    {
      'workoutSessionId': 'workout_session_id',
      'overallEffort': 'overall_effort',
      'feeling': 'feeling',
      'painReported': 'pain_reported',
      'notes': 'notes',
      'createdAt': 'created_at',
      'updatedAt': 'updated_at',
    },
    timestamps: false,
    owned: false,
  ),
  'ACTIVITY_SUMMARY': _TypeSpec('local_activity_summaries', {
    'workoutInstanceId': 'workout_instance_id',
    'workoutSessionId': 'workout_session_id',
    'titleSnapshot': 'title_snapshot',
    'workoutType': 'workout_type',
    'startedAt': 'started_at',
    'completedAt': 'completed_at',
    'activeDurationSeconds': 'active_duration_seconds',
    'completedStepCount': 'completed_step_count',
    'totalStepCount': 'total_step_count',
    'overallEffort': 'overall_effort',
    'createdAt': 'created_at',
  }, timestamps: false),
  'MANUAL_ACTIVITY': _TypeSpec('local_activities', {
    'title': 'title',
    'localDate': 'local_date',
    'durationMinutes': 'duration_minutes',
    'userSportId': 'user_sport_id',
    'workoutInstanceId': 'workout_instance_id',
    'note': 'note',
    'source': 'source',
    'rowVersion': 'row_version',
  }),
  'CALENDAR_CHANGE': _TypeSpec('local_calendar_changes', {
    'workoutInstanceId': 'workout_instance_id',
    'changeType': 'change_type',
    'fromLocalDate': 'from_local_date',
    'toLocalDate': 'to_local_date',
    'replacementInstanceId': 'replacement_instance_id',
    'createdAt': 'created_at',
  }, timestamps: false),
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

    // Children bez owner/sync sloupců jsou vlastněny tranzitivně (DRS-011)
    // — chovají se jako SYNCED (lokální DIRTY koncept na nich neexistuje).
    final local = await _db
        .customSelect(
          spec.owned
              ? 'SELECT sync_state FROM ${spec.table} WHERE id = ?'
              : "SELECT 'SYNCED' AS sync_state FROM ${spec.table} WHERE id = ?",
          variables: [Variable.withString(item.entityId)],
        )
        .getSingleOrNull();

    if (local != null) {
      final syncState = local.data['sync_state']! as String;
      if (syncState != 'SYNCED') {
        // Nikdy tiše (PMS-001/DTS-005); řešení = existující C12 push flow.
        return PullApplyOutcome.conflictSkipped;
      }
      if (knownVersion != null && item.serverVersion <= knownVersion) {
        return PullApplyOutcome.noOp;
      }
    }

    // Tombstone (C44 §3): SYNCED řádek smazat, neexistující jen evidovat
    // verzi — žádné oživení (DTS-006); idempotentní (DTS-004).
    if (item.deleted) {
      if (local != null) {
        await _db.customStatement('DELETE FROM ${spec.table} WHERE id = ?', [
          item.entityId,
        ]);
      }
      await _storeVersion(item, nowMillis);
      return local != null
          ? PullApplyOutcome.appliedDelete
          : PullApplyOutcome.noOp;
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
        final ownerColumns = spec.owned ? 'owner_id, sync_state, ' : '';
        final ownerValues = spec.owned ? "?, 'SYNCED', " : '';
        final metaColumns = spec.timestamps ? 'created_at, updated_at, ' : '';
        final metaValues = spec.timestamps ? '?, ?, ' : '';
        await _db.customStatement(
          'INSERT INTO ${spec.table} '
          '(id, $ownerColumns$metaColumns${columns.join(', ')}) '
          'VALUES (?, $ownerValues$metaValues'
          '${List.filled(columns.length, '?').join(', ')})',
          [
            item.entityId,
            if (spec.owned) ownerId,
            if (spec.timestamps) ...[nowMillis, nowMillis],
            ...values.map((v) => v.value),
          ],
        );
      } else {
        final ownerSet = spec.owned ? "sync_state = 'SYNCED', " : '';
        final metaSet = spec.timestamps ? 'updated_at = ?, ' : '';
        await _db.customStatement(
          'UPDATE ${spec.table} SET '
          '$ownerSet$metaSet'
          '${columns.map((c) => '$c = ?').join(', ')} '
          'WHERE id = ?',
          [
            if (spec.timestamps) nowMillis,
            ...values.map((v) => v.value),
            item.entityId,
          ],
        );
      }
      if (item.entityType == 'WORKOUT_INSTANCE') {
        await _rebuildStructure(item);
      }
    } catch (_) {
      // Typované selhání řádku (PMS-009) — žádný částečný zápis (statement
      // je atomický), žádný pád běhu.
      return PullApplyOutcome.skippedDependency;
    }

    // Evidence server verze (PMS-006) — zdroj expectedServerVersion pro
    // push i no-op rozhodnutí dalšího pullu.
    await _storeVersion(item, nowMillis);
    return local == null
        ? PullApplyOutcome.appliedNew
        : PullApplyOutcome.appliedUpdate;
  }

  Future<void> _storeVersion(SyncPullItem item, int nowMillis) => _db
      .into(_db.localSyncedVersions)
      .insertOnConflictUpdate(
        LocalSyncedVersionsCompanion.insert(
          entityType: item.entityType,
          entityId: item.entityId,
          serverVersion: item.serverVersion,
          updatedAt: nowMillis,
        ),
      );

  /// Rekonstrukce struktury instance (C43 §3, WSS-004): celá a state-based
  /// — smazat lokální sekce (kaskáda odstraní kroky/sety) a vložit ze
  /// syrových sloupcových map. Chybějící `structure` = poctivý stav bez
  /// dopočtů (WSS-008).
  Future<void> _rebuildStructure(SyncPullItem item) async {
    final structure = item.payload['structure'];
    if (structure is! Map) {
      return;
    }
    await _db.customStatement(
      'DELETE FROM local_workout_sections WHERE workout_instance_id = ?',
      [item.entityId],
    );

    Future<void> insertRaw(String table, Map row) async {
      final columns = row.keys.cast<String>().toList();
      await _db.customStatement(
        'INSERT INTO $table (${columns.join(', ')}) '
        'VALUES (${List.filled(columns.length, '?').join(', ')})',
        [for (final column in columns) row[column]],
      );
    }

    final sections = (structure['sections'] as List?) ?? const [];
    for (final sectionRaw in sections.cast<Map>()) {
      final section = Map<String, Object?>.from(sectionRaw)..remove('steps');
      await insertRaw('local_workout_sections', section);
      for (final stepRaw
          in ((sectionRaw['steps'] as List?) ?? const []).cast<Map>()) {
        final step = Map<String, Object?>.from(stepRaw)..remove('setPlans');
        await insertRaw('local_workout_steps', step);
        for (final setPlan
            in ((stepRaw['setPlans'] as List?) ?? const []).cast<Map>()) {
          await insertRaw(
            'local_set_plans',
            Map<String, Object?>.from(setPlan),
          );
        }
      }
    }
  }
}
