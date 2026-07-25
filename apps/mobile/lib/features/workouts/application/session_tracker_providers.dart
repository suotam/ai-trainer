import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../data/drift_workout_performance_repository.dart';
import '../domain/record_performance_result.dart';
import '../domain/session_tracker.dart';
import '../domain/workout_performance_repository.dart';
import 'record_set_performance.dart';
import 'set_set_completion.dart';
import 'workout_bootstrap.dart';

/// Composition performance vrstvy (fyzický model §16). Presentation čte jen
/// tyto providery — nikdy Drift typy (PDR-008).
final workoutPerformanceRepositoryProvider =
    Provider<WorkoutPerformanceRepository>(
      (ref) => DriftWorkoutPerformanceRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(idGeneratorProvider),
      ),
    );

final recordSetPerformanceProvider = Provider<RecordSetPerformance>(
  (ref) => RecordSetPerformance(
    repository: ref.watch(workoutPerformanceRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final setSetCompletionProvider = Provider<SetSetCompletion>(
  (ref) => SetSetCompletion(
    repository: ref.watch(workoutPerformanceRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Tracker aktivní session. Po bootstrapu idempotentně inicializuje
/// performance řádky (odloženo z R1-03) a načte read model. Bez sítě,
/// bez auto-retry.
final sessionTrackerProvider = FutureProvider.family<SessionTracker?, String>((
  ref,
  sessionId,
) async {
  await ref.watch(workoutBootstrapCompletedProvider.future);
  final repository = ref.watch(workoutPerformanceRepositoryProvider);
  await repository.initializePerformances(
    sessionId: sessionId,
    now: ref.watch(clockProvider)(),
  );
  return repository.loadTracker(sessionId);
}, retry: (retryCount, error) => null);

/// UI stav zápisu jednoho setu.
sealed class TrackerSaveState {
  const TrackerSaveState();
}

class TrackerIdle extends TrackerSaveState {
  const TrackerIdle();
}

class TrackerSaving extends TrackerSaveState {
  const TrackerSaving(this.setPerformanceId);
  final String setPerformanceId;
}

class TrackerSaved extends TrackerSaveState {
  const TrackerSaved(this.setPerformanceId);
  final String setPerformanceId;
}

class TrackerValidationError extends TrackerSaveState {
  const TrackerValidationError(this.setPerformanceId);
  final String setPerformanceId;
}

class TrackerError extends TrackerSaveState {
  const TrackerError(this.setPerformanceId);
  final String setPerformanceId;
}

/// Controller zápisu do trackeru. Guarduje paralelní save stejného setu a
/// po úspěšném zápisu obnoví tracker read model. Žádný automatický retry.
class TrackerController extends Notifier<TrackerSaveState> {
  final Set<String> _inFlight = {};

  @override
  TrackerSaveState build() => const TrackerIdle();

  Future<void> saveActuals({
    required String sessionId,
    required String setPerformanceId,
    required int? actualRepetitions,
    required double? actualWeightKg,
  }) => _run(sessionId, setPerformanceId, () {
    return ref
        .read(recordSetPerformanceProvider)
        .call(
          setPerformanceId: setPerformanceId,
          actualRepetitions: actualRepetitions,
          actualWeightKg: actualWeightKg,
        );
  });

  Future<void> toggleCompleted({
    required String sessionId,
    required String setPerformanceId,
    required bool completed,
  }) => _run(sessionId, setPerformanceId, () {
    return ref
        .read(setSetCompletionProvider)
        .call(setPerformanceId: setPerformanceId, completed: completed);
  });

  Future<void> _run(
    String sessionId,
    String setPerformanceId,
    Future<RecordPerformanceResult> Function() action,
  ) async {
    if (_inFlight.contains(setPerformanceId)) {
      return;
    }
    _inFlight.add(setPerformanceId);
    state = TrackerSaving(setPerformanceId);
    try {
      final result = await action();
      switch (result) {
        case PerformanceSaved():
          ref.invalidate(sessionTrackerProvider(sessionId));
          state = TrackerSaved(setPerformanceId);
        case PerformanceValidationFailure():
          state = TrackerValidationError(setPerformanceId);
        case PerformanceSessionNotActive():
        case PerformanceSetNotFound():
          state = TrackerError(setPerformanceId);
      }
    } catch (_) {
      // Raw persistence výjimka se nepropaguje do UI.
      state = TrackerError(setPerformanceId);
    } finally {
      _inFlight.remove(setPerformanceId);
    }
  }
}

final trackerControllerProvider =
    NotifierProvider<TrackerController, TrackerSaveState>(
      TrackerController.new,
    );
