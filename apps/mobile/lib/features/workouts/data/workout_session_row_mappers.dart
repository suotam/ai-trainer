/// Mapping session Drift řádků na doménové modely (fyzický model §16).
/// Neznámý status je chyba dat, nikoli tichý default (PDR-008).
library;

import '../../../core/database/app_database.dart';
import '../domain/workout_read_model.dart';
import '../domain/workout_session.dart';

WorkoutSessionStatus decodeSessionStatus(String code) {
  for (final value in WorkoutSessionStatus.values) {
    if (value.code == code) {
      return value;
    }
  }
  throw UnsupportedPersistedValue('local_workout_sessions.status', code);
}

WorkoutSessionSnapshot mapSessionSnapshot(LocalWorkoutSessionRow row) =>
    WorkoutSessionSnapshot(
      id: row.id,
      workoutInstanceId: row.workoutInstanceId,
      instanceRevisionNumber: row.instanceRevisionNumber,
      status: decodeSessionStatus(row.status),
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        row.startedAt,
        isUtc: true,
      ),
    );
