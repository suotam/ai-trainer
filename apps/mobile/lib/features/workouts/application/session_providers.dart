import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../data/drift_workout_session_repository.dart';
import '../domain/start_session_result.dart';
import '../domain/workout_session.dart';
import '../domain/workout_session_repository.dart';
import 'start_workout_session.dart';
import 'workout_bootstrap.dart';

/// Composition session vrstvy (fyzický model §16). Presentation čte jen
/// tyto providery — nikdy Drift typy (PDR-008).
final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>(
  (ref) => DriftWorkoutSessionRepository(ref.watch(appDatabaseProvider)),
);

final startWorkoutSessionProvider = Provider<StartWorkoutSession>(
  (ref) => StartWorkoutSession(
    repository: ref.watch(workoutSessionRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Globálně aktivní session pro recovery po restartu. Čeká na bootstrap,
/// poté čte z persistence. Bez sítě, bez auto-retry, bez background pollingu.
final activeSessionProvider = FutureProvider<WorkoutSessionSnapshot?>((
  ref,
) async {
  await ref.watch(workoutBootstrapCompletedProvider.future);
  return ref.watch(workoutSessionRepositoryProvider).findActiveSession();
}, retry: (retryCount, error) => null);

/// Session podle ID pro active session screen.
final sessionByIdProvider =
    FutureProvider.family<WorkoutSessionSnapshot?, String>((ref, id) async {
      await ref.watch(workoutBootstrapCompletedProvider.future);
      final trimmed = id.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      return ref.watch(workoutSessionRepositoryProvider).sessionById(trimmed);
    }, retry: (retryCount, error) => null);

/// UI stav startu session.
sealed class StartSessionUiState {
  const StartSessionUiState();
}

class StartSessionIdle extends StartSessionUiState {
  const StartSessionIdle();
}

class StartSessionInProgress extends StartSessionUiState {
  const StartSessionInProgress();
}

class StartSessionSuccess extends StartSessionUiState {
  const StartSessionSuccess(this.result);
  final StartSessionResult result;
}

class StartSessionFailure extends StartSessionUiState {
  const StartSessionFailure();
}

/// Controller startu z UI. Guarduje dvojitý tap a paralelní start commandy —
/// nový start se ignoruje, dokud jeden probíhá. Žádný automatický retry loop.
class StartSessionController extends Notifier<StartSessionUiState> {
  bool _inFlight = false;

  @override
  StartSessionUiState build() => const StartSessionIdle();

  Future<void> start(String workoutInstanceId) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const StartSessionInProgress();
    try {
      final result = await ref
          .read(startWorkoutSessionProvider)
          .call(workoutInstanceId);
      // Nová session nebo obnovení mění aktivní stav — invaliduj recovery.
      ref.invalidate(activeSessionProvider);
      state = StartSessionSuccess(result);
    } catch (_) {
      // Raw výjimka se nepropaguje do UI (mobile-architecture §24).
      state = const StartSessionFailure();
    } finally {
      _inFlight = false;
    }
  }

  void reset() => state = const StartSessionIdle();
}

final startSessionControllerProvider =
    NotifierProvider<StartSessionController, StartSessionUiState>(
      StartSessionController.new,
    );
