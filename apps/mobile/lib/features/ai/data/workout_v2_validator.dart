/// Klientská validace tvaru `workout v2` (C52 §2, PS2-001/004/007/008/009):
/// sekce → kroky (katalog C51 XOR vlastní s popisem; EXERCISE/REST) → sady.
/// Čistá deterministická funkce; nevalidní → `null`, nikdy oprava; vrací
/// kanonickou mapu (jen schválená pole, stabilní pořadí).
library;

import '../../workouts/domain/exercise_catalog.dart';

const workoutTypesV2 = {
  'STRENGTH',
  'ENDURANCE',
  'MOBILITY',
  'TECHNIQUE',
  'GENERAL',
};

const _sectionOrder = ['WARM_UP', 'MAIN', 'COOLDOWN'];
const _maxStepsPerWorkout = 30;

/// [requireDayOffset]: plán a ADD ano; REPLACE ne (zakázán, C37 §3).
/// [requireReason]: plán ano; operace úprav ne (důvod nese operace).
Map<String, Object?>? validateWorkoutV2(
  Object? raw, {
  required bool requireDayOffset,
  required bool requireReason,
}) {
  if (raw is! Map) {
    return null;
  }
  final title = requiredText(raw['title'], 120);
  final workoutType = requiredText(raw['workoutType'], 40);
  if (title == null ||
      workoutType == null ||
      !workoutTypesV2.contains(workoutType)) {
    return null;
  }
  int? dayOffset;
  if (requireDayOffset) {
    dayOffset = requiredInt(raw['dayOffset'], 0, 27);
    if (dayOffset == null) {
      return null;
    }
  } else if (raw.containsKey('dayOffset')) {
    return null;
  }
  String? reason;
  if (requireReason) {
    reason = requiredText(raw['reason'], 500);
    if (reason == null) {
      return null;
    }
  }
  int? duration;
  if (raw.containsKey('plannedDurationMinutes')) {
    duration = requiredInt(raw['plannedDurationMinutes'], 1, 600);
    if (duration == null) {
      return null;
    }
  }
  final sectionsRaw = raw['sections'];
  if (sectionsRaw is! List || sectionsRaw.isEmpty || sectionsRaw.length > 3) {
    return null;
  }
  final sections = <Map<String, Object?>>[];
  var lastOrder = -1;
  var totalSteps = 0;
  var hasMain = false;
  for (final sectionRaw in sectionsRaw) {
    final section = _validateSection(sectionRaw);
    if (section == null) {
      return null;
    }
    // Každý typ nejvýše jednou, pořadí WARM_UP → MAIN → COOLDOWN (PS2-007).
    final order = _sectionOrder.indexOf(section['sectionType']! as String);
    if (order <= lastOrder) {
      return null;
    }
    lastOrder = order;
    hasMain = hasMain || order == 1;
    totalSteps += (section['steps']! as List).length;
    sections.add(section);
  }
  if (!hasMain || totalSteps > _maxStepsPerWorkout) {
    return null;
  }
  return {
    'title': title,
    'workoutType': workoutType,
    'dayOffset': ?dayOffset,
    'reason': ?reason,
    'plannedDurationMinutes': ?duration,
    'sections': sections,
  };
}

Map<String, Object?>? _validateSection(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  final sectionType = requiredText(raw['sectionType'], 20);
  if (sectionType == null || !_sectionOrder.contains(sectionType)) {
    return null;
  }
  String? title;
  if (raw.containsKey('title') && raw['title'] != null) {
    title = requiredText(raw['title'], 120);
    if (title == null) {
      return null;
    }
  }
  final stepsRaw = raw['steps'];
  if (stepsRaw is! List || stepsRaw.isEmpty || stepsRaw.length > 20) {
    return null;
  }
  final steps = <Map<String, Object?>>[];
  for (final stepRaw in stepsRaw) {
    final step = _validateStep(stepRaw);
    if (step == null) {
      return null;
    }
    steps.add(step);
  }
  return {'sectionType': sectionType, 'title': ?title, 'steps': steps};
}

Map<String, Object?>? _validateStep(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  final stepType = requiredText(raw['stepType'], 20);
  String? note;
  if (raw.containsKey('note') && raw['note'] != null) {
    note = requiredText(raw['note'], 300);
    if (note == null) {
      return null;
    }
  }
  switch (stepType) {
    case 'REST':
      // Jen durationSeconds (+ note) — PS2-009.
      final duration = requiredInt(raw['durationSeconds'], 5, 600);
      if (duration == null ||
          raw.containsKey('sets') ||
          raw.containsKey('exerciseCode') ||
          raw.containsKey('customTitle') ||
          raw.containsKey('prescription')) {
        return null;
      }
      return {'stepType': 'REST', 'durationSeconds': duration, 'note': ?note};
    case 'EXERCISE':
      if (raw.containsKey('durationSeconds')) {
        return null;
      }
      final code = raw['exerciseCode'];
      final customTitle = raw['customTitle'];
      // Katalog XOR vlastní s povinným popisem (PS2-003, EXC-008).
      String? exerciseCode;
      String? title;
      String? instructions;
      if (code != null && customTitle == null) {
        exerciseCode = requiredText(code, 40);
        final entry = exerciseCode == null
            ? null
            : exerciseCatalogEntry(exerciseCode);
        if (entry == null || entry.deprecated) {
          return null;
        }
      } else if (code == null && customTitle != null) {
        title = requiredText(customTitle, 120);
        instructions = requiredText(raw['instructions'], 500);
        if (title == null || instructions == null) {
          return null;
        }
      } else {
        return null;
      }
      final prescription = requiredText(raw['prescription'], 20);
      if (prescription != 'SET_REP' && prescription != 'DURATION') {
        return null;
      }
      final setsRaw = raw['sets'];
      if (setsRaw is! List || setsRaw.isEmpty || setsRaw.length > 20) {
        return null;
      }
      final sets = <Map<String, Object?>>[];
      for (final setRaw in setsRaw) {
        final set = _validateSet(
          setRaw,
          isDuration: prescription == 'DURATION',
        );
        if (set == null) {
          return null;
        }
        sets.add(set);
      }
      return {
        'stepType': 'EXERCISE',
        'exerciseCode': ?exerciseCode,
        'customTitle': ?title,
        'instructions': ?instructions,
        'prescription': prescription,
        'sets': sets,
        'note': ?note,
      };
    default:
      return null;
  }
}

/// Konzistence sady s předpisem (PS2-008): SET_REP ↔ repetitions,
/// DURATION ↔ durationSeconds.
Map<String, Object?>? _validateSet(Object? raw, {required bool isDuration}) {
  if (raw is! Map) {
    return null;
  }
  int? repetitions;
  int? durationSeconds;
  if (isDuration) {
    if (raw.containsKey('repetitions')) {
      return null;
    }
    durationSeconds = requiredInt(raw['durationSeconds'], 1, 3600);
    if (durationSeconds == null) {
      return null;
    }
  } else {
    if (raw.containsKey('durationSeconds')) {
      return null;
    }
    repetitions = requiredInt(raw['repetitions'], 1, 100);
    if (repetitions == null) {
      return null;
    }
  }
  double? weight;
  if (raw.containsKey('weightKg') && raw['weightKg'] != null) {
    final value = raw['weightKg'];
    if (value is! num || value < 0 || value > 500) {
      return null;
    }
    weight = value.toDouble();
  }
  int? rest;
  if (raw.containsKey('restAfterSeconds') && raw['restAfterSeconds'] != null) {
    rest = requiredInt(raw['restAfterSeconds'], 0, 600);
    if (rest == null) {
      return null;
    }
  }
  return {
    'repetitions': ?repetitions,
    'durationSeconds': ?durationSeconds,
    'weightKg': ?weight,
    'restAfterSeconds': ?rest,
  };
}

String? requiredText(Object? value, int maxLength) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.length > maxLength) {
    return null;
  }
  return trimmed;
}

int? requiredInt(Object? value, int min, int max) {
  if (value is! int || value < min || value > max) {
    return null;
  }
  return value;
}
