import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/ai_tables.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../domain/ai_proposal.dart';
import '../domain/ai_proposal_repository.dart';

/// Drift persistence AI návrhů (C29 §2). Owner stamping při zápisu;
/// návrhy jsou append-only historie (APL-008).
class DriftAiProposalRepository implements AiProposalRepository {
  DriftAiProposalRepository(this._db);

  final AppDatabase _db;

  Future<String> _currentOwnerId() async {
    final row = await (_db.select(
      _db.localAppState,
    )..where((t) => t.key.equals(localOwnerStateKey))).getSingleOrNull();
    return row?.value ?? localAnonymousOwnerId;
  }

  @override
  Future<void> saveProposed({
    required String id,
    required String requestType,
    required Map<String, Object?> canonicalPayload,
    required String summary,
    required String promptVersion,
    required String schemaVersion,
    required String modelId,
    required DateTime now,
  }) async {
    final owner = await _currentOwnerId();
    await _db
        .into(_db.localAiProposals)
        .insert(
          LocalAiProposalsCompanion.insert(
            id: id,
            requestType: requestType,
            payloadJson: jsonEncode(canonicalPayload),
            summary: summary,
            promptVersion: promptVersion,
            schemaVersion: schemaVersion,
            modelId: modelId,
            createdAt: now.toUtc().millisecondsSinceEpoch,
            rowVersion: 1,
            ownerId: Value(owner),
          ),
        );
  }

  @override
  Future<List<AiProposal>> proposalsForCurrentOwner() async {
    final owner = await _currentOwnerId();
    final rows =
        await (_db.select(_db.localAiProposals)
              ..where((t) => t.ownerId.equals(owner))
              ..orderBy([
                (t) => OrderingTerm.desc(t.createdAt),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return [for (final row in rows) _toDomain(row)];
  }

  @override
  Future<AiProposal?> proposalById(String id) async {
    // Owner-scoped čtení (APL-011): cizí návrh se chová jako neexistující.
    final owner = await _currentOwnerId();
    final row = await (_db.select(
      _db.localAiProposals,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null || row.ownerId != owner ? null : _toDomain(row);
  }

  static const _expiry = Duration(days: 7);

  @override
  Future<DecideProposalResult> decide(
    String id,
    ProposalDecision decision, {
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final row = await (_db.select(
        _db.localAiProposals,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null || row.ownerId != owner) {
        return const DecisionNotFound();
      }
      if (row.status != proposalStatusProposed) {
        return const DecisionInvalidState();
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      Future<void> setStatus(String status) =>
          (_db.update(
            _db.localAiProposals,
          )..where((t) => t.id.equals(id))).write(
            LocalAiProposalsCompanion(
              status: Value(status),
              decidedAt: Value(nowMillis),
              rowVersion: Value(row.rowVersion + 1),
            ),
          );

      // Expirace se vyhodnocuje při rozhodování (APL-007) — jen pro
      // potvrzení; odmítnout lze i starý návrh (zachovaný stav).
      if (decision == ProposalDecision.confirm &&
          nowMillis - row.createdAt > _expiry.inMilliseconds) {
        await setStatus(proposalStatusExpired);
        return const DecisionExpired();
      }
      final newStatus = switch (decision) {
        ProposalDecision.confirm => proposalStatusConfirmed,
        ProposalDecision.reject => proposalStatusRejected,
      };
      await setStatus(newStatus);
      return DecisionSaved(newStatus);
    });
  }

  /// Stavy, ze kterých smí proběhnout execution přechod (C29 §3, C30 §2).
  static const _executableStatuses = {
    proposalStatusConfirmed,
    proposalStatusExecutionFailed,
  };

  @override
  Future<bool> markExecuted(
    String id, {
    required String executedPlanId,
    required DateTime now,
  }) => _markExecution(
    id,
    status: proposalStatusExecuted,
    executedPlanId: executedPlanId,
    now: now,
  );

  @override
  Future<bool> markExecutionFailed(String id, {required DateTime now}) =>
      _markExecution(id, status: proposalStatusExecutionFailed, now: now);

  Future<bool> _markExecution(
    String id, {
    required String status,
    String? executedPlanId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final row = await (_db.select(
        _db.localAiProposals,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null ||
          row.ownerId != owner ||
          !_executableStatuses.contains(row.status)) {
        return false;
      }
      await (_db.update(
        _db.localAiProposals,
      )..where((t) => t.id.equals(id))).write(
        LocalAiProposalsCompanion(
          status: Value(status),
          executedPlanId: Value(executedPlanId),
          rowVersion: Value(row.rowVersion + 1),
        ),
      );
      return true;
    });
  }

  AiProposal _toDomain(LocalAiProposalRow row) => AiProposal(
    id: row.id,
    requestType: row.requestType,
    payload: jsonDecode(row.payloadJson) as Map<String, Object?>,
    summary: row.summary,
    promptVersion: row.promptVersion,
    schemaVersion: row.schemaVersion,
    modelId: row.modelId,
    status: row.status,
    createdAtMillis: row.createdAt,
    decidedAtMillis: row.decidedAt,
    executedPlanId: row.executedPlanId,
  );
}
