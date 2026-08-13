import '../../../core/database/app_database.dart';
import '../../../core/database/tables/ai_tables.dart';
import '../../../core/database/tables/plan_tables.dart';
import '../../../core/time/clock.dart';
import '../../availability/domain/availability_profile_repository.dart';
import '../../checkin/domain/daily_check_in_repository.dart';
import '../../plan/domain/calendar_operations.dart';
import '../../plan/domain/training_plan.dart';
import '../../plan/domain/training_plan_repository.dart';
import '../../safety/domain/safety_assessment.dart';
import '../../workouts/domain/workout_instance_repository.dart';
import '../domain/ai_proposal.dart';
import '../domain/ai_proposal_repository.dart';
import '../domain/proposal_executor.dart';

/// Provedení potvrzeného návrhu výhradně přes C20/C21 porty (CSE-001,
/// AJE-001) v jedné transakci (CSE-003/AJE-003). Doménová pravidla platí
/// beze změny (CSE-002/AJE-002); selhání = rollback + EXECUTION_FAILED po
/// něm. Adjustment (C38): deterministická resolvace targetů (AJE-004) a
/// safety veto (AJE-005) před jakoukoli změnou.
class DriftProposalExecutor implements ProposalExecutor {
  DriftProposalExecutor(
    this._db,
    this._plans,
    this._proposals,
    this._calendarOps,
    this._instances,
    this._checkIns,
    this._availability,
  );

  final AppDatabase _db;
  final TrainingPlanRepository _plans;
  final AiProposalRepository _proposals;
  final CalendarOperationsRepository _calendarOps;
  final WorkoutInstanceRepository _instances;
  final DailyCheckInRepository _checkIns;
  final AvailabilityProfileRepository _availability;

  @override
  Future<ExecuteProposalResult> execute(
    String proposalId, {
    required String Function() newId,
    required DateTime now,
  }) async {
    try {
      return await _db.transaction(() async {
        final proposal = await _proposals.proposalById(proposalId);
        if (proposal == null) {
          return const ExecutionNotFound();
        }
        if (proposal.status != proposalStatusConfirmed &&
            proposal.status != proposalStatusExecutionFailed) {
          return const ExecutionInvalidState();
        }

        if (proposal.isAdjustment) {
          return _executeAdjustment(proposal, newId: newId, now: now);
        }

        final planTitle = proposal.payload['planTitle'];
        final workouts = proposal.payload['workouts'];
        if (planTitle is! String || workouts is! List || workouts.isEmpty) {
          throw const _Abort(ExecutionInvalidPayload());
        }

        final planId = newId();
        final created = await _plans.createPlan(
          title: planTitle,
          origin: planOriginAiProposal,
          newId: planId,
          now: now,
        );
        switch (created) {
          case PlanWriteSaved():
            break;
          case PlanWriteActiveConflict():
            throw const _Abort(ExecutionActivePlanConflict());
          default:
            throw const _Abort(ExecutionInvalidPayload());
        }

        for (final workoutRaw in workouts) {
          final input = _workoutInput(workoutRaw, now);
          if (input == null) {
            throw const _Abort(ExecutionInvalidPayload());
          }
          final added = await _plans.addWorkout(
            planId,
            input,
            newId: newId,
            now: now,
          );
          if (added is! PlanWriteSaved) {
            throw const _Abort(ExecutionInvalidPayload());
          }
        }

        final marked = await _proposals.markExecuted(
          proposalId,
          executedPlanId: planId,
          now: now,
        );
        if (!marked) {
          throw const _Abort(ExecutionInvalidState());
        }
        return ExecutionSaved(planId);
      });
    } on _Abort catch (abort) {
      // Transakce je odvolaná (žádný částečný stav, CSE-003); výsledek
      // pokusu se přizná stavem návrhu (CSE-005).
      await _proposals.markExecutionFailed(proposalId, now: now);
      return abort.result;
    }
  }

  /// Provedení adjustmentu (C38 §4): resolvace targetů, safety veto a
  /// překlad na C21/C20 operace — celé uvnitř transakce volajícího.
  Future<ExecuteProposalResult> _executeAdjustment(
    AiProposal proposal, {
    required String Function() newId,
    required DateTime now,
  }) async {
    final operations = proposal.payload['operations'];
    if (operations is! List || operations.isEmpty) {
      throw const _Abort(ExecutionInvalidPayload());
    }
    // Dny relativně k lokálnímu datu vzniku návrhu (C38 §2, AJE-006).
    final creation = DateTime.fromMillisecondsSinceEpoch(
      proposal.createdAtMillis,
      isUtc: true,
    );

    // Safety veto (AJE-005): STOP stav blokuje zátěž přidávající operace
    // deterministicky, před jakoukoli změnou.
    final addsLoad = operations.any(
      (op) =>
          op is Map &&
          (op['operation'] == 'ADD' || op['operation'] == 'REPLACE'),
    );
    if (addsLoad) {
      final today = formatLocalDate(now);
      final safety = evaluateSafety(
        todayCheckIn: await _checkIns.checkInForDate(today),
        activeConstraints: [
          for (final constraint
              in await _availability.constraintsForCurrentOwner())
            if (constraint.status == 'ACTIVE') constraint,
        ],
      );
      if (safety.state == SafetyState.doNotRecommendActivity) {
        throw const _Abort(ExecutionSafetyConflict());
      }
    }

    String? activePlanId;
    for (final raw in operations) {
      if (raw is! Map) {
        throw const _Abort(ExecutionInvalidPayload());
      }
      final kind = raw['operation'];
      switch (kind) {
        case 'MOVE':
          final instanceId = await _resolveTarget(raw['target'], creation);
          final toDayOffset = raw['toDayOffset'];
          if (toDayOffset is! int) {
            throw const _Abort(ExecutionInvalidPayload());
          }
          final moved = await _calendarOps.moveWorkout(
            instanceId,
            scheduledDateForOffset(creation, toDayOffset),
            changeId: newId(),
            now: now,
          );
          if (moved is! CalendarOpSaved) {
            throw const _Abort(ExecutionOperationRejected());
          }
        case 'CANCEL':
          final instanceId = await _resolveTarget(raw['target'], creation);
          final cancelled = await _calendarOps.cancelWorkout(
            instanceId,
            changeId: newId(),
            now: now,
          );
          if (cancelled is! CalendarOpSaved) {
            throw const _Abort(ExecutionOperationRejected());
          }
        case 'REPLACE':
          final target = raw['target'];
          final instanceId = await _resolveTarget(target, creation);
          // Náhrada dědí den targetu (C37 §3).
          final targetDate = scheduledDateForOffset(
            creation,
            (target as Map)['dayOffset'] as int,
          );
          final input = _workoutInputForAdjustment(
            raw['workout'],
            scheduledLocalDate: targetDate,
          );
          if (input == null) {
            throw const _Abort(ExecutionInvalidPayload());
          }
          final replaced = await _calendarOps.replaceWorkout(
            instanceId,
            input,
            newId: newId,
            now: now,
          );
          if (replaced is! CalendarOpSaved) {
            throw const _Abort(ExecutionOperationRejected());
          }
        case 'ADD':
          // ADD jde do jediného ACTIVE plánu vlastníka (C38 §4).
          activePlanId ??= await _requireActivePlanId();
          final workout = raw['workout'];
          final dayOffset = workout is Map ? workout['dayOffset'] : null;
          if (dayOffset is! int) {
            throw const _Abort(ExecutionInvalidPayload());
          }
          final input = _workoutInputForAdjustment(
            workout,
            scheduledLocalDate: scheduledDateForOffset(creation, dayOffset),
          );
          if (input == null) {
            throw const _Abort(ExecutionInvalidPayload());
          }
          final added = await _plans.addWorkout(
            activePlanId,
            input,
            newId: newId,
            now: now,
          );
          if (added is! PlanWriteSaved) {
            throw const _Abort(ExecutionOperationRejected());
          }
        default:
          throw const _Abort(ExecutionInvalidPayload());
      }
    }

    final marked = await _proposals.markExecuted(
      proposal.id,
      executedPlanId: activePlanId,
      now: now,
    );
    if (!marked) {
      throw const _Abort(ExecutionInvalidState());
    }
    return ExecutionSaved(activePlanId);
  }

  /// Deterministická resolvace targetu (C38 §3, AJE-004): přesná shoda
  /// datum + title, jinak typované selhání — nikdy odhad.
  Future<String> _resolveTarget(Object? target, DateTime creation) async {
    if (target is! Map) {
      throw const _Abort(ExecutionInvalidPayload());
    }
    final dayOffset = target['dayOffset'];
    final title = target['title'];
    if (dayOffset is! int || title is! String) {
      throw const _Abort(ExecutionInvalidPayload());
    }
    final date = scheduledDateForOffset(creation, dayOffset);
    final candidates = [
      for (final workout in await _instances.workoutsForLocalDate(date))
        if (workout.title == title) workout,
    ];
    if (candidates.length != 1) {
      throw const _Abort(ExecutionTargetUnresolved());
    }
    return candidates.single.id;
  }

  Future<String> _requireActivePlanId() async {
    final active = [
      for (final plan in await _plans.plansForCurrentOwner())
        if (plan.isActive) plan,
    ];
    if (active.length != 1) {
      throw const _Abort(ExecutionOperationRejected());
    }
    return active.single.id;
  }

  /// Překlad adjustment workoutu (bez per-workout reason, C37 §3).
  PlannedWorkoutInput? _workoutInputForAdjustment(
    Object? raw, {
    required String scheduledLocalDate,
  }) {
    if (raw is! Map) {
      return null;
    }
    final title = raw['title'];
    final workoutType = raw['workoutType'];
    if (title is! String || workoutType is! String) {
      return null;
    }
    final duration = raw['plannedDurationMinutes'];
    if (duration is! int?) {
      return null;
    }
    final exercises = <PlannedExerciseInput>[];
    final exercisesRaw = raw['exercises'];
    if (exercisesRaw != null) {
      if (exercisesRaw is! List) {
        return null;
      }
      for (final exerciseRaw in exercisesRaw) {
        if (exerciseRaw is! Map) {
          return null;
        }
        final exerciseTitle = exerciseRaw['title'];
        final sets = exerciseRaw['sets'];
        final repetitions = exerciseRaw['repetitions'];
        final weight = exerciseRaw['weightKg'];
        if (exerciseTitle is! String ||
            sets is! int ||
            repetitions is! int ||
            weight is! num?) {
          return null;
        }
        exercises.add(
          PlannedExerciseInput(
            title: exerciseTitle,
            sets: sets,
            repetitions: repetitions,
            weightKg: weight?.toDouble(),
          ),
        );
      }
    }
    return PlannedWorkoutInput(
      title: title,
      workoutType: workoutType,
      scheduledLocalDate: scheduledLocalDate,
      plannedDurationMinutes: duration,
      exercises: exercises,
    );
  }

  /// Překlad kanonického C28 workoutu na C20 vstup (C30 §3) — nikdy
  /// oprava ani dopočet (CSE-012).
  PlannedWorkoutInput? _workoutInput(Object? raw, DateTime now) {
    if (raw is! Map) {
      return null;
    }
    final title = raw['title'];
    final workoutType = raw['workoutType'];
    final dayOffset = raw['dayOffset'];
    if (title is! String || workoutType is! String || dayOffset is! int) {
      return null;
    }
    final duration = raw['plannedDurationMinutes'];
    if (duration is! int?) {
      return null;
    }
    final exercisesRaw = raw['exercises'];
    final exercises = <PlannedExerciseInput>[];
    if (exercisesRaw != null) {
      if (exercisesRaw is! List) {
        return null;
      }
      for (final exerciseRaw in exercisesRaw) {
        if (exerciseRaw is! Map) {
          return null;
        }
        final exerciseTitle = exerciseRaw['title'];
        final sets = exerciseRaw['sets'];
        final repetitions = exerciseRaw['repetitions'];
        final weight = exerciseRaw['weightKg'];
        if (exerciseTitle is! String ||
            sets is! int ||
            repetitions is! int ||
            weight is! num?) {
          return null;
        }
        exercises.add(
          PlannedExerciseInput(
            title: exerciseTitle,
            sets: sets,
            repetitions: repetitions,
            weightKg: weight?.toDouble(),
          ),
        );
      }
    }
    return PlannedWorkoutInput(
      title: title,
      workoutType: workoutType,
      scheduledLocalDate: scheduledDateForOffset(now, dayOffset),
      plannedDurationMinutes: duration,
      exercises: exercises,
    );
  }
}

/// Mapování `dayOffset` → datum (C30 §3, CSE-008 — jediný vlastník):
/// den 0 = lokální kalendářní datum okamžiku provedení. Aritmetika běží
/// v UTC, aby ji neovlivnily DST přechody.
String scheduledDateForOffset(DateTime now, int dayOffset) {
  final local = now.toLocal();
  final date = DateTime.utc(
    local.year,
    local.month,
    local.day,
  ).add(Duration(days: dayOffset));
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}

final class _Abort implements Exception {
  const _Abort(this.result);
  final ExecuteProposalResult result;
}
