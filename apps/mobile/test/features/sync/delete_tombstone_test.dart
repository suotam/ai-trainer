import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/tables/workout_tables.dart';
import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/features/auth/domain/stored_auth_session.dart';
import 'package:ai_trainer_mobile/features/availability/data/drift_availability_profile_repository.dart';
import 'package:ai_trainer_mobile/features/sync/application/sync_engine.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_local_sync_metadata_repository.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_pull_applier.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_sync_snapshot_repository.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R6-04 testy tombstonů (C44): lokální DELETE záměr atomicky se smazáním
/// (DTS-007/008), push dispatch DELETE_ENTITY (DTS-009), pull aplikace
/// tombstonu (SYNCED smazán, DIRTY nikdy tiše, absent bez oživení —
/// DTS-004/005/006).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 12);

  Future<void> setOwner(AppDatabase db, String owner) => db
      .into(db.localAppState)
      .insertOnConflictUpdate(
        LocalAppStateCompanion.insert(
          key: localOwnerStateKey,
          value: owner,
          updatedAt: 0,
        ),
      );

  test('zpětvzetí známého řádku vytvoří DELETE záměr atomicky; LOCAL_ONLY '
      'se maže jen lokálně (DTS-007/008)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    await setOwner(db, 'account-1');
    final availability = DriftAvailabilityProfileRepository(db);

    // Serverem známý řádek (evidovaná verze) → záměr.
    await availability.upsertDay(
      dayOfWeek: 'MON',
      level: 'AVAILABLE',
      newId: 'rule-known',
      now: now,
    );
    await db.customStatement(
      "INSERT INTO local_synced_versions (entity_type, entity_id, "
      "server_version, updated_at) VALUES ('AVAILABILITY_RULE', "
      "'rule-known', 3, 0)",
    );
    // LOCAL_ONLY řádek bez verze → žádný záměr.
    await availability.upsertDay(
      dayOfWeek: 'TUE',
      level: 'LIMITED',
      newId: 'rule-local',
      now: now,
    );

    await availability.removeDay('MON');
    await availability.removeDay('TUE');

    final intents = await db
        .customSelect(
          "SELECT entity_id, operation_type, status, idempotency_key "
          "FROM local_outbox WHERE operation_type = 'DELETE'",
        )
        .get();
    expect(intents, hasLength(1));
    expect(intents.single.data['entity_id'], 'rule-known');
    expect(intents.single.data['status'], 'PENDING');
    expect(
      intents.single.data['idempotency_key'],
      'DELETE:AVAILABILITY_RULE:rule-known:v3',
    );
    final rules = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_availability_rules')
        .getSingle();
    expect(rules.data['c'], 0);

    // Push dispatch (DTS-009): DELETE_ENTITY bez payloadu s verzí.
    final storage = InMemorySecureSessionStorage()
      ..stored = StoredAuthSession(
        accountId: 'account-1',
        sessionId: 'session-1',
        accessToken: 'access-token',
        accessExpiresAt: now.add(const Duration(minutes: 15)),
        refreshToken: 'refresh-token',
        refreshExpiresAt: now.add(const Duration(days: 30)),
      );
    final api = FakeSyncApiClient();
    final engine = SyncEngine(
      storage,
      FakeInstallationIdentity('inst-del'),
      DriftLocalSyncMetadataRepository(db, _FixedIds()),
      DriftSyncSnapshotRepository(db),
      api,
      () => now,
    );
    final result = await engine.pushPending();
    expect(result, isA<SyncRunCompleted>());
    final deleteOp = api.pushedBatches.single.singleWhere(
      (op) => op.operationType == 'DELETE_ENTITY',
    );
    expect(deleteOp.entityType, 'AVAILABILITY_RULE');
    expect(deleteOp.entityId, 'rule-known');
    expect(deleteOp.payload, isEmpty);
    expect(deleteOp.expectedServerVersion, 3);
    final closed = await db
        .customSelect(
          "SELECT status FROM local_outbox WHERE operation_type = 'DELETE'",
        )
        .getSingle();
    expect(closed.data['status'], 'SYNCED');
  });

  test('pull tombstone matice: SYNCED smazán, DIRTY nikdy tiše, absent bez '
      'oživení; idempotence (DTS-004/005/006)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final applier = DriftPullApplier(db);

    SyncPullItem tombstone({int version = 2}) => SyncPullItem(
      entityType: 'AVAILABILITY_RULE',
      entityId: 'rule-1',
      serverVersion: version,
      payload: const {'dayOfWeek': 'MON', 'level': 'AVAILABLE'},
      deleted: true,
    );

    // Absent → jen evidence verze, žádné oživení (DTS-006).
    expect(
      await applier.apply('account-1', tombstone(), now: now),
      PullApplyOutcome.noOp,
    );
    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_availability_rules')
        .getSingle();
    expect(count.data['c'], 0);

    // SYNCED řádek → tombstone ho smaže (DTS-004 aplikace).
    await db.customStatement(
      "INSERT INTO local_availability_rules (id, day_of_week, level, "
      "created_at, updated_at, row_version, owner_id, sync_state) VALUES "
      "('rule-1', 'MON', 'AVAILABLE', 0, 0, 1, 'account-1', 'SYNCED')",
    );
    expect(
      await applier.apply('account-1', tombstone(version: 3), now: now),
      PullApplyOutcome.appliedDelete,
    );
    final afterDelete = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_availability_rules')
        .getSingle();
    expect(afterDelete.data['c'], 0);
    // Idempotence: opakovaná aplikace téže verze = no-op.
    expect(
      await applier.apply('account-1', tombstone(version: 3), now: now),
      PullApplyOutcome.noOp,
    );

    // DIRTY lokální pravda → nikdy tiše (DTS-005).
    await db.customStatement(
      "INSERT INTO local_availability_rules (id, day_of_week, level, "
      "created_at, updated_at, row_version, owner_id, sync_state) VALUES "
      "('rule-1', 'MON', 'LIMITED', 0, 0, 2, 'account-1', 'DIRTY')",
    );
    expect(
      await applier.apply('account-1', tombstone(version: 4), now: now),
      PullApplyOutcome.conflictSkipped,
    );
    final survived = await db
        .customSelect(
          "SELECT level FROM local_availability_rules WHERE id = 'rule-1'",
        )
        .getSingle();
    expect(survived.data['level'], 'LIMITED');
  });
}

class _FixedIds implements IdGenerator {
  int _next = 0;

  @override
  String newId() => 'id-${_next++}';
}
