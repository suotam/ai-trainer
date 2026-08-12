import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../../../core/ids/id_generator.dart';
import '../domain/complete_workout_result.dart';
import '../domain/workout_completion_repository.dart';
import '../domain/workout_feedback.dart';

/// Drift implementace dokončení workoutu (fyzický model §15.3, PDR-006/007).
///
/// Celé dokončení je jedna atomická transakce; selhání kteréhokoli kroku
/// vrátí celou transakci (rollback). Idempotence je vynucena aplikačně
/// (už dokončená session → no-op) i DB unikátem `local_activity_summaries.
/// workout_session_id`. Planned snapshot ani performance data se nemažou
/// ani nepřepisují.
class DriftWorkoutCompletionRepository implements WorkoutCompletionRepository {
  DriftWorkoutCompletionRepository(this._db, this._idGenerator);

  final AppDatabase _db;
  final IdGenerator _idGenerator;

  static const String _activeSessionKey = 'active_session_id';

  @override
  Future<CompleteWorkoutResult> completeWorkout({
    required String sessionId,
    required DateTime now,
    WorkoutFeedbackInput? feedback,
  }) {
    return _db.transaction(() async {
      // 1. Validovat podporovaný stav session.
      final session = await (_db.select(
        _db.localWorkoutSessions,
      )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (session == null) {
        return const CompletionSessionNotFound();
      }
      if (session.status == 'COMPLETED') {
        // Idempotence: původní completed_at, summary ani pointer se nemění.
        return const WorkoutAlreadyCompleted();
      }
      if (session.status != 'ACTIVE' && session.status != 'PAUSED') {
        return const CompletionSessionNotCompletable();
      }

      final instance =
          await (_db.select(_db.localWorkoutInstances)
                ..where((t) => t.id.equals(session.workoutInstanceId)))
              .getSingleOrNull();
      if (instance == null) {
        return const CompletionInstanceNotFound();
      }
      // Instance musí být v dokončitelném (nikoli terminálním) stavu.
      const completableInstance = {'READY', 'IN_PROGRESS', 'PAUSED'};
      if (!completableInstance.contains(instance.status)) {
        return const CompletionInconsistentState();
      }

      final nowMillis = now.toUtc().millisecondsSinceEpoch;

      // 2. Dopočítat dokončení kroků z completion stavu setů.
      final stepCounts = await _finalizeSteps(sessionId, nowMillis);

      // 3. Uložit volitelný feedback (feedback lze přeskočit; prázdný se
      //    neukládá). Jedna zpětná vazba na session (§12 unique).
      if (feedback != null && feedback.hasContent) {
        await _db
            .into(_db.localWorkoutFeedback)
            .insert(
              LocalWorkoutFeedbackCompanion.insert(
                id: _idGenerator.newId(),
                workoutSessionId: sessionId,
                overallEffort: Value(feedback.overallEffort),
                feeling: Value(feedback.feeling?.code),
                painReported: feedback.painReported,
                notes: Value(feedback.notes),
                createdAt: nowMillis,
                updatedAt: nowMillis,
              ),
            );
      }

      // 4. Nastavit session COMPLETED + completed_at.
      await (_db.update(
        _db.localWorkoutSessions,
      )..where((t) => t.id.equals(sessionId))).write(
        LocalWorkoutSessionsCompanion(
          status: const Value('COMPLETED'),
          completedAt: Value(nowMillis),
          updatedAt: Value(nowMillis),
          rowVersion: Value(session.rowVersion + 1),
        ),
      );

      // 5. Nastavit instance COMPLETED nebo PARTIALLY_COMPLETED.
      final instanceStatus =
          stepCounts.total > 0 && stepCounts.completed == stepCounts.total
          ? 'COMPLETED'
          : 'PARTIALLY_COMPLETED';
      await (_db.update(
        _db.localWorkoutInstances,
      )..where((t) => t.id.equals(instance.id))).write(
        LocalWorkoutInstancesCompanion(
          status: Value(instanceStatus),
          completedAt: Value(nowMillis),
          updatedAt: Value(nowMillis),
          rowVersion: Value(instance.rowVersion + 1),
        ),
      );

      // 6. Vytvořit ActivitySummary s feedback snapshotem overall_effort (§13).
      final summaryId = _idGenerator.newId();
      await _db
          .into(_db.localActivitySummaries)
          .insert(
            LocalActivitySummariesCompanion.insert(
              id: summaryId,
              workoutInstanceId: instance.id,
              workoutSessionId: sessionId,
              titleSnapshot: instance.title,
              workoutType: instance.workoutType,
              startedAt: session.startedAt,
              completedAt: nowMillis,
              activeDurationSeconds: session.elapsedActiveSeconds,
              completedStepCount: stepCounts.completed,
              totalStepCount: stepCounts.total,
              overallEffort: Value(feedback?.overallEffort),
              createdAt: nowMillis,
            ),
          );

      // 7. Vyčistit technický active-session pointer, jen pokud ukazuje sem.
      await (_db.delete(_db.localAppState)..where(
            (t) => t.key.equals(_activeSessionKey) & t.value.equals(sessionId),
          ))
          .go();

      // R2-05: summary vlastní aktuální lokální vlastník (C2 §4) a dokončení
      // mění stav session/instance — dříve synchronizované jsou znovu DIRTY
      // (state-based push, C10 §5.3). Anonymní hodnota je no-op vůči defaultům.
      await _db.customStatement(
        'UPDATE local_activity_summaries SET owner_id = '
        "COALESCE((SELECT value FROM local_app_state WHERE key = '$localOwnerStateKey'), '$localAnonymousOwnerId') "
        'WHERE id = ?',
        [summaryId],
      );
      await _db.customStatement(
        "UPDATE local_workout_sessions SET sync_state = 'DIRTY' "
        "WHERE id = ? AND sync_state = 'SYNCED'",
        [sessionId],
      );
      await _db.customStatement(
        "UPDATE local_workout_instances SET sync_state = 'DIRTY' "
        "WHERE id = ? AND sync_state = 'SYNCED'",
        [instance.id],
      );

      return WorkoutCompleted(summaryId);
    });
  }

  /// Dopočítá dokončení EXERCISE kroků: krok je COMPLETED, má-li aspoň jeden
  /// set a všechny jsou COMPLETED; PARTIAL při části dokončených; jinak
  /// NOT_STARTED. Vrací počty pro instanci a summary. Nepřepisuje actual
  /// hodnoty setů (PDR-003/012).
  Future<_StepCounts> _finalizeSteps(String sessionId, int nowMillis) async {
    final stepPerformances = await (_db.select(
      _db.localStepPerformances,
    )..where((t) => t.workoutSessionId.equals(sessionId))).get();

    var completed = 0;
    for (final stepPerf in stepPerformances) {
      final sets = await (_db.select(
        _db.localSetPerformances,
      )..where((t) => t.stepPerformanceId.equals(stepPerf.id))).get();

      final String status;
      if (sets.isNotEmpty && sets.every((s) => s.status == 'COMPLETED')) {
        status = 'COMPLETED';
        completed += 1;
      } else if (sets.any((s) => s.status == 'COMPLETED')) {
        status = 'PARTIAL';
      } else {
        status = 'NOT_STARTED';
      }

      if (status != stepPerf.status) {
        await (_db.update(
          _db.localStepPerformances,
        )..where((t) => t.id.equals(stepPerf.id))).write(
          LocalStepPerformancesCompanion(
            status: Value(status),
            updatedAt: Value(nowMillis),
            rowVersion: Value(stepPerf.rowVersion + 1),
          ),
        );
      }
    }

    return _StepCounts(completed: completed, total: stepPerformances.length);
  }
}

class _StepCounts {
  const _StepCounts({required this.completed, required this.total});
  final int completed;
  final int total;
}
