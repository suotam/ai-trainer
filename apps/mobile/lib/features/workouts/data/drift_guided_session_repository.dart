import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/guided_session.dart';
import '../domain/guided_session_repository.dart';
import 'workout_session_row_mappers.dart';

/// Drift implementace stavu průvodce (C53 §4/§5): jen sloupce session,
/// všechny mutace v transakci s ověřením ACTIVE/PAUSED; žádná raw výjimka.
class DriftGuidedSessionRepository implements GuidedSessionRepository {
  DriftGuidedSessionRepository(this._db);

  final AppDatabase _db;

  @override
  Future<GuidedSessionRecord?> record(String sessionId) async {
    final row = await (_db.select(
      _db.localWorkoutSessions,
    )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    return row == null ? null : _map(row);
  }

  GuidedSessionRecord _map(LocalWorkoutSessionRow row) => GuidedSessionRecord(
    sessionId: row.id,
    workoutInstanceId: row.workoutInstanceId,
    status: decodeSessionStatus(row.status),
    startedAt: _utc(row.startedAt)!,
    elapsedActiveSeconds: row.elapsedActiveSeconds,
    lastResumedAt: _utc(row.lastResumedAt),
    pausedAt: _utc(row.pausedAt),
    activeStepId: row.activeStepId,
    phase: GuidedPhase.fromCode(row.playerPhase),
    phaseStartedAt: _utc(row.playerPhaseStartedAt),
    activeSetPosition: row.activeSetPosition,
  );

  DateTime? _utc(int? millis) => millis == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);

  @override
  Future<GuidedSessionResult> goToStep({
    required String sessionId,
    required String stepId,
    required DateTime now,
  }) => _mutate(sessionId, now, (row, nowMillis) {
    return LocalWorkoutSessionsCompanion(
      activeStepId: Value(stepId),
      playerPhase: const Value(null),
      playerPhaseStartedAt: const Value(null),
      activeSetPosition: const Value(null),
      updatedAt: Value(nowMillis),
      rowVersion: Value(row.rowVersion + 1),
    );
  });

  @override
  Future<GuidedSessionResult> startPhase({
    required String sessionId,
    required GuidedPhase phase,
    required DateTime now,
    String? stepId,
    int? setPosition,
  }) => _mutate(sessionId, now, (row, nowMillis) {
    if (phase.code == null) {
      return null;
    }
    return LocalWorkoutSessionsCompanion(
      activeStepId: stepId == null ? const Value.absent() : Value(stepId),
      playerPhase: Value(phase.code),
      playerPhaseStartedAt: Value(nowMillis),
      activeSetPosition: Value(setPosition),
      updatedAt: Value(nowMillis),
      rowVersion: Value(row.rowVersion + 1),
    );
  });

  @override
  Future<GuidedSessionResult> clearPhase({
    required String sessionId,
    required DateTime now,
  }) => _mutate(sessionId, now, (row, nowMillis) {
    return LocalWorkoutSessionsCompanion(
      playerPhase: const Value(null),
      playerPhaseStartedAt: const Value(null),
      activeSetPosition: const Value(null),
      updatedAt: Value(nowMillis),
      rowVersion: Value(row.rowVersion + 1),
    );
  });

  @override
  Future<GuidedSessionResult> pause({
    required String sessionId,
    required DateTime now,
  }) => _mutate(sessionId, now, (row, nowMillis) {
    if (row.status != 'ACTIVE') {
      return null;
    }
    final since = row.lastResumedAt ?? row.startedAt;
    final running = ((nowMillis - since) / 1000).floor();
    return LocalWorkoutSessionsCompanion(
      status: const Value('PAUSED'),
      pausedAt: Value(nowMillis),
      elapsedActiveSeconds: Value(
        row.elapsedActiveSeconds + (running < 0 ? 0 : running),
      ),
      updatedAt: Value(nowMillis),
      rowVersion: Value(row.rowVersion + 1),
    );
  });

  @override
  Future<GuidedSessionResult> resume({
    required String sessionId,
    required DateTime now,
  }) => _mutate(sessionId, now, (row, nowMillis) {
    if (row.status != 'PAUSED') {
      return null;
    }
    // Ukotvení fáze se posune o délku pauzy (GSP-009) — odpočet pokračuje
    // tam, kde byl zmrazen.
    final pausedFor = row.pausedAt == null ? 0 : nowMillis - row.pausedAt!;
    return LocalWorkoutSessionsCompanion(
      status: const Value('ACTIVE'),
      lastResumedAt: Value(nowMillis),
      pausedAt: const Value(null),
      playerPhaseStartedAt: row.playerPhaseStartedAt == null
          ? const Value.absent()
          : Value(row.playerPhaseStartedAt! + (pausedFor < 0 ? 0 : pausedFor)),
      updatedAt: Value(nowMillis),
      rowVersion: Value(row.rowVersion + 1),
    );
  });

  /// Společný rámec: session musí existovat a být ACTIVE/PAUSED; builder
  /// vrátí `null` = operace v tomto stavu nedává smysl (typované odmítnutí).
  Future<GuidedSessionResult> _mutate(
    String sessionId,
    DateTime now,
    LocalWorkoutSessionsCompanion? Function(LocalWorkoutSessionRow row, int now)
    build,
  ) {
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.localWorkoutSessions,
      )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (row == null) {
        return const GuidedSessionNotFound();
      }
      if (row.status != 'ACTIVE' && row.status != 'PAUSED') {
        return const GuidedSessionNotActive();
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      final companion = build(row, nowMillis);
      if (companion == null) {
        return const GuidedSessionNotActive();
      }
      await (_db.update(
        _db.localWorkoutSessions,
      )..where((t) => t.id.equals(sessionId))).write(companion);
      return const GuidedSessionSaved();
    });
  }
}
