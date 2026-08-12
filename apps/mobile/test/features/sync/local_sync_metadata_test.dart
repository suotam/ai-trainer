import 'dart:io';

import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_local_sync_metadata_repository.dart';
import 'package:ai_trainer_mobile/features/sync/domain/local_sync_metadata.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// R2-01 lokální sync metadata a outbox (C2 §6/§7, `LSM-*`) nad skutečnou
/// SQLite. Ověřuje restart-safe frontu, idempotenci dle klíče, deterministické
/// pořadí a ID vlastníka. Bez sítě.
void main() {
  final now = DateTime.utc(2026, 7, 20, 8);

  test('ID lokálního vlastníka je stabilní local-anonymous', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftLocalSyncMetadataRepository(db, SequenceIdGenerator());
    expect(await repo.localOwnerId(), 'local-anonymous');
  });

  test('enqueue přiřadí sekvenci, vlastníka a stav PENDING', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftLocalSyncMetadataRepository(db, SequenceIdGenerator());

    final e = await repo.enqueue(
      const OutboxOperation(
        entityType: 'workout_session',
        entityId: 'ses-1',
        operationType: OutboxOperationType.create,
        idempotencyKey: 'op-1',
      ),
      now: now,
    );
    expect(e.sequence, 0);
    expect(e.ownerId, 'local-anonymous');
    expect(e.status, 'PENDING');
    expect(e.operationType, OutboxOperationType.create);
  });

  test('opakovaný enqueue se stejným klíčem je idempotentní', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftLocalSyncMetadataRepository(db, SequenceIdGenerator());
    const op = OutboxOperation(
      entityType: 'set_performance',
      entityId: 'setp-1',
      operationType: OutboxOperationType.update,
      idempotencyKey: 'stable-key',
    );

    final first = await repo.enqueue(op, now: now);
    final second = await repo.enqueue(op, now: now);

    expect(second.id, first.id);
    expect(second.sequence, first.sequence);
    expect((await repo.pendingOperations()).length, 1);
  });

  test('pending operace mají deterministické pořadí dle sekvence', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftLocalSyncMetadataRepository(db, SequenceIdGenerator());
    for (var i = 0; i < 3; i++) {
      await repo.enqueue(
        OutboxOperation(
          entityType: 'workout_session',
          entityId: 'ses-$i',
          operationType: OutboxOperationType.create,
          idempotencyKey: 'k-$i',
        ),
        now: now,
      );
    }
    final pending = await repo.pendingOperations();
    expect(pending.map((e) => e.sequence).toList(), [0, 1, 2]);
    expect(pending.map((e) => e.entityId).toList(), [
      'ses-0',
      'ses-1',
      'ses-2',
    ]);
  });

  test('outbox položka přežije restart aplikace (skutečný reopen)', () async {
    final dir = await Directory.systemTemp.createTemp('r2_01_outbox');
    final path = '${dir.path}/outbox.sqlite';
    addTearDown(() => dir.delete(recursive: true));

    final first = AppDatabase(NativeDatabase(File(path)));
    await DriftLocalSyncMetadataRepository(
      first,
      SequenceIdGenerator(),
    ).enqueue(
      const OutboxOperation(
        entityType: 'workout_session',
        entityId: 'ses-1',
        operationType: OutboxOperationType.create,
        idempotencyKey: 'survives-restart',
      ),
      now: now,
    );
    await first.close();

    // „Restart" — nová instance nad stejným souborem.
    final second = AppDatabase(NativeDatabase(File(path)));
    addTearDown(second.close);
    final pending = await DriftLocalSyncMetadataRepository(
      second,
      SequenceIdGenerator(),
    ).pendingOperations();

    expect(pending.length, 1);
    expect(pending.single.idempotencyKey, 'survives-restart');
    expect(pending.single.entityId, 'ses-1');
  });
}
