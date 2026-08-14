import 'package:ai_trainer_mobile/core/database/tables/workout_tables.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_api_client.dart';
import 'package:ai_trainer_mobile/features/auth/domain/stored_auth_session.dart';
import 'package:ai_trainer_mobile/features/checkin/data/drift_daily_check_in_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/domain/daily_check_in.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/sync/application/pull_engine.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_sync_snapshot_repository.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_history_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_instance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R6-05 testy obnovy (C45): plná obnova na prázdné DB (struktura +
/// historie, DRS-004), přerušení + idempotentní dokončení (DRS-003),
/// tombstone se neobnoví (DTS-006), koexistence lokálních dat (DRS-005)
/// a beta krok 10 — dokončený workout viditelný v historii (DRS-012).
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

  /// „Zařízení A": plný profil + workout s cviky + dokončená session
  /// (historie) — server stav = jeho pending kolekce.
  Future<Map<String, List<SyncPullItem>>> buildServerState() async {
    final deviceA = createTestDatabase();
    final plans = DriftTrainingPlanRepository(deviceA);
    await plans.createPlan(title: 'Plán A', newId: 'p1', now: now);
    var seq = 0;
    final added =
        await plans.addWorkout(
              'p1',
              PlannedWorkoutInput(
                title: 'Silový A',
                workoutType: 'STRENGTH',
                scheduledLocalDate: formatLocalDate(now),
                exercises: const [
                  PlannedExerciseInput(title: 'Dřep', sets: 2, repetitions: 5),
                ],
              ),
              newId: () => 'a-${seq++}',
              now: now,
            )
            as PlanWriteSaved;
    final instanceId = added.id;
    await DriftDailyCheckInRepository(deviceA).saveForDate(
      formatLocalDate(now),
      const DailyCheckInInput(energyLevel: 4, fatigueLevel: 2),
      newId: 'ci1',
      now: now,
    );
    // Dokončená session s aktivitním summary (historie) — přímé řádky
    // odpovídající R1 zápisům.
    await deviceA.customStatement(
      "INSERT INTO local_workout_sessions (id, workout_instance_id, "
      "instance_revision_number, status, started_at, completed_at, "
      "elapsed_active_seconds, created_at, updated_at, row_version, "
      "owner_id, sync_state) VALUES ('ses1', '$instanceId', 1, 'COMPLETED', "
      "10, 20, 600, 10, 20, 2, 'local-anonymous', 'LOCAL_ONLY')",
    );
    await deviceA.customStatement(
      "INSERT INTO local_activity_summaries (id, workout_instance_id, "
      "workout_session_id, title_snapshot, workout_type, started_at, "
      "completed_at, active_duration_seconds, completed_step_count, "
      "total_step_count, created_at, owner_id, sync_state) VALUES "
      "('sum1', '$instanceId', 'ses1', 'Silový A', 'STRENGTH', 10, 20, "
      "600, 1, 1, 20, 'local-anonymous', 'LOCAL_ONLY')",
    );

    final planned = await DriftSyncSnapshotRepository(
      deviceA,
    ).collectPendingEntities(localAnonymousOwnerId);
    await deviceA.close();
    final serverState = <String, List<SyncPullItem>>{};
    for (final entity in planned) {
      serverState
          .putIfAbsent(entity.entityType, () => [])
          .add(
            SyncPullItem(
              entityType: entity.entityType,
              entityId: entity.entityId,
              serverVersion: 1,
              payload: entity.payload,
            ),
          );
    }
    return serverState;
  }

  test('plná obnova na prázdné DB: struktura + historie + read modely; '
      'druhý běh no-op; tombstone se neobnoví; lokální data přežijí', () async {
    final serverState = await buildServerState();
    // Tombstonovaná availability na serveru (DTS-006).
    serverState['AVAILABILITY_RULE'] = [
      const SyncPullItem(
        entityType: 'AVAILABILITY_RULE',
        entityId: 'rule-deleted',
        serverVersion: 2,
        payload: {'dayOfWeek': 'MON', 'level': 'AVAILABLE'},
        deleted: true,
      ),
    ];

    final deviceB = createTestDatabase();
    addTearDown(deviceB.close);
    // Lokální anonymní data nového zařízení (přežijí, DRS-005).
    await DriftDailyCheckInRepository(deviceB).saveForDate(
      formatLocalDate(now.subtract(const Duration(days: 1))),
      const DailyCheckInInput(energyLevel: 2, fatigueLevel: 4),
      newId: 'local-ci',
      now: now,
    );

    final api = FakeSyncApiClient()..pullServerItems.addAll(serverState);
    final storage = InMemorySecureSessionStorage()..stored = session();
    final engine = PullEngine(
      deviceB,
      storage,
      FakeInstallationIdentity('inst-restore'),
      api,
    );

    final result = await engine.pullChanges(now: now);
    expect(result, isA<PullRunCompleted>());
    final completed = result as PullRunCompleted;
    expect(completed.conflictSkipped, 0);
    expect(completed.skippedDependency, 0);

    // Úplnost (DRS-004): plán, instance se strukturou, historie, check-in.
    Future<int> count(String sql) async =>
        (await deviceB.customSelect(sql).getSingle()).data.values.first as int;
    expect(await count('SELECT COUNT(*) AS c FROM local_training_plans'), 1);
    expect(await count('SELECT COUNT(*) AS c FROM local_workout_instances'), 1);
    expect(await count('SELECT COUNT(*) AS c FROM local_workout_sections'), 1);
    expect(await count('SELECT COUNT(*) AS c FROM local_set_plans'), 2);
    expect(await count('SELECT COUNT(*) AS c FROM local_workout_sessions'), 1);
    expect(
      await count('SELECT COUNT(*) AS c FROM local_activity_summaries'),
      1,
    );
    // Check-iny: serverový + lokální anonymní přežil (DRS-005).
    expect(await count('SELECT COUNT(*) AS c FROM local_daily_check_ins'), 2);
    // Tombstone se neobnovil (DTS-006).
    expect(
      await count('SELECT COUNT(*) AS c FROM local_availability_rules'),
      0,
    );

    // Beta krok 10: dokončený workout je v historii read modelu (DRS-012).
    final history = await DriftWorkoutHistoryRepository(
      deviceB,
    ).completedWorkouts();
    expect(history.single.title, 'Silový A');
    // Today read model vidí obnovený workout.
    final today = await DriftWorkoutInstanceRepository(
      deviceB,
    ).workoutsForLocalDate(formatLocalDate(now));
    expect(today.map((w) => w.title), contains('Silový A'));

    // Idempotence (DRS-003): druhý běh nic neaplikuje.
    final second = await engine.pullChanges(now: now);
    expect((second as PullRunCompleted).applied, 0);
  });

  test('přerušení uprostřed: typovaná nedostupnost, kurzory drží průběh a '
      'dokončení je idempotentní bez duplicit (DRS-003)', () async {
    final serverState = await buildServerState();
    final deviceB = createTestDatabase();
    addTearDown(deviceB.close);
    final api = _InterruptingApi(
      FakeSyncApiClient()
        ..pullServerItems.addAll(serverState)
        ..pullBatchLimit = 2,
      failAfterCalls: 2,
    );
    final storage = InMemorySecureSessionStorage()..stored = session();
    final engine = PullEngine(
      deviceB,
      storage,
      FakeInstallationIdentity('inst-restore'),
      api,
    );

    // Přerušený běh = typovaná nedostupnost; část dat už je aplikovaná
    // a kurzory ji drží (PMS-010).
    expect(await engine.pullChanges(now: now), isA<PullUnavailable>());
    Future<int> count(String sql) async =>
        (await deviceB.customSelect(sql).getSingle()).data.values.first as int;
    final partial = await count(
      "SELECT COUNT(*) AS c FROM local_app_state WHERE key LIKE 'pull_cursor_%'",
    );
    expect(partial, greaterThan(0));

    // Obnovené spojení: dokončení bez duplicit (DRS-003).
    api.failAfterCalls = null;
    final resumed = await engine.pullChanges(now: now);
    expect(resumed, isA<PullRunCompleted>());
    expect(await count('SELECT COUNT(*) AS c FROM local_training_plans'), 1);
    expect(await count('SELECT COUNT(*) AS c FROM local_workout_instances'), 1);
    expect(await count('SELECT COUNT(*) AS c FROM local_workout_sessions'), 1);
    // Třetí běh je čistý no-op.
    final third = await engine.pullChanges(now: now);
    expect((third as PullRunCompleted).applied, 0);
  });
}

/// Delegující fake simulující výpadek po N voláních (přerušený restore).
class _InterruptingApi implements SyncApiClient {
  _InterruptingApi(this._delegate, {required this.failAfterCalls});

  final FakeSyncApiClient _delegate;
  int? failAfterCalls;
  int _calls = 0;

  @override
  Future<List<SyncItemOutcome>> push({
    required String accessToken,
    required String installationId,
    required List<SyncPushOperation> operations,
  }) => _delegate.push(
    accessToken: accessToken,
    installationId: installationId,
    operations: operations,
  );

  @override
  Future<SyncPullResponse> pull({
    required String accessToken,
    required String installationId,
    required Map<String, String?> cursors,
    int? limit,
  }) {
    _calls++;
    final threshold = failAfterCalls;
    if (threshold != null && _calls > threshold) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
    return _delegate.pull(
      accessToken: accessToken,
      installationId: installationId,
      cursors: cursors,
      limit: limit,
    );
  }
}
