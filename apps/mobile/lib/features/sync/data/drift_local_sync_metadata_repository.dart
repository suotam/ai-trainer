import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../../../core/ids/id_generator.dart';
import '../domain/local_sync_metadata.dart';
import '../domain/local_sync_metadata_repository.dart';

/// Drift implementace lokálních sync metadat a outboxu (R2-01, C2 §6/§7).
///
/// Enqueue běží v jedné transakci: přiřadí deterministické `sequence`
/// (max+1) a stabilní `idempotency_key`; opakování se stejným klíčem je
/// idempotentní (LSM-008/009). Bez sítě a bez odesílání.
class DriftLocalSyncMetadataRepository implements LocalSyncMetadataRepository {
  DriftLocalSyncMetadataRepository(this._db, this._idGenerator);

  final AppDatabase _db;
  final IdGenerator _idGenerator;

  @override
  Future<String> localOwnerId() async {
    final row = await (_db.select(
      _db.localAppState,
    )..where((t) => t.key.equals(localOwnerStateKey))).getSingleOrNull();
    return row?.value ?? localAnonymousOwnerId;
  }

  @override
  Future<OutboxEntry> enqueue(
    OutboxOperation operation, {
    required DateTime now,
  }) {
    return _db.transaction(() async {
      // Idempotence dle stabilního klíče: existující položku vrať beze změny.
      final existing =
          await (_db.select(_db.localOutbox)..where(
                (t) => t.idempotencyKey.equals(operation.idempotencyKey),
              ))
              .getSingleOrNull();
      if (existing != null) {
        return _map(existing);
      }

      final maxSeq =
          await (_db.selectOnly(_db.localOutbox)
                ..addColumns([_db.localOutbox.sequence.max()]))
              .map((r) => r.read(_db.localOutbox.sequence.max()))
              .getSingleOrNull();
      final nextSeq = (maxSeq ?? -1) + 1;
      final owner = await localOwnerId();
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      final id = _idGenerator.newId();

      await _db
          .into(_db.localOutbox)
          .insert(
            LocalOutboxCompanion.insert(
              id: id,
              ownerId: Value(owner),
              entityType: operation.entityType,
              entityId: operation.entityId,
              operationType: operation.operationType.code,
              idempotencyKey: operation.idempotencyKey,
              sequence: nextSeq,
              createdAt: nowMillis,
            ),
          );

      final row = await (_db.select(
        _db.localOutbox,
      )..where((t) => t.id.equals(id))).getSingle();
      return _map(row);
    });
  }

  @override
  Future<List<OutboxEntry>> pendingOperations() async {
    final rows =
        await (_db.select(_db.localOutbox)
              ..where((t) => t.status.equals('PENDING'))
              ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
            .get();
    return rows.map(_map).toList(growable: false);
  }

  OutboxEntry _map(LocalOutboxRow row) => OutboxEntry(
    id: row.id,
    ownerId: row.ownerId,
    entityType: row.entityType,
    entityId: row.entityId,
    operationType: OutboxOperationType.fromCode(row.operationType),
    idempotencyKey: row.idempotencyKey,
    sequence: row.sequence,
    status: row.status,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
  );
}
