@Tags(['live'])
library;

/// On-device diagnostika: výpis chatu/akcí/návrhů z vytažené SQLite
/// (`adb shell run-as ... cat app_flutter/ai_trainer.sqlite`). Opt-in přes
/// `AIT_DB=cesta`; nikdy netiskne klíč (DB ho neobsahuje, BYK-001).

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dbPath = Platform.environment['AIT_DB'];
  test('dump', () async {
    final path = dbPath!;
    final db = NativeDatabase(File(path));
    final conn = DatabaseConnection(db);
    final ex = conn.executor;
    await ex.ensureOpen(_User());
    final rows = await ex.runSelect(
      'SELECT role, status, error_kind, position, substr(content,1,1200) AS c, created_at FROM local_chat_messages ORDER BY created_at, position',
      const [],
    );
    for (final r in rows) {
      stdout.writeln(
        '--- ${r['role']} ${r['status']} ${r['error_kind']} pos=${r['position']} t=${r['created_at']}',
      );
      stdout.writeln(r['c']);
    }
    final acts = await ex
        .runSelect('SELECT * FROM local_chat_actions ORDER BY rowid', const [])
        .catchError((_) => <Map<String, Object?>>[]);
    stdout.writeln('actions=${acts.length}');
    for (final a in acts) {
      stdout.writeln(
        a.toString().substring(0, a.toString().length.clamp(0, 400)),
      );
    }
    final props = await ex
        .runSelect(
          'SELECT id, request_type, status, schema_version, prompt_version, created_at, substr(canonical_payload,1,600) AS p FROM local_ai_proposals ORDER BY created_at',
          const [],
        )
        .catchError((_) => <Map<String, Object?>>[]);
    stdout.writeln('proposals=${props.length}');
    for (final p in props) {
      stdout.writeln(p);
    }
    await ex.close();
  }, skip: dbPath == null ? 'opt-in: AIT_DB=<pulled sqlite>' : null);
}

class _User extends QueryExecutorUser {
  @override
  int get schemaVersion => 17;
  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
