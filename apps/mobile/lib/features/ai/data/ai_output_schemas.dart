/// JSON schémata structured outputs pro plán v2 a úpravy v2 (C52 §3.3):
/// pojistka tvaru vynucená API — `required`, `enum` (vč. katalogu C51),
/// `additionalProperties: false`, `anyOf` pro XOR katalog/vlastní a
/// EXERCISE/REST. Číselné meze, délky, pořadí sekcí a konzistenci sad
/// hlídá výhradně validátor (`workout_v2_validator.dart`, PS2-004).
library;

import '../../workouts/domain/exercise_catalog.dart';
import 'workout_v2_validator.dart';

Map<String, Object?> _setSchema({required bool duration}) => {
  'type': 'object',
  'properties': {
    if (duration)
      'durationSeconds': {'type': 'integer'}
    else
      'repetitions': {'type': 'integer'},
    'weightKg': {'type': 'number'},
    'restAfterSeconds': {'type': 'integer'},
  },
  'required': [duration ? 'durationSeconds' : 'repetitions'],
  'additionalProperties': false,
};

Map<String, Object?> _exerciseStepSchema({
  required bool catalog,
  required bool duration,
}) => {
  'type': 'object',
  'properties': {
    'stepType': {
      'type': 'string',
      'enum': ['EXERCISE'],
    },
    if (catalog)
      'exerciseCode': {'type': 'string', 'enum': activeExerciseCodes()}
    else ...{
      'customTitle': {'type': 'string'},
      'instructions': {'type': 'string'},
    },
    'prescription': {
      'type': 'string',
      'enum': [duration ? 'DURATION' : 'SET_REP'],
    },
    'sets': {'type': 'array', 'items': _setSchema(duration: duration)},
    'note': {'type': 'string'},
  },
  'required': [
    'stepType',
    if (catalog) 'exerciseCode' else ...['customTitle', 'instructions'],
    'prescription',
    'sets',
  ],
  'additionalProperties': false,
};

final Map<String, Object?> _restStepSchema = {
  'type': 'object',
  'properties': {
    'stepType': {
      'type': 'string',
      'enum': ['REST'],
    },
    'durationSeconds': {'type': 'integer'},
    'note': {'type': 'string'},
  },
  'required': ['stepType', 'durationSeconds'],
  'additionalProperties': false,
};

final Map<String, Object?> _sectionSchema = {
  'type': 'object',
  'properties': {
    'sectionType': {
      'type': 'string',
      'enum': ['WARM_UP', 'MAIN', 'COOLDOWN'],
    },
    'title': {'type': 'string'},
    'steps': {
      'type': 'array',
      'items': {
        'anyOf': [
          _exerciseStepSchema(catalog: true, duration: false),
          _exerciseStepSchema(catalog: true, duration: true),
          _exerciseStepSchema(catalog: false, duration: false),
          _exerciseStepSchema(catalog: false, duration: true),
          _restStepSchema,
        ],
      },
    },
  },
  'required': ['sectionType', 'steps'],
  'additionalProperties': false,
};

/// Workout v2 (C52 §2). [withDayOffset]/[withReason] dle použití
/// (plán: obojí; ADD: den; REPLACE: nic).
Map<String, Object?> workoutV2Schema({
  required bool withDayOffset,
  required bool withReason,
}) => {
  'type': 'object',
  'properties': {
    'title': {'type': 'string'},
    'workoutType': {'type': 'string', 'enum': workoutTypesV2.toList()},
    if (withDayOffset) 'dayOffset': {'type': 'integer'},
    if (withReason) 'reason': {'type': 'string'},
    'plannedDurationMinutes': {'type': 'integer'},
    'sections': {'type': 'array', 'items': _sectionSchema},
  },
  'required': [
    'title',
    'workoutType',
    if (withDayOffset) 'dayOffset',
    if (withReason) 'reason',
    'sections',
  ],
  'additionalProperties': false,
};

/// `plan-proposal-schema-v2` (C52 §3.1).
final Map<String, Object?> planProposalSchemaV2 = {
  'type': 'object',
  'properties': {
    'summary': {'type': 'string'},
    'planTitle': {'type': 'string'},
    'workouts': {
      'type': 'array',
      'items': workoutV2Schema(withDayOffset: true, withReason: true),
    },
  },
  'required': ['summary', 'planTitle', 'workouts'],
  'additionalProperties': false,
};

Map<String, Object?> _operationSchema(String kind) {
  final target = {
    'type': 'object',
    'properties': {
      'dayOffset': {'type': 'integer'},
      'title': {'type': 'string'},
    },
    'required': ['dayOffset', 'title'],
    'additionalProperties': false,
  };
  return {
    'type': 'object',
    'properties': {
      'operation': {
        'type': 'string',
        'enum': [kind],
      },
      'reason': {'type': 'string'},
      if (kind == 'MOVE' || kind == 'CANCEL' || kind == 'REPLACE')
        'target': target,
      if (kind == 'MOVE') 'toDayOffset': {'type': 'integer'},
      if (kind == 'REPLACE')
        'workout': workoutV2Schema(withDayOffset: false, withReason: false),
      if (kind == 'ADD')
        'workout': workoutV2Schema(withDayOffset: true, withReason: false),
    },
    'required': [
      'operation',
      'reason',
      if (kind != 'ADD') 'target',
      if (kind == 'MOVE') 'toDayOffset',
      if (kind == 'REPLACE' || kind == 'ADD') 'workout',
    ],
    'additionalProperties': false,
  };
}

/// `adjustment-proposal-schema-v2` (C52 §3.2): C37 tabulka operací,
/// `workout` = workout v2 bez `reason`.
final Map<String, Object?> adjustmentProposalSchemaV2 = {
  'type': 'object',
  'properties': {
    'summary': {'type': 'string'},
    'operations': {
      'type': 'array',
      'items': {
        'anyOf': [
          _operationSchema('MOVE'),
          _operationSchema('CANCEL'),
          _operationSchema('REPLACE'),
          _operationSchema('ADD'),
        ],
      },
    },
  },
  'required': ['summary', 'operations'],
  'additionalProperties': false,
};
