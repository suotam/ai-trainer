@Tags(['live'])
library;

/// On-device repro startu session nad vytaženou SQLite (opt-in `AIT_DB`):
/// pro každou instanci workoutu zkusí `startSession` v kopii DB a vypíše
/// typovaný výsledek nebo výjimku (nález „couldn't start the workout").
import 'dart:io';

import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dbPath = Platform.environment['AIT_DB'];
  test(
    'start session repro',
    () async {
      final db = AppDatabase(NativeDatabase(File(dbPath!)));
      final repo = DriftWorkoutSessionRepository(db);
      final rows = await db
          .customSelect(
            'SELECT id, title, status, scheduled_local_date, revision_number, '
            'started_session_id FROM local_workout_instances '
            'ORDER BY scheduled_local_date',
          )
          .get();
      final sessions = await db
          .customSelect(
            'SELECT id, workout_instance_id, status FROM local_workout_sessions',
          )
          .get();
      stdout.writeln('sessions=${[for (final s in sessions) s.data]}');
      for (final r in rows) {
        stdout.writeln('instance ${r.data}');
        final id = r.data['id'] as String;
        try {
          await db.transaction(() async {
            final res = await repo.startSession(
              workoutInstanceId: id,
              newSessionId: 'repro-$id',
              now: DateTime.now(),
            );
            throw _Rollback(res.toString());
          });
        } on _Rollback catch (e) {
          stdout.writeln('  -> ${e.result}');
        } catch (e) {
          stdout.writeln('  !! EXCEPTION $e');
        }
      }
      await db.close();
    },
    skip: dbPath == null ? 'opt-in: AIT_DB=<pulled sqlite>' : null,
  );
}

class _Rollback implements Exception {
  _Rollback(this.result);
  final String result;
}
