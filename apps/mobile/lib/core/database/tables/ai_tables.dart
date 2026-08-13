/// Drift tabulky R4 AI návrhů (C29 §2).
///
/// `local_ai_proposals` je lokální reviewovatelný artefakt — nese výhradně
/// kanonický validovaný payload (APL-002) a povinnou trojici verzí
/// (APL-003). Návrhy se v P0 nesynchronizují (mimo C24 registr, APL-011);
/// attach bezpodmínečný. Žádné mazání — append-only historie (APL-008).
library;

import 'package:drift/drift.dart';

import 'workout_tables.dart';

/// Stabilní kódy stavů návrhu (C29 §3).
const String proposalStatusProposed = 'PROPOSED';
const String proposalStatusConfirmed = 'CONFIRMED';
const String proposalStatusRejected = 'REJECTED';
const String proposalStatusExecuted = 'EXECUTED';
const String proposalStatusExecutionFailed = 'EXECUTION_FAILED';
const String proposalStatusExpired = 'EXPIRED';

@DataClassName('LocalAiProposalRow')
class LocalAiProposals extends Table {
  @override
  String get tableName => 'local_ai_proposals';

  TextColumn get id => text()();
  TextColumn get requestType => text()();
  TextColumn get payloadJson => text()();
  TextColumn get summary => text()();
  TextColumn get promptVersion => text()();
  TextColumn get schemaVersion => text()();
  TextColumn get modelId => text()();
  TextColumn get status =>
      text().withDefault(const Constant(proposalStatusProposed))();
  IntColumn get createdAt => integer()();
  IntColumn get decidedAt => integer().nullable()();
  TextColumn get executedPlanId => text().nullable()();
  IntColumn get rowVersion => integer()();

  TextColumn get ownerId =>
      text().withDefault(const Constant(localAnonymousOwnerId))();
  TextColumn get syncState =>
      text().withDefault(const Constant(syncStateLocalOnly))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (status IN ('PROPOSED','CONFIRMED','REJECTED','EXECUTED',"
        "'EXECUTION_FAILED','EXPIRED'))",
    'CHECK (length(trim(summary)) > 0)',
    'CHECK (length(trim(prompt_version)) > 0)',
    'CHECK (length(trim(schema_version)) > 0)',
    'CHECK (length(trim(model_id)) > 0)',
    'CHECK (row_version >= 1)',
    syncStateCheck,
  ];
}
