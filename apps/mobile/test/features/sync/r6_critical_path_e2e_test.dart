import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/tables/workout_tables.dart';
import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/domain/stored_auth_session.dart';
import 'package:ai_trainer_mobile/features/availability/data/drift_availability_profile_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/data/drift_daily_check_in_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/domain/daily_check_in.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/sync/application/pull_engine.dart';
import 'package:ai_trainer_mobile/features/sync/application/sync_engine.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_local_sync_metadata_repository.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_sync_snapshot_repository.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_history_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R6-06 – kritický E2E důkaz hlavní hodnoty R6 (plán §9.6, §13): dvě
/// „zařízení" (dvě reálné SQLite DB) proti témuž fake serveru se sdíleným
/// stavem (R6P-013). Zařízení A pushne plnou doménovou pravdu vč. struktury
/// workoutů a DELETE tombstonu → zařízení B se obnoví restore pullem →
/// **identická doménová pravda po tabulkách** → R1 flow na obnoveném
/// workoutu → idempotence oběma směry (opakovaný push i pull no-op).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 12);

  StoredAuthSession session() => StoredAuthSession(
    accountId: 'account-1',
    sessionId: 'session-1',
    accessToken: 'access-token',
    accessExpiresAt: now.add(const Duration(minutes: 15)),
    refreshToken: 'refresh-token',
    refreshExpiresAt: now.add(const Duration(days: 30)),
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

  SyncEngine pushEngine(
    AppDatabase db,
    InMemorySecureSessionStorage storage,
    FakeSyncApiClient api,
  ) => SyncEngine(
    storage,
    FakeInstallationIdentity('inst-e2e'),
    DriftLocalSyncMetadataRepository(db, _FixedIds()),
    DriftSyncSnapshotRepository(db),
    api,
    () => now,
  );

  Future<List<Map<String, Object?>>> dump(AppDatabase db, String table) async =>
      [
        for (final row
            in await db.customSelect('SELECT * FROM $table ORDER BY id').get())
          Map<String, Object?>.from(row.data),
      ];

  test('R6 E2E: zařízení A → push (struktura + delete) → zařízení B → '
      'restore → identická doménová pravda → R1 flow → oboustranná '
      'idempotence', () async {
    final server = _SharedStateServer();
    final storage = InMemorySecureSessionStorage()..stored = session();

    // ── Zařízení A: plná doménová pravda přihlášeného účtu.
    final deviceA = createTestDatabase();
    addTearDown(deviceA.close);
    await setOwner(deviceA, 'account-1');

    final plans = DriftTrainingPlanRepository(deviceA);
    await plans.createPlan(title: 'Plán A', newId: 'p1', now: now);
    var seq = 0;
    String nextId() => 'a-${seq++}';
    final workoutDone =
        await plans.addWorkout(
              'p1',
              PlannedWorkoutInput(
                title: 'Silový A',
                workoutType: 'STRENGTH',
                scheduledLocalDate: formatLocalDate(now),
                plannedDurationMinutes: 60,
                exercises: const [
                  PlannedExerciseInput(
                    title: 'Dřep',
                    sets: 2,
                    repetitions: 5,
                    weightKg: 80,
                  ),
                ],
              ),
              newId: nextId,
              now: now,
            )
            as PlanWriteSaved;
    final workoutFresh =
        await plans.addWorkout(
              'p1',
              PlannedWorkoutInput(
                title: 'Mobilita B',
                workoutType: 'MOBILITY',
                scheduledLocalDate: formatLocalDate(
                  now.add(const Duration(days: 1)),
                ),
                exercises: const [
                  PlannedExerciseInput(title: 'Kočka', sets: 1, repetitions: 8),
                ],
              ),
              newId: nextId,
              now: now,
            )
            as PlanWriteSaved;

    final availability = DriftAvailabilityProfileRepository(deviceA);
    await availability.upsertDay(
      dayOfWeek: 'MON',
      level: 'AVAILABLE',
      newId: 'rule-mon',
      now: now,
    );
    await availability.upsertDay(
      dayOfWeek: 'TUE',
      level: 'LIMITED',
      newId: 'rule-tue',
      now: now,
    );
    await DriftDailyCheckInRepository(deviceA).saveForDate(
      formatLocalDate(now),
      const DailyCheckInInput(energyLevel: 4, fatigueLevel: 2),
      newId: 'ci1',
      now: now,
    );
    // Dokončený běh „Silový A" — historie (řádky odpovídající R1 zápisům).
    await deviceA.customStatement(
      "INSERT INTO local_workout_sessions (id, workout_instance_id, "
      "instance_revision_number, status, started_at, completed_at, "
      "elapsed_active_seconds, created_at, updated_at, row_version, "
      "owner_id, sync_state) VALUES ('ses1', '${workoutDone.id}', 1, "
      "'COMPLETED', 10, 20, 600, 10, 20, 2, 'account-1', 'LOCAL_ONLY')",
    );
    await deviceA.customStatement(
      "INSERT INTO local_activity_summaries (id, workout_instance_id, "
      "workout_session_id, title_snapshot, workout_type, started_at, "
      "completed_at, active_duration_seconds, completed_step_count, "
      "total_step_count, created_at, owner_id, sync_state) VALUES "
      "('sum1', '${workoutDone.id}', 'ses1', 'Silový A', 'STRENGTH', 10, "
      "20, 600, 1, 1, 20, 'account-1', 'LOCAL_ONLY')",
    );

    // Push 1: vše vč. struktury workoutů (C43) na sdílený server.
    final engineA = pushEngine(deviceA, storage, server);
    final firstPush = await engineA.pushPending();
    expect(firstPush, isA<SyncRunCompleted>());
    final firstCompleted = firstPush as SyncRunCompleted;
    expect(firstCompleted.conflicts + firstCompleted.rejected, 0);
    expect(firstCompleted.pending, 0);

    // Lokální zpětvzetí serverem známého pravidla → DELETE záměr (C44);
    // push 2 ho doručí jako tombstone.
    await availability.removeDay('MON');
    final deletePush = await engineA.pushPending();
    expect(deletePush, isA<SyncRunCompleted>());
    final tombstones = server.pullServerItems['AVAILABILITY_RULE']!
        .where((item) => item.deleted)
        .toList();
    expect(tombstones.single.entityId, 'rule-mon');

    // Push idempotence: třetí běh nemá co odeslat.
    final pushedBatchesBefore = server.pushedBatches.length;
    final idlePush = await engineA.pushPending() as SyncRunCompleted;
    expect(idlePush.synced, 0);
    expect(server.pushedBatches.length, pushedBatchesBefore);

    // ── Zařízení B: čistá instalace + přihlášení (owner binding) →
    // restore (C45).
    final deviceB = createTestDatabase();
    addTearDown(deviceB.close);
    await setOwner(deviceB, 'account-1');
    final pullB = PullEngine(
      deviceB,
      storage,
      FakeInstallationIdentity('inst-e2e-b'),
      server,
    );
    final restore = await pullB.pullChanges(now: now);
    expect(restore, isA<PullRunCompleted>());
    final restored = restore as PullRunCompleted;
    expect(restored.conflictSkipped, 0);
    expect(restored.skippedDependency, 0);

    // Identická doménová pravda: obnovené tabulky se rovnají zařízení A
    // řádek po řádku (vč. struktury; smazané pravidlo chybí na obou).
    for (final table in [
      'local_training_plans',
      'local_workout_instances',
      'local_workout_sections',
      'local_workout_steps',
      'local_set_plans',
      'local_availability_rules',
      'local_daily_check_ins',
      'local_workout_sessions',
      'local_activity_summaries',
    ]) {
      expect(
        await dump(deviceB, table),
        await dump(deviceA, table),
        reason: table,
      );
    }
    // Tombstone se neoživil (DTS-006) a přeživší pravidlo je jediné.
    final rules = await dump(deviceB, 'local_availability_rules');
    expect(rules.single['id'], 'rule-tue');
    // Historie čte obnovenou pravdu (beta krok 10).
    final history = await DriftWorkoutHistoryRepository(
      deviceB,
    ).completedWorkouts();
    expect(history.single.title, 'Silový A');

    // R1 flow na obnoveném workoutu: start session nad rekonstruovanou
    // strukturou (cross-slice invariant 6).
    expect(
      await DriftWorkoutSessionRepository(deviceB).startSession(
        workoutInstanceId: workoutFresh.id,
        newSessionId: 'ses-b-1',
        now: now,
      ),
      isA<SessionCreated>(),
    );

    // Oboustranná idempotence: opakovaný pull na B je no-op. První pull na
    // A běží od prázdných kurzorů — overlap je dovolen (invariant 9: smí
    // vést jen k nadbytečné idempotentní aplikaci, nikdy ke ztrátě dat) —
    // doménová pravda A se nesmí změnit a opakovaný pull už je čistý no-op.
    final secondRestore = await pullB.pullChanges(now: now);
    expect((secondRestore as PullRunCompleted).applied, 0);
    final truthBefore = {
      for (final table in ['local_availability_rules', 'local_training_plans'])
        table: await dump(deviceA, table),
    };
    final pullA = PullEngine(
      deviceA,
      storage,
      FakeInstallationIdentity('inst-e2e'),
      server,
    );
    final selfPull = await pullA.pullChanges(now: now);
    expect((selfPull as PullRunCompleted).conflictSkipped, 0);
    for (final entry in truthBefore.entries) {
      expect(await dump(deviceA, entry.key), entry.value, reason: entry.key);
    }
    final selfPullAgain = await pullA.pullChanges(now: now);
    expect((selfPullAgain as PullRunCompleted).applied, 0);
    final pushBIdle =
        await pushEngine(deviceB, storage, server).pushPending()
            as SyncRunCompleted;
    // Nesynchronizovaná lokální pravda B je jen nová R1 session z tohoto
    // testu (její performance vrstva a jí mutovaná instance workoutu) —
    // nic z obnovených, nezměněných entit se znovu neodesílá.
    final lastBatch = server.pushedBatches.isEmpty
        ? const <SyncPushOperation>[]
        : server.pushedBatches.last;
    const restoredUntouched = {'p1', 'ci1', 'ses1', 'sum1', 'rule-tue'};
    expect(
      lastBatch.where(
        (op) =>
            restoredUntouched.contains(op.entityId) ||
            op.entityId == workoutDone.id,
      ),
      isEmpty,
      reason: 'obnovená nezměněná data se nesmí znovu pushovat',
    );
    expect(lastBatch.map((op) => op.entityId), contains('ses-b-1'));
    expect(pushBIdle.conflicts + pushBIdle.rejected, 0);
  });
}

/// Fake server se sdíleným stavem (R6P-013): úspěšný push se stává pull
/// pravdou — položky per typ v pořadí vzniku, DELETE_ENTITY jako tombstone.
class _SharedStateServer extends FakeSyncApiClient {
  @override
  Future<List<SyncItemOutcome>> push({
    required String accessToken,
    required String installationId,
    required List<SyncPushOperation> operations,
  }) async {
    final outcomes = await super.push(
      accessToken: accessToken,
      installationId: installationId,
      operations: operations,
    );
    for (var i = 0; i < operations.length; i++) {
      final op = operations[i];
      final outcome = outcomes[i];
      if (outcome.result == 'SUCCESS') {
        pullServerItems
            .putIfAbsent(op.entityType, () => [])
            .add(
              SyncPullItem(
                entityType: op.entityType,
                entityId: op.entityId,
                serverVersion: outcome.serverVersion!,
                payload: op.payload,
                deleted: op.operationType == 'DELETE_ENTITY',
              ),
            );
      }
    }
    return outcomes;
  }
}

class _FixedIds implements IdGenerator {
  int _next = 0;

  @override
  String newId() => 'e2e-id-${_next++}';
}
