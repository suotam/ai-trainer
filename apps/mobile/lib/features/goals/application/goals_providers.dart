import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../data/drift_goal_repository.dart';
import '../domain/goal.dart';
import '../domain/goal_repository.dart';

/// Composition cílů (R3-02, C18). Presentation čte jen tyto providery —
/// nikdy Drift typy (PDR-008).
final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => DriftGoalRepository(ref.watch(appDatabaseProvider)),
);

/// Cíle aktuálního vlastníka v deterministickém pořadí (GLC-013).
final goalsProvider = FutureProvider<List<Goal>>(
  (ref) => ref.watch(goalRepositoryProvider).goalsForCurrentOwner(),
  retry: (retryCount, error) => null,
);

/// UI stav zápisu cíle.
sealed class GoalsSaveState {
  const GoalsSaveState();
}

class GoalsIdle extends GoalsSaveState {
  const GoalsIdle();
}

class GoalsSaving extends GoalsSaveState {
  const GoalsSaving();
}

class GoalsSaved extends GoalsSaveState {
  const GoalsSaved();
}

class GoalsFailure extends GoalsSaveState {
  const GoalsFailure(this.result);
  final SaveGoalResult result;
}

/// Controller zápisů cílů: double-submit guard, typované chyby, po úspěchu
/// invalidace read modelu. Žádný automatický retry.
class GoalsController extends Notifier<GoalsSaveState> {
  bool _inFlight = false;

  @override
  GoalsSaveState build() => const GoalsIdle();

  Future<void> save(GoalInput input, {String? existingId}) => _run(
    () => ref
        .read(goalRepositoryProvider)
        .saveGoal(
          input,
          existingId: existingId,
          newId: ref.read(idGeneratorProvider).newId(),
          now: ref.read(clockProvider)(),
        ),
  );

  Future<void> changeStatus(String id, String newStatus) => _run(
    () => ref
        .read(goalRepositoryProvider)
        .changeStatus(id, newStatus, now: ref.read(clockProvider)()),
  );

  Future<void> _run(Future<SaveGoalResult> Function() action) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const GoalsSaving();
    try {
      final result = await action();
      switch (result) {
        case GoalSaved():
          ref.invalidate(goalsProvider);
          state = const GoalsSaved();
        default:
          state = GoalsFailure(result);
      }
    } catch (_) {
      // Raw persistence výjimka se nepropaguje do UI.
      state = const GoalsFailure(GoalValidationFailed());
    } finally {
      _inFlight = false;
    }
  }
}

final goalsControllerProvider =
    NotifierProvider<GoalsController, GoalsSaveState>(GoalsController.new);
