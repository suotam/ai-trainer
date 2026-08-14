import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/tables/workout_tables.dart';
import 'package:ai_trainer_mobile/features/sync/application/pull_engine.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_pull_applier.dart';
import 'package:ai_trainer_mobile/features/auth/domain/stored_auth_session.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R6-02 testy pull merge (C42): merge matice §3 (insert/update/no-op/
/// konflikt), idempotence, kurzor persistence s posunem až po aplikaci
/// (PMS-010), anonymní skip a typovaná nedostupnost (PMS-012).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 12);

  StoredAuthSession storedSession(DateTime at) => StoredAuthSession(
    accountId: 'account-1',
    sessionId: 'session-1',
    accessToken: 'access-token',
    accessExpiresAt: at.add(const Duration(minutes: 15)),
    refreshToken: 'refresh-token',
    refreshExpiresAt: at.add(const Duration(days: 30)),
  );

  SyncPullItem sportItem({int version = 1, String role = 'PRIMARY'}) =>
      SyncPullItem(
        entityType: 'USER_SPORT',
        entityId: 'sport-1',
        serverVersion: version,
        payload: {
          'sportCode': 'CLIMBING',
          'role': role,
          'priority': 'HIGH',
          'experienceLevel': 'INTERMEDIATE',
          'status': 'ACTIVE',
          'rowVersion': version,
        },
      );

  Future<void> setOwner(AppDatabase db, String owner) => db
      .into(db.localAppState)
      .insertOnConflictUpdate(
        LocalAppStateCompanion.insert(
          key: localOwnerStateKey,
          value: owner,
          updatedAt: 0,
        ),
      );

  test('merge matice: insert se SYNCED a ownerem, update vyšší verzí, '
      'no-op stejné verze, DIRTY nikdy tiše (PMS-001/002/005/006)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final applier = DriftPullApplier(db);

    // 1. Neexistující řádek → INSERT (SYNCED, owner účtu).
    expect(
      await applier.apply('account-1', sportItem(), now: now),
      PullApplyOutcome.appliedNew,
    );
    final inserted = await db
        .customSelect(
          "SELECT owner_id, sync_state, role, row_version "
          "FROM local_user_sports WHERE id = 'sport-1'",
        )
        .getSingle();
    expect(inserted.data['owner_id'], 'account-1');
    expect(inserted.data['sync_state'], 'SYNCED');
    expect(inserted.data['role'], 'PRIMARY');

    // 2. Idempotence: stejná verze → no-op (PMS-002).
    expect(
      await applier.apply('account-1', sportItem(), now: now),
      PullApplyOutcome.noOp,
    );

    // 3. Vyšší server verze → UPDATE, stále SYNCED (PMS-005).
    expect(
      await applier.apply(
        'account-1',
        sportItem(version: 2, role: 'SECONDARY'),
        now: now,
      ),
      PullApplyOutcome.appliedUpdate,
    );
    final updated = await db
        .customSelect(
          "SELECT role, sync_state FROM local_user_sports WHERE id = 'sport-1'",
        )
        .getSingle();
    expect(updated.data['role'], 'SECONDARY');
    expect(updated.data['sync_state'], 'SYNCED');
    final version = await db
        .customSelect(
          "SELECT server_version FROM local_synced_versions "
          "WHERE entity_type = 'USER_SPORT' AND entity_id = 'sport-1'",
        )
        .getSingle();
    expect(version.data['server_version'], 2);

    // 4. Lokální DIRTY → nikdy tiše (PMS-001): data beze změny.
    await db.customStatement(
      "UPDATE local_user_sports SET sync_state = 'DIRTY', role = 'PRIMARY' "
      "WHERE id = 'sport-1'",
    );
    expect(
      await applier.apply(
        'account-1',
        sportItem(version: 3, role: 'RECREATIONAL'),
        now: now,
      ),
      PullApplyOutcome.conflictSkipped,
    );
    final conflicted = await db
        .customSelect(
          "SELECT role, sync_state FROM local_user_sports WHERE id = 'sport-1'",
        )
        .getSingle();
    expect(conflicted.data['role'], 'PRIMARY');
    expect(conflicted.data['sync_state'], 'DIRTY');

    // Chybějící FK prerekvizita → typovaný dependency skip (PMS-009).
    expect(
      await applier.apply(
        'account-1',
        const SyncPullItem(
          entityType: 'GOAL',
          entityId: 'goal-1',
          serverVersion: 1,
          payload: {
            'title': 'Cíl',
            'goalType': 'PERFORMANCE',
            'priority': 'PRIMARY',
            'status': 'ACTIVE',
            'userSportId': 'missing-sport',
            'rowVersion': 1,
          },
        ),
        now: now,
      ),
      PullApplyOutcome.skippedDependency,
    );
  });

  test('engine: kurzory se persistují a posouvají, druhý běh je no-op; '
      'stránkování konverguje (PMS-010, C42 §4)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    await setOwner(db, 'account-1');
    final api = FakeSyncApiClient()
      ..pullBatchLimit = 2
      ..pullServerItems['USER_SPORT'] = [sportItem()]
      ..pullServerItems['TRAINING_PLAN'] = [
        const SyncPullItem(
          entityType: 'TRAINING_PLAN',
          entityId: 'plan-1',
          serverVersion: 1,
          payload: {
            'title': 'Obnovený plán',
            'status': 'ACTIVE',
            'origin': 'MANUAL',
            'rowVersion': 1,
          },
        ),
      ]
      ..pullServerItems['DAILY_CHECK_IN'] = [
        const SyncPullItem(
          entityType: 'DAILY_CHECK_IN',
          entityId: 'ci-1',
          serverVersion: 1,
          payload: {
            'localDate': '2026-08-13',
            'energyLevel': 4,
            'fatigueLevel': 2,
            'rowVersion': 1,
          },
        ),
      ];
    final storage = InMemorySecureSessionStorage()..stored = storedSession(now);
    final engine = PullEngine(
      db,
      storage,
      FakeInstallationIdentity('inst-pull'),
      api,
    );

    final result = await engine.pullChanges(now: now);
    expect(result, isA<PullRunCompleted>());
    expect((result as PullRunCompleted).applied, 3);
    expect(result.conflictSkipped, 0);
    // Stránkování: batch limit 2 → víc než jedno kolo (hasMore konverguje).
    expect(api.pullCalls, greaterThan(1));

    // Kurzory persistované (PMS-010).
    final cursor = await db
        .customSelect(
          "SELECT value FROM local_app_state WHERE key = 'pull_cursor_USER_SPORT'",
        )
        .getSingle();
    expect(cursor.data['value'], '1');

    // Druhý běh je no-op — nic se neaplikuje znovu (PMS-002).
    final second = await engine.pullChanges(now: now);
    expect((second as PullRunCompleted).applied, 0);

    // Obnovená data jsou plnohodnotné lokální řádky.
    final plan = await db
        .customSelect(
          "SELECT title, sync_state, owner_id FROM local_training_plans "
          "WHERE id = 'plan-1'",
        )
        .getSingle();
    expect(plan.data['title'], 'Obnovený plán');
    expect(plan.data['sync_state'], 'SYNCED');
    expect(plan.data['owner_id'], 'account-1');
  });

  test('anonymní stav a nedostupnost jsou typované; kurzory se při selhání '
      'neposouvají (PMS-012)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final api = FakeSyncApiClient()
      ..pullServerItems['USER_SPORT'] = [sportItem()];

    // Anonymní = typovaný skip.
    final anonymous = PullEngine(
      db,
      InMemorySecureSessionStorage(),
      FakeInstallationIdentity('inst'),
      api,
    );
    expect(await anonymous.pullChanges(now: now), isA<PullSkippedAnonymous>());

    // Nedostupný server = typovaná nedostupnost, žádný kurzor.
    api.offline = true;
    final storage = InMemorySecureSessionStorage()..stored = storedSession(now);
    final engine = PullEngine(
      db,
      storage,
      FakeInstallationIdentity('inst'),
      api,
    );
    expect(await engine.pullChanges(now: now), isA<PullUnavailable>());
    final cursors = await db
        .customSelect(
          "SELECT COUNT(*) AS c FROM local_app_state WHERE key LIKE 'pull_cursor_%'",
        )
        .getSingle();
    expect(cursors.data['c'], 0);
  });
}
