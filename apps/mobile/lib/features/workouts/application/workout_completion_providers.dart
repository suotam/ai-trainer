import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../data/drift_workout_completion_repository.dart';
import '../data/drift_workout_history_repository.dart';
import '../domain/complete_workout_result.dart';
import '../domain/workout_completion_repository.dart';
import '../domain/workout_feedback.dart';
import '../domain/workout_history.dart';
import '../domain/workout_history_repository.dart';
import 'complete_workout.dart';
import 'session_providers.dart';
import 'session_recovery_providers.dart';
import 'session_tracker_providers.dart';
import 'today_providers.dart';
import 'workout_bootstrap.dart';

/// Composition completion vrstvy (fyzický model §16). Presentation čte jen
/// tyto providery — nikdy Drift typy (PDR-008).
final workoutCompletionRepositoryProvider =
    Provider<WorkoutCompletionRepository>(
      (ref) => DriftWorkoutCompletionRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(idGeneratorProvider),
      ),
    );

final completeWorkoutProvider = Provider<CompleteWorkout>(
  (ref) => CompleteWorkout(
    repository: ref.watch(workoutCompletionRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>(
  (ref) => DriftWorkoutHistoryRepository(ref.watch(appDatabaseProvider)),
);

/// Historie dokončených workoutů. Čeká na bootstrap, poté čte read model.
/// Bez sítě, bez auto-retry.
final completedWorkoutsProvider = FutureProvider<List<WorkoutHistoryEntry>>((
  ref,
) async {
  await ref.watch(workoutBootstrapCompletedProvider.future);
  return ref.watch(workoutHistoryRepositoryProvider).completedWorkouts();
}, retry: (retryCount, error) => null);

/// Read-only detail dokončeného workoutu: historická metadata + neměnný
/// tracker read model. Bez inicializace (jen čtení), bez sítě.
final completedWorkoutDetailProvider =
    FutureProvider.family<CompletedWorkoutDetail?, String>((
      ref,
      sessionId,
    ) async {
      await ref.watch(workoutBootstrapCompletedProvider.future);
      final entry = await ref
          .watch(workoutHistoryRepositoryProvider)
          .completedWorkoutBySessionId(sessionId);
      if (entry == null) {
        return null;
      }
      final historyRepository = ref.watch(workoutHistoryRepositoryProvider);
      final tracker = await ref
          .watch(workoutPerformanceRepositoryProvider)
          .loadTracker(sessionId);
      if (tracker == null) {
        return null;
      }
      final feedback = await historyRepository.feedbackBySessionId(sessionId);
      return CompletedWorkoutDetail(
        entry: entry,
        tracker: tracker,
        feedback: feedback,
      );
    }, retry: (retryCount, error) => null);

/// UI stav dokončování workoutu.
sealed class WorkoutCompletionState {
  const WorkoutCompletionState();
}

class CompletionIdle extends WorkoutCompletionState {
  const CompletionIdle();
}

class CompletionInProgress extends WorkoutCompletionState {
  const CompletionInProgress();
}

/// Session je dokončena (nově nebo už dříve) — UI může navigovat mimo tracker.
class CompletionDone extends WorkoutCompletionState {
  const CompletionDone({required this.alreadyCompleted});

  final bool alreadyCompleted;
}

/// Bezpečný chybový stav (validace/konflikt/nekonzistence/raw selhání).
class CompletionError extends WorkoutCompletionState {
  const CompletionError();
}

/// Controller dokončení. Guarduje dvojitý tap (jeden completion write),
/// po úspěchu invaliduje aktivní session, recovery, Today a history
/// providery. Žádný automatický retry.
class WorkoutCompletionController extends Notifier<WorkoutCompletionState> {
  bool _inFlight = false;

  @override
  WorkoutCompletionState build() => const CompletionIdle();

  Future<void> complete(
    String sessionId, {
    WorkoutFeedbackInput? feedback,
  }) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const CompletionInProgress();
    try {
      final result = await ref
          .read(completeWorkoutProvider)
          .call(sessionId: sessionId, feedback: feedback);
      switch (result) {
        case WorkoutCompleted():
          _invalidateAfterCompletion(sessionId);
          state = const CompletionDone(alreadyCompleted: false);
        case WorkoutAlreadyCompleted():
          _invalidateAfterCompletion(sessionId);
          state = const CompletionDone(alreadyCompleted: true);
        case CompletionSessionNotFound():
        case CompletionSessionNotCompletable():
        case CompletionInstanceNotFound():
        case CompletionInconsistentState():
          state = const CompletionError();
      }
    } catch (_) {
      // Raw persistence výjimka se nepropaguje do UI.
      state = const CompletionError();
    } finally {
      _inFlight = false;
    }
  }

  void reset() => state = const CompletionIdle();

  void _invalidateAfterCompletion(String sessionId) {
    ref.invalidate(activeSessionProvider);
    ref.invalidate(sessionRecoveryProvider);
    ref.invalidate(sessionTrackerProvider(sessionId));
    ref.invalidate(completedWorkoutsProvider);
    ref.invalidate(todayWorkoutsProvider);
  }
}

final workoutCompletionControllerProvider =
    NotifierProvider<WorkoutCompletionController, WorkoutCompletionState>(
      WorkoutCompletionController.new,
    );
