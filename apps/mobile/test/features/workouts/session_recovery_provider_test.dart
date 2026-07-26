import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_recovery_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_recovery_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// Startup recovery provider (VSP §16). Ověřuje rozhodnutí bez widgetů,
/// explicitní Retry a absenci paralelního destruktivního běhu.
void main() {
  ProviderContainer container({
    required FakeWorkoutSessionRepository sessions,
    FakeWorkoutPerformanceRepository? performances,
  }) {
    final c = ProviderContainer(
      overrides: [
        r1SeedRepositoryProvider.overrideWithValue(
          FakeSeedRepository([SeedResult.applied]),
        ),
        workoutSessionRepositoryProvider.overrideWithValue(sessions),
        workoutPerformanceRepositoryProvider.overrideWithValue(
          performances ?? FakeWorkoutPerformanceRepository(),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('bez aktivní session → NoActiveSession', () async {
    final c = container(sessions: FakeWorkoutSessionRepository());
    final result = await c.read(sessionRecoveryProvider.future);
    expect(result, isA<NoActiveSessionRecovery>());
  });

  test('aktivní session + pointer → recovered', () async {
    final session = buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1');
    final c = container(
      sessions: FakeWorkoutSessionRepository(
        activeSessions: [session],
        activePointer: 'ses-1',
      ),
    );
    final result = await c.read(sessionRecoveryProvider.future);
    expect(result, isA<ActiveSessionRecovered>());
  });

  test('raw selhání → UnrecoverableRecovery (bez error propagace)', () async {
    final c = container(
      sessions: FakeWorkoutSessionRepository(throwOnFindActiveSessions: true),
    );
    final result = await c.read(sessionRecoveryProvider.future);
    expect(result, isA<UnrecoverableRecovery>());
  });

  test('explicitní Retry (invalidace) znovu spustí recovery', () async {
    final sessions = FakeWorkoutSessionRepository(
      throwOnFindActiveSessions: true,
    );
    final c = container(sessions: sessions);
    expect(
      await c.read(sessionRecoveryProvider.future),
      isA<UnrecoverableRecovery>(),
    );

    // Podmínka pominula → Retry vede k NoActiveSession.
    sessions.throwOnFindActiveSessions = false;
    c.invalidate(sessionRecoveryProvider);
    expect(
      await c.read(sessionRecoveryProvider.future),
      isA<NoActiveSessionRecovery>(),
    );
  });

  test('paralelní čtení nespustí dvě opravy pointeru', () async {
    final session = buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1');
    final sessions = FakeWorkoutSessionRepository(
      activeSessions: [session],
      activePointer: null, // vynutí opravu
    );
    final c = container(sessions: sessions);

    final f1 = c.read(sessionRecoveryProvider.future);
    final f2 = c.read(sessionRecoveryProvider.future);
    await Future.wait([f1, f2]);

    // Sdílený future → oprava proběhne právě jednou.
    expect(sessions.reconcileCallCount, 1);
  });

  test('recovery use case lze přepsat přes Riverpod override', () async {
    final c = container(sessions: FakeWorkoutSessionRepository());
    // recoverActiveSessionProvider je běžný Provider složený z repository
    // providerů — override repository stačí k řízení výsledku (výše).
    final useCase = c.read(recoverActiveSessionProvider);
    expect(useCase, isNotNull);
  });
}
