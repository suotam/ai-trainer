import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/start_workout_session.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

class SequenceIdGenerator implements IdGenerator {
  int _n = 0;
  @override
  String newId() => 'gen-${_n++}';
}

void main() {
  ProviderContainer container({
    required FakeWorkoutSessionRepository sessions,
  }) {
    final c = ProviderContainer(
      overrides: [
        r1SeedRepositoryProvider.overrideWithValue(
          FakeSeedRepository([SeedResult.applied]),
        ),
        workoutSessionRepositoryProvider.overrideWithValue(sessions),
        idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('StartWorkoutSession use case', () {
    test('používá injektovaný clock a id generator', () async {
      final sessions = FakeWorkoutSessionRepository();
      DateTime? passedNow;
      final recording = _RecordingSessionRepository(
        onStart: (now) {
          passedNow = now;
        },
      );
      final useCase = StartWorkoutSession(
        repository: recording,
        idGenerator: SequenceIdGenerator(),
        clock: () => DateTime.utc(2026, 7, 20, 9),
      );

      final result = await useCase.call('wi1');

      expect((result as SessionCreated).sessionId, 'gen-0');
      expect(passedNow, DateTime.utc(2026, 7, 20, 9));
      expect(sessions.startCallCount, 0);
    });
  });

  group('StartSessionController', () {
    test('idle → starting → created', () async {
      final c = container(
        sessions: FakeWorkoutSessionRepository(
          startScript: [const SessionCreated('ses-1')],
        ),
      );
      final notifier = c.read(startSessionControllerProvider.notifier);
      expect(c.read(startSessionControllerProvider), isA<StartSessionIdle>());

      final future = notifier.start('wi1');
      expect(
        c.read(startSessionControllerProvider),
        isA<StartSessionInProgress>(),
      );
      await future;

      final state = c.read(startSessionControllerProvider);
      expect(state, isA<StartSessionSuccess>());
      expect((state as StartSessionSuccess).result, isA<SessionCreated>());
    });

    test('idle → starting → resumed', () async {
      final c = container(
        sessions: FakeWorkoutSessionRepository(
          startScript: [const SessionResumedExisting('ses-1')],
        ),
      );
      await c.read(startSessionControllerProvider.notifier).start('wi1');
      final state =
          c.read(startSessionControllerProvider) as StartSessionSuccess;
      expect(state.result, isA<SessionResumedExisting>());
    });

    test('idle → starting → conflict', () async {
      final c = container(
        sessions: FakeWorkoutSessionRepository(
          startScript: [
            const ConflictWithAnotherSession(
              activeSessionId: 'ses-x',
              activeWorkoutInstanceId: 'other',
            ),
          ],
        ),
      );
      await c.read(startSessionControllerProvider.notifier).start('wi1');
      final state =
          c.read(startSessionControllerProvider) as StartSessionSuccess;
      expect(state.result, isA<ConflictWithAnotherSession>());
    });

    test('idle → starting → error při raw výjimce (bez propagace)', () async {
      final c = container(
        sessions: FakeWorkoutSessionRepository(throwOnStart: true),
      );
      await c.read(startSessionControllerProvider.notifier).start('wi1');
      expect(
        c.read(startSessionControllerProvider),
        isA<StartSessionFailure>(),
      );
    });

    test('dvojitý trigger nevytvoří dva starty', () async {
      final sessions = FakeWorkoutSessionRepository(
        startScript: [const SessionCreated('ses-1')],
      );
      final c = container(sessions: sessions);
      final notifier = c.read(startSessionControllerProvider.notifier);

      final f1 = notifier.start('wi1');
      final f2 = notifier.start('wi1'); // ignorováno, jeden je in-flight
      await Future.wait([f1, f2]);

      expect(sessions.startCallCount, 1);
    });
  });

  group('activeSessionProvider (recovery)', () {
    test('načte uloženou aktivní session', () async {
      final c = container(
        sessions: FakeWorkoutSessionRepository(
          activeSession: buildSessionSnapshot(id: 'ses-active'),
        ),
      );
      final active = await c.read(activeSessionProvider.future);
      expect(active, isNotNull);
      expect(active!.id, 'ses-active');
    });

    test('bez aktivní session vrací null', () async {
      final c = container(sessions: FakeWorkoutSessionRepository());
      expect(await c.read(activeSessionProvider.future), isNull);
    });
  });

  test(
    'sessionByIdProvider: prázdné ID nevolá repository a vrací null',
    () async {
      final c = container(sessions: FakeWorkoutSessionRepository());
      expect(await c.read(sessionByIdProvider('   ').future), isNull);
    },
  );
}

class _RecordingSessionRepository extends FakeWorkoutSessionRepository {
  _RecordingSessionRepository({required this.onStart});
  final void Function(DateTime now) onStart;

  @override
  Future<StartSessionResult> startSession({
    required String workoutInstanceId,
    required String newSessionId,
    required DateTime now,
  }) async {
    onStart(now);
    return SessionCreated(newSessionId);
  }
}
