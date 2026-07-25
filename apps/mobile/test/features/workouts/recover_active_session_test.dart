import 'package:ai_trainer_mobile/features/workouts/application/recover_active_session.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_recovery_result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// Rozhodovací matice recovery aktivní session (VSP §16, fyzický model §19,
/// PDR-012) — bez widgetů a bez sítě (QTR-003).
void main() {
  final now = DateTime.utc(2026, 7, 20, 9);

  RecoverActiveSession useCase(
    FakeWorkoutSessionRepository sessions,
    FakeWorkoutPerformanceRepository performances,
  ) => RecoverActiveSession(
    sessionRepository: sessions,
    performanceRepository: performances,
    clock: () => now,
  );

  test('bez aktivní session a bez pointeru → NoActiveSession', () async {
    final sessions = FakeWorkoutSessionRepository();
    final perf = FakeWorkoutPerformanceRepository();

    final result = await useCase(sessions, perf).call();

    expect(result, isA<NoActiveSessionRecovery>());
    expect(perf.initCallCount, 0);
    expect(sessions.reconcileCallCount, 0);
  });

  test('jedna aktivní session a pointer souhlasí → recovered', () async {
    final session = buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1');
    final sessions = FakeWorkoutSessionRepository(
      activeSessions: [session],
      activePointer: 'ses-1',
    );
    final perf = FakeWorkoutPerformanceRepository();

    final result = await useCase(sessions, perf).call();

    expect(result, isA<ActiveSessionRecovered>());
    expect((result as ActiveSessionRecovered).session.id, 'ses-1');
    // Idempotentní init proběhne; pointer souhlasí → žádná oprava.
    expect(perf.initCallCount, 1);
    expect(sessions.reconcileCallCount, 0);
  });

  test(
    'jedna aktivní session a chybějící pointer → recovered po opravě',
    () async {
      final session = buildSessionSnapshot(
        id: 'ses-1',
        workoutInstanceId: 'wi1',
      );
      final sessions = FakeWorkoutSessionRepository(
        activeSessions: [session],
        activePointer: null,
      );
      final perf = FakeWorkoutPerformanceRepository();

      final result = await useCase(sessions, perf).call();

      expect(result, isA<ActiveSessionRecoveredAfterRepair>());
      expect(sessions.reconcileCallCount, 1);
      expect(sessions.activePointer, 'ses-1');
    },
  );

  test('pointer ukazuje na jinou session → recovered po opravě', () async {
    final session = buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1');
    final sessions = FakeWorkoutSessionRepository(
      activeSessions: [session],
      activePointer: 'stale-id',
    );
    final perf = FakeWorkoutPerformanceRepository();

    final result = await useCase(sessions, perf).call();

    expect(result, isA<ActiveSessionRecoveredAfterRepair>());
    expect(sessions.reconcileCallCount, 1);
    expect(sessions.activePointer, 'ses-1');
  });

  test(
    'aktivní session s chybějící instancí → inconsistent (missingInstance)',
    () async {
      final session = buildSessionSnapshot(
        id: 'ses-1',
        workoutInstanceId: 'gone',
      );
      final sessions = FakeWorkoutSessionRepository(
        activeSessions: [session],
        activePointer: 'ses-1',
        existingInstanceIds: const {}, // žádná instance neexistuje
      );
      final perf = FakeWorkoutPerformanceRepository();

      final result = await useCase(sessions, perf).call();

      expect(result, isA<InconsistentActiveSessionRecovery>());
      expect(
        (result as InconsistentActiveSessionRecovery).reason,
        RecoveryInconsistencyReason.missingInstance,
      );
      // Nekonzistentní snapshot → žádná performance inicializace.
      expect(perf.initCallCount, 0);
    },
  );

  test(
    'více aktivních sessions → MultipleActiveSessions bez destrukce',
    () async {
      final sessions = FakeWorkoutSessionRepository(
        activeSessions: [
          buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1'),
          buildSessionSnapshot(id: 'ses-2', workoutInstanceId: 'wi2'),
        ],
        activePointer: 'ses-1',
      );
      final perf = FakeWorkoutPerformanceRepository();

      final result = await useCase(sessions, perf).call();

      expect(result, isA<MultipleActiveSessionsRecovery>());
      expect((result as MultipleActiveSessionsRecovery).count, 2);
      // Žádná automatická oprava ani init při konfliktu.
      expect(sessions.reconcileCallCount, 0);
      expect(perf.initCallCount, 0);
    },
  );

  test(
    'osiřelý pointer bez aktivní session → inconsistent (orphanPointer)',
    () async {
      final sessions = FakeWorkoutSessionRepository(
        activeSessions: const [],
        activePointer: 'ghost',
      );
      final perf = FakeWorkoutPerformanceRepository();

      final result = await useCase(sessions, perf).call();

      expect(result, isA<InconsistentActiveSessionRecovery>());
      expect(
        (result as InconsistentActiveSessionRecovery).reason,
        RecoveryInconsistencyReason.orphanPointer,
      );
      // Osiřelý pointer se nemaže (žádný destruktivní self-healing).
      expect(sessions.activePointer, 'ghost');
    },
  );

  test('raw persistence výjimka → UnrecoverableRecovery (bez úniku)', () async {
    final sessions = FakeWorkoutSessionRepository(
      throwOnFindActiveSessions: true,
    );
    final perf = FakeWorkoutPerformanceRepository();

    final result = await useCase(sessions, perf).call();

    expect(result, isA<UnrecoverableRecovery>());
  });
}
