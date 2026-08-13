import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../workouts/application/today_providers.dart';
import '../data/drift_calendar_operations_repository.dart';
import '../data/drift_training_plan_repository.dart';
import '../domain/calendar_operations.dart';
import '../domain/training_plan.dart';
import '../domain/training_plan_repository.dart';

/// Composition ručního plánování (R3-04, C20). Presentation čte jen tyto
/// providery — nikdy Drift typy (PDR-008).
final trainingPlanRepositoryProvider = Provider<TrainingPlanRepository>(
  (ref) => DriftTrainingPlanRepository(ref.watch(appDatabaseProvider)),
);

/// Plány vlastníka (ACTIVE první, MPC-013).
final trainingPlansProvider = FutureProvider<List<TrainingPlan>>(
  (ref) => ref.watch(trainingPlanRepositoryProvider).plansForCurrentOwner(),
  retry: (retryCount, error) => null,
);

/// Workouty daného plánu podle data (MPC-013).
final planWorkoutsProvider =
    FutureProvider.family<List<PlannedWorkoutSummary>, String>(
      (ref, planId) =>
          ref.watch(trainingPlanRepositoryProvider).workoutsForPlan(planId),
      retry: (retryCount, error) => null,
    );

/// Kalendářní operace (R3-05, C21).
final calendarOperationsRepositoryProvider =
    Provider<CalendarOperationsRepository>(
      (ref) =>
          DriftCalendarOperationsRepository(ref.watch(appDatabaseProvider)),
    );

/// UI stav zápisu plánu.
sealed class PlanSaveState {
  const PlanSaveState();
}

class PlanIdle extends PlanSaveState {
  const PlanIdle();
}

class PlanSaving extends PlanSaveState {
  const PlanSaving();
}

class PlanSaved extends PlanSaveState {
  const PlanSaved();
}

class PlanFailure extends PlanSaveState {
  const PlanFailure(this.result);
  final PlanWriteResult result;
}

/// Typovaná chyba kalendářní operace (CAL-007).
class PlanCalendarFailure extends PlanSaveState {
  const PlanCalendarFailure(this.result);
  final CalendarOpResult result;
}

/// Controller zápisů plánu: double-submit guard, typované chyby, po
/// úspěchu invalidace read modelů (vč. Today — ruční workout se v něm
/// objevuje okamžitě). Žádný automatický retry.
class PlanController extends Notifier<PlanSaveState> {
  bool _inFlight = false;

  @override
  PlanSaveState build() => const PlanIdle();

  Future<void> createPlan({required String title, String? note}) => _run(
    () => ref
        .read(trainingPlanRepositoryProvider)
        .createPlan(
          title: title,
          note: note,
          newId: ref.read(idGeneratorProvider).newId(),
          now: ref.read(clockProvider)(),
        ),
  );

  Future<void> setPlanStatus(String id, String status) => _run(
    () => ref
        .read(trainingPlanRepositoryProvider)
        .setPlanStatus(id, status, now: ref.read(clockProvider)()),
  );

  Future<void> addWorkout(String planId, PlannedWorkoutInput input) => _run(
    () => ref
        .read(trainingPlanRepositoryProvider)
        .addWorkout(
          planId,
          input,
          newId: ref.read(idGeneratorProvider).newId,
          now: ref.read(clockProvider)(),
        ),
  );

  Future<void> moveWorkout(String instanceId, String targetLocalDate) =>
      _runCalendar(
        () => ref
            .read(calendarOperationsRepositoryProvider)
            .moveWorkout(
              instanceId,
              targetLocalDate,
              changeId: ref.read(idGeneratorProvider).newId(),
              now: ref.read(clockProvider)(),
            ),
      );

  Future<void> cancelWorkout(String instanceId) => _runCalendar(
    () => ref
        .read(calendarOperationsRepositoryProvider)
        .cancelWorkout(
          instanceId,
          changeId: ref.read(idGeneratorProvider).newId(),
          now: ref.read(clockProvider)(),
        ),
  );

  Future<void> replaceWorkout(String instanceId, PlannedWorkoutInput input) =>
      _runCalendar(
        () => ref
            .read(calendarOperationsRepositoryProvider)
            .replaceWorkout(
              instanceId,
              input,
              newId: ref.read(idGeneratorProvider).newId,
              now: ref.read(clockProvider)(),
            ),
      );

  Future<void> _runCalendar(Future<CalendarOpResult> Function() action) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const PlanSaving();
    try {
      final result = await action();
      switch (result) {
        case CalendarOpSaved():
          ref
            ..invalidate(trainingPlansProvider)
            ..invalidate(planWorkoutsProvider)
            ..invalidate(todayWorkoutsProvider);
          state = const PlanSaved();
        default:
          state = PlanCalendarFailure(result);
      }
    } catch (_) {
      // Raw persistence výjimka se nepropaguje do UI.
      state = const PlanCalendarFailure(CalendarOpValidationFailed());
    } finally {
      _inFlight = false;
    }
  }

  Future<void> _run(Future<PlanWriteResult> Function() action) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const PlanSaving();
    try {
      final result = await action();
      switch (result) {
        case PlanWriteSaved():
          ref
            ..invalidate(trainingPlansProvider)
            ..invalidate(planWorkoutsProvider)
            // Interní kalendář = existující R1 read modely (C20 §6).
            ..invalidate(todayWorkoutsProvider);
          state = const PlanSaved();
        default:
          state = PlanFailure(result);
      }
    } catch (_) {
      // Raw persistence výjimka se nepropaguje do UI.
      state = const PlanFailure(PlanWriteValidationFailed());
    } finally {
      _inFlight = false;
    }
  }
}

final planControllerProvider = NotifierProvider<PlanController, PlanSaveState>(
  PlanController.new,
);
