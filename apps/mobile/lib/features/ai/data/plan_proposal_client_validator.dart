/// Klientská validace `plan-proposal-schema-v1` (C28 §2–§3, SOV-003 —
/// obrana do hloubky: server validoval, klient před persistencí znovu).
/// Čistá deterministická funkce; nevalidní payload → `null`, nikdy oprava
/// (SOV-005). Vrací kanonickou mapu (jen schválená pole, SOV-010).
library;

const _workoutTypes = {
  'STRENGTH',
  'ENDURANCE',
  'MOBILITY',
  'TECHNIQUE',
  'GENERAL',
};

Map<String, Object?>? validatePlanProposalPayload(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  final summary = _requiredText(raw['summary'], 2000);
  final planTitle = _requiredText(raw['planTitle'], 120);
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
    final workout = _validateWorkout(workoutRaw);
    if (workout == null) {
      return null;
    }
    workouts.add(workout);
  }
  return {'summary': summary, 'planTitle': planTitle, 'workouts': workouts};
}

Map<String, Object?>? _validateWorkout(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  final title = _requiredText(raw['title'], 120);
  final workoutType = _requiredText(raw['workoutType'], 40);
  final dayOffset = _requiredInt(raw['dayOffset'], 0, 27);
  final reason = _requiredText(raw['reason'], 500);
  if (title == null ||
      workoutType == null ||
      !_workoutTypes.contains(workoutType) ||
      dayOffset == null ||
      reason == null) {
    return null;
  }
  int? duration;
  if (raw.containsKey('plannedDurationMinutes')) {
    duration = _requiredInt(raw['plannedDurationMinutes'], 1, 600);
    if (duration == null) {
      return null;
    }
  }
  final exercises = <Map<String, Object?>>[];
  if (raw.containsKey('exercises')) {
    final exercisesRaw = raw['exercises'];
    if (exercisesRaw is! List || exercisesRaw.length > 20) {
      return null;
    }
    for (final exerciseRaw in exercisesRaw) {
      final exercise = _validateExercise(exerciseRaw);
      if (exercise == null) {
        return null;
      }
      exercises.add(exercise);
    }
  }
  return {
    'title': title,
    'workoutType': workoutType,
    'dayOffset': dayOffset,
    'reason': reason,
    'plannedDurationMinutes': ?duration,
    if (exercises.isNotEmpty) 'exercises': exercises,
  };
}

Map<String, Object?>? _validateExercise(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  final title = _requiredText(raw['title'], 120);
  final sets = _requiredInt(raw['sets'], 1, 20);
  final repetitions = _requiredInt(raw['repetitions'], 1, 100);
  if (title == null || sets == null || repetitions == null) {
    return null;
  }
  double? weight;
  if (raw.containsKey('weightKg')) {
    final value = raw['weightKg'];
    if (value is! num || value < 0 || value > 500) {
      return null;
    }
    weight = value.toDouble();
  }
  return {
    'title': title,
    'sets': sets,
    'repetitions': repetitions,
    'weightKg': ?weight,
  };
}

String? _requiredText(Object? value, int maxLength) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.length > maxLength) {
    return null;
  }
  return trimmed;
}

int? _requiredInt(Object? value, int min, int max) {
  if (value is! int || value < min || value > max) {
    return null;
  }
  return value;
}
