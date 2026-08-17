/// JSON schémata structured outputs pro plán v2 a úpravy v2 (C52 §3.3):
/// pojistka tvaru vynucená API — `required`, `enum` (vč. katalogu C51),
/// `additionalProperties: false`, `anyOf` pro XOR katalog/vlastní a
/// EXERCISE/REST. Číselné meze, délky, pořadí sekcí a konzistenci sad
/// hlídá výhradně validátor (`workout_v2_validator.dart`, PS2-004).
///
/// **Limit API (on-device nález 8):** structured outputs odmítnou schéma
/// s více než 24 volitelnými (ne-`required`) vlastnostmi napříč celým
/// stromem včetně `anyOf` větví (HTTP 400 „too many optional parameters").
/// Proto jsou `plannedDurationMinutes` a `restAfterSeconds` (0 = bez pauzy)
/// povinné, sekce nemá `title` a REST krok nemá `note` — volitelné zůstávají
/// jen `weightKg` a `note` u cviku (8 na workout). Úpravy nesou workout jen
/// jednou (REPLACE/ADD sdílená větev — dvakrát byla gramatika „too large",
/// nález 8b) + volitelný `target`/`dayOffset` = 10. Strážní test:
/// `optionalPropertyCount` ≤ 24 (`ai_output_schemas_test`).
library;

import '../../workouts/domain/exercise_catalog.dart';
import 'workout_v2_validator.dart';

/// Sada: `repetitions` (SET_REP) nebo `durationSeconds` (DURATION) — obě
/// ve schématu volitelné, konzistenci s `prescription` hlídá validátor
/// (nález 8b: jedna varianta místo dvou drží gramatiku malou).
final Map<String, Object?> _setSchema = {
  'type': 'object',
  'properties': {
    'repetitions': {'type': 'integer'},
    'durationSeconds': {'type': 'integer'},
    'weightKg': {'type': 'number'},
    'restAfterSeconds': {'type': 'integer'},
  },
  'required': ['restAfterSeconds'],
  'additionalProperties': false,
};

/// Krok cviku: katalogový (`exerciseCode` z enum C51) nebo vlastní
/// (`customTitle` + `instructions`) — XOR hlídá validátor; enum katalogu je
/// ve schématu právě jednou.
Map<String, Object?> _exerciseStepSchema({required bool catalog}) => {
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
      'enum': ['SET_REP', 'DURATION'],
    },
    'sets': {'type': 'array', 'items': _setSchema},
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
    'steps': {
      'type': 'array',
      'items': {
        'anyOf': [
          _exerciseStepSchema(catalog: true),
          _exerciseStepSchema(catalog: false),
          _restStepSchema,
        ],
      },
    },
  },
  'required': ['sectionType', 'steps'],
  'additionalProperties': false,
};

/// Workout v2 (C52 §2). [withDayOffset]/[withReason] dle použití
/// (plán: obojí povinné; úpravy: `dayOffset` volitelný — ADD ho vyžaduje,
/// REPLACE zakazuje, hlídá validátor; `reason` nic). [dayOffsetRequired]
/// = false nechá `dayOffset` ve schématu jako volitelný.
Map<String, Object?> workoutV2Schema({
  required bool withDayOffset,
  required bool withReason,
  bool dayOffsetRequired = true,
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
    if (withDayOffset && dayOffsetRequired) 'dayOffset',
    if (withReason) 'reason',
    'plannedDurationMinutes',
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
        // REPLACE a ADD sdílejí jednu větev (nález 8b): workout v2 se ve
        // schématu vyskytuje jen jednou — dvakrát byla „compiled grammar
        // too large" (HTTP 400). Který z nich vyžaduje `target` (REPLACE) a
        // který `dayOffset` (ADD), hlídá validátor (PS2-004).
        'enum': kind == 'WORKOUT' ? ['REPLACE', 'ADD'] : [kind],
      },
      'reason': {'type': 'string'},
      'target': target,
      if (kind == 'MOVE') 'toDayOffset': {'type': 'integer'},
      if (kind == 'WORKOUT')
        'workout': workoutV2Schema(
          withDayOffset: true,
          withReason: false,
          dayOffsetRequired: false,
        ),
    },
    'required': [
      'operation',
      'reason',
      if (kind != 'WORKOUT') 'target',
      if (kind == 'MOVE') 'toDayOffset',
      if (kind == 'WORKOUT') 'workout',
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
          _operationSchema('WORKOUT'),
        ],
      },
    },
  },
  'required': ['summary', 'operations'],
  'additionalProperties': false,
};

/// Limit structured outputs na volitelné vlastnosti (nález 8): API počítá
/// všechny ne-`required` vlastnosti v celém stromu schématu (každý výskyt,
/// včetně `anyOf` větví). Hranice 24 → schéma s vyšším počtem = HTTP 400.
const int structuredOutputOptionalLimit = 24;

/// Deterministický součet volitelných vlastností napříč [schema].
int optionalPropertyCount(Object? schema) {
  if (schema is Map) {
    var count = 0;
    final properties = schema['properties'];
    if (properties is Map) {
      final required = (schema['required'] as List?)?.cast<Object?>() ?? [];
      for (final entry in properties.entries) {
        if (!required.contains(entry.key)) {
          count++;
        }
        count += optionalPropertyCount(entry.value);
      }
    }
    for (final key in ['items', 'anyOf', 'oneOf', 'allOf']) {
      final child = schema[key];
      if (child != null) {
        count += optionalPropertyCount(child);
      }
    }
    return count;
  }
  if (schema is List) {
    var count = 0;
    for (final item in schema) {
      count += optionalPropertyCount(item);
    }
    return count;
  }
  return 0;
}
