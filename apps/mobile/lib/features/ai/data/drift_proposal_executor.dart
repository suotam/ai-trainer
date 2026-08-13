import '../../../core/database/app_database.dart';
import '../../../core/database/tables/ai_tables.dart';
import '../../../core/database/tables/plan_tables.dart';
import '../../plan/domain/training_plan.dart';
import '../../plan/domain/training_plan_repository.dart';
import '../domain/ai_proposal_repository.dart';
import '../domain/proposal_executor.dart';

/// Provedení potvrzeného návrhu výhradně přes C20 port (CSE-001) v jedné
/// transakci (CSE-003). Doménová pravidla (MPC-002/004) platí beze změny
/// (CSE-002); selhání = rollback + EXECUTION_FAILED po něm (CSE-005).
class DriftProposalExecutor implements ProposalExecutor {
  DriftProposalExecutor(this._db, this._plans, this._proposals);

  final AppDatabase _db;
  final TrainingPlanRepository _plans;
  final AiProposalRepository _proposals;

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
