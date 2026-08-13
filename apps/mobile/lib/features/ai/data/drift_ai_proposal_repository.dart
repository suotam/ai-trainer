import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
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
    final row = await (_db.select(
      _db.localAiProposals,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
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
