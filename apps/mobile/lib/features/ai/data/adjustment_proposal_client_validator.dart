/// Klientská validace `adjustment-proposal-schema-v1` (C37 §3–§4,
/// SOV-003 — obrana do hloubky). Čistá deterministická funkce; nevalidní
/// payload → `null`, nikdy oprava. Vrací kanonickou mapu (jen schválená
/// pole). Tvarová tabulka operací přesně (ASJ-003).
library;

const _workoutTypes = {
  'STRENGTH',
  'ENDURANCE',
  'MOBILITY',
  'TECHNIQUE',
  'GENERAL',
};

const _operationKinds = {'MOVE', 'CANCEL', 'REPLACE', 'ADD'};

Map<String, Object?>? validateAdjustmentProposalPayload(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  final summary = _requiredText(raw['summary'], 2000);
  final operationsRaw = raw['operations'];
  if (summary == null ||
      operationsRaw is! List ||
      operationsRaw.isEmpty ||
      operationsRaw.length > 10) {
    return null;
  }
  final operations = <Map<String, Object?>>[];
  for (final operationRaw in operationsRaw) {
    final operation = _validateOperation(operationRaw);
    if (operation == null) {
      return null;
    }
    operations.add(operation);
  }
  return {'summary': summary, 'operations': operations};
}

Map<String, Object?>? _validateOperation(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  final kind = _requiredText(raw['operation'], 20);
  // Vysvětlitelnost povinná per operace (ASJ-002).
  final reason = _requiredText(raw['reason'], 500);
  if (kind == null || !_operationKinds.contains(kind) || reason == null) {
    return null;
  }
  final hasTarget = raw.containsKey('target');
  final hasWorkout = raw.containsKey('workout');
  final hasToDay = raw.containsKey('toDayOffset');
  final shapeOk = switch (kind) {
    'MOVE' => hasTarget && hasToDay && !hasWorkout,
    'CANCEL' => hasTarget && !hasToDay && !hasWorkout,
    'REPLACE' => hasTarget && hasWorkout && !hasToDay,
    'ADD' => hasWorkout && !hasTarget && !hasToDay,
    _ => false,
  };
  if (!shapeOk) {
    return null;
  }

  Map<String, Object?>? target;
  if (hasTarget) {
    target = _validateTarget(raw['target']);
    if (target == null) {
      return null;
    }
  }
  int? toDayOffset;
  if (hasToDay) {
    toDayOffset = _requiredInt(raw['toDayOffset'], 0, 27);
    if (toDayOffset == null) {
      return null;
    }
  }
  Map<String, Object?>? workout;
  if (hasWorkout) {
    // REPLACE dědí den z targetu — dayOffset je zakázán (C37 §3).
    workout = _validateWorkout(raw['workout'], requireDayOffset: kind == 'ADD');
    if (workout == null) {
      return null;
    }
  }
  return {
    'operation': kind,
    'reason': reason,
    'target': ?target,
    'toDayOffset': ?toDayOffset,
    'workout': ?workout,
  };
}

/// Target by-value z kontextového týdne (ASJ-004).
Map<String, Object?>? _validateTarget(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  final dayOffset = _requiredInt(raw['dayOffset'], 0, 6);
  final title = _requiredText(raw['title'], 120);
  if (dayOffset == null || title == null) {
    return null;
  }
  return {'dayOffset': dayOffset, 'title': title};
}

Map<String, Object?>? _validateWorkout(
  Object? raw, {
  required bool requireDayOffset,
}) {
  if (raw is! Map) {
    return null;
  }
  final title = _requiredText(raw['title'], 120);
  final workoutType = _requiredText(raw['workoutType'], 40);
  if (title == null ||
      workoutType == null ||
      !_workoutTypes.contains(workoutType)) {
    return null;
  }
  int? dayOffset;
  if (requireDayOffset) {
    dayOffset = _requiredInt(raw['dayOffset'], 0, 27);
    if (dayOffset == null) {
      return null;
    }
  } else if (raw.containsKey('dayOffset')) {
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
    'dayOffset': ?dayOffset,
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
