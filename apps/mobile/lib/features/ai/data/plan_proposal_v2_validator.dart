/// Klientská validace `plan-proposal-schema-v2` (C52 §3.1, PS2-001):
/// C28 obal (summary, planTitle, workouts 1–14) s workouty v2 (sekce,
/// kroky nad katalogem C51, sady). Čistá deterministická funkce; nevalidní
/// celek → `null`, nikdy oprava; kanonická mapa.
library;

import 'workout_v2_validator.dart';

Map<String, Object?>? validatePlanProposalV2Payload(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  final summary = requiredText(raw['summary'], 2000);
  final planTitle = requiredText(raw['planTitle'], 120);
  final workoutsRaw = raw['workouts'];
  if (summary == null ||
      planTitle == null ||
      workoutsRaw is! List ||
      workoutsRaw.isEmpty ||
      workoutsRaw.length > 14) {
    return null;
  }
  final workouts = <Map<String, Object?>>[];
  for (final workoutRaw in workoutsRaw) {
    final workout = validateWorkoutV2(
      workoutRaw,
      requireDayOffset: true,
      requireReason: true,
    );
    if (workout == null) {
      return null;
    }
    workouts.add(workout);
  }
  return {'summary': summary, 'planTitle': planTitle, 'workouts': workouts};
}
