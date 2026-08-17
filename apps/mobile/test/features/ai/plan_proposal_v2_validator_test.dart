import 'dart:convert';

import 'package:ai_trainer_mobile/features/ai/data/adjustment_proposal_client_validator.dart';
import 'package:ai_trainer_mobile/features/ai/data/ai_output_schemas.dart';
import 'package:ai_trainer_mobile/features/ai/data/plan_proposal_v2_validator.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/exercise_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// R8-02 testy validátoru v2 (C52 PS2-014): validní kanonizace, XOR
/// katalog/vlastní, pořadí a unikátnost sekcí, MAIN povinný, konzistence
/// sad s předpisem, REST tvar, meze, neznámá pole zahozena; schéma
/// structured outputs nese enum katalogu.
Map<String, Object?> validWorkout({int dayOffset = 0, bool reason = true}) => {
  'title': 'Lezecký den',
  'workoutType': 'STRENGTH',
  'dayOffset': dayOffset,
  if (reason) 'reason': 'Síla prstů a kompenzace.',
  'plannedDurationMinutes': 60,
  'sections': [
    {
      'sectionType': 'WARM_UP',
      'steps': [
        {
          'stepType': 'EXERCISE',
          'exerciseCode': 'JUMPING_JACKS',
          'prescription': 'DURATION',
          'sets': [
            {'durationSeconds': 60},
          ],
        },
        {
          'stepType': 'EXERCISE',
          'exerciseCode': 'SHOULDER_DISLOCATES',
          'prescription': 'SET_REP',
          'sets': [
            {'repetitions': 10},
          ],
          'note': 'Pomalu.',
        },
      ],
    },
    {
      'sectionType': 'MAIN',
      'title': 'Hlavní část',
      'steps': [
        {
          'stepType': 'EXERCISE',
          'exerciseCode': 'HANGBOARD_MAX_HANG',
          'prescription': 'DURATION',
          'sets': [
            {'durationSeconds': 10, 'restAfterSeconds': 180},
            {'durationSeconds': 10, 'restAfterSeconds': 180},
          ],
        },
        {'stepType': 'REST', 'durationSeconds': 120},
        {
          'stepType': 'EXERCISE',
          'customTitle': 'Kampus lehce',
          'instructions': 'Nohy na stupačkách, jen dohmaty 1-2-3.',
          'prescription': 'SET_REP',
          'sets': [
            {'repetitions': 5, 'restAfterSeconds': 90},
          ],
        },
        {
          'stepType': 'EXERCISE',
          'exerciseCode': 'RING_DIP',
          'prescription': 'SET_REP',
          'sets': [
            {'repetitions': 8, 'weightKg': 0, 'restAfterSeconds': 90},
          ],
          'unknown': 'zahodit',
        },
      ],
    },
    {
      'sectionType': 'COOLDOWN',
      'steps': [
        {
          'stepType': 'EXERCISE',
          'exerciseCode': 'FOREARM_MASSAGE',
          'prescription': 'DURATION',
          'sets': [
            {'durationSeconds': 120},
          ],
        },
      ],
    },
  ],
};

Map<String, Object?> validPlan() => {
  'summary': 'Týden zaměřený na prsty.',
  'planTitle': 'Lezecký týden',
  'workouts': [validWorkout(), validWorkout(dayOffset: 2)],
  'extra': 'ignored',
};

Map<String, Object?> deep(Map<String, Object?> source) =>
    jsonDecode(jsonEncode(source)) as Map<String, Object?>;

void main() {
  test('validní plán v2 se kanonizuje: sekce/kroky/sady, neznámá pole '
      'zahozena, deterministicky (PS2-001/010)', () {
    final canonical = validatePlanProposalV2Payload(validPlan());
    expect(canonical, isNotNull);
    expect(canonical!.containsKey('extra'), isFalse);
    final workouts = canonical['workouts']! as List;
    expect(workouts, hasLength(2));
    final first = workouts.first as Map<String, Object?>;
    final sections = first['sections']! as List;
    expect(sections, hasLength(3));
    final main = sections[1] as Map<String, Object?>;
    expect(main['title'], 'Hlavní část');
    final steps = main['steps']! as List;
    expect(steps, hasLength(4));
    final dip = steps[3] as Map<String, Object?>;
    expect(dip.containsKey('unknown'), isFalse);
    expect(dip['exerciseCode'], 'RING_DIP');
    expect(((dip['sets']! as List).first as Map)['restAfterSeconds'], 90);
    final rest = steps[1] as Map<String, Object?>;
    expect(rest, {'stepType': 'REST', 'durationSeconds': 120});
    final custom = steps[2] as Map<String, Object?>;
    expect(custom['customTitle'], 'Kampus lehce');
    expect(custom.containsKey('exerciseCode'), isFalse);
    // Determinismus.
    expect(
      jsonEncode(validatePlanProposalV2Payload(validPlan())),
      jsonEncode(canonical),
    );
  });

  test('nevalidní celek = null bez opravy: XOR, neznámý kód, sekce, sady, '
      'REST, meze (PS2-003/004/007/008/009)', () {
    Map<String, Object?> plan(void Function(Map<String, Object?> w) mutate) {
      final p = deep(validPlan());
      mutate((p['workouts']! as List).first as Map<String, Object?>);
      return p;
    }

    Map<String, Object?> mainStep(Map<String, Object?> w, int i) =>
        (((w['sections']! as List)[1] as Map)['steps'] as List)[i]
            as Map<String, Object?>;

    // Vlastní bez popisu.
    expect(
      validatePlanProposalV2Payload(
        plan((w) => mainStep(w, 2).remove('instructions')),
      ),
      isNull,
    );
    // Kód i vlastní název zároveň.
    expect(
      validatePlanProposalV2Payload(
        plan((w) => mainStep(w, 0)['customTitle'] = 'x'),
      ),
      isNull,
    );
    // Neznámý kód.
    expect(
      validatePlanProposalV2Payload(
        plan((w) => mainStep(w, 0)['exerciseCode'] = 'SOCCER_DRILL'),
      ),
      isNull,
    );
    // Sada nekonzistentní s předpisem (DURATION s repetitions).
    expect(
      validatePlanProposalV2Payload(
        plan((w) => (mainStep(w, 0)['sets'] as List)[0] = {'repetitions': 5}),
      ),
      isNull,
    );
    // REST se sadami.
    expect(
      validatePlanProposalV2Payload(
        plan((w) => mainStep(w, 1)['sets'] = <Object>[]),
      ),
      isNull,
    );
    // Sekce mimo pořadí (COOLDOWN před MAIN).
    expect(
      validatePlanProposalV2Payload(
        plan((w) {
          final s = w['sections']! as List;
          final cool = s.removeAt(2);
          s.insert(1, cool);
        }),
      ),
      isNull,
    );
    // Duplicitní typ sekce.
    expect(
      validatePlanProposalV2Payload(
        plan(
          (w) => (w['sections']! as List).add(
            deep((w['sections']! as List)[1] as Map<String, Object?>),
          ),
        ),
      ),
      isNull,
    );
    // Bez MAIN.
    expect(
      validatePlanProposalV2Payload(
        plan((w) => (w['sections']! as List).removeAt(1)),
      ),
      isNull,
    );
    // Legacy exercises místo sections.
    expect(
      validatePlanProposalV2Payload(
        plan((w) {
          w.remove('sections');
          w['exercises'] = [
            {'title': 'Dřep', 'sets': 3, 'repetitions': 10},
          ];
        }),
      ),
      isNull,
    );
    // Meze: 31 kroků.
    expect(
      validatePlanProposalV2Payload(
        plan((w) {
          final steps = ((w['sections']! as List)[1] as Map)['steps'] as List;
          while (steps.length < 20) {
            steps.add({'stepType': 'REST', 'durationSeconds': 30});
          }
          final warm = ((w['sections']! as List)[0] as Map)['steps'] as List;
          while (warm.length < 11) {
            warm.add({'stepType': 'REST', 'durationSeconds': 30});
          }
        }),
      ),
      isNull,
    );
    // Prázdný / nevalidní obal.
    expect(validatePlanProposalV2Payload(null), isNull);
    expect(validatePlanProposalV2Payload({'summary': 's'}), isNull);
  });

  test('úpravy v2: REPLACE/ADD nesou workout v2, REPLACE bez dayOffset '
      '(C52 §3.2)', () {
    final adjustment = {
      'summary': 'Uber.',
      'operations': [
        {
          'operation': 'REPLACE',
          'reason': 'Únava.',
          'target': {'dayOffset': 1, 'title': 'Silový A'},
          'workout': validWorkout(reason: false)..remove('dayOffset'),
        },
        {
          'operation': 'ADD',
          'reason': 'Regenerace.',
          'workout': validWorkout(dayOffset: 3, reason: false),
        },
        {
          'operation': 'CANCEL',
          'reason': 'Bolest.',
          'target': {'dayOffset': 4, 'title': 'Běh'},
        },
      ],
    };
    final canonical = validateAdjustmentProposalV2Payload(adjustment);
    expect(canonical, isNotNull);
    final ops = canonical!['operations']! as List;
    expect(
      ((ops[0] as Map)['workout'] as Map).containsKey('dayOffset'),
      isFalse,
    );
    expect(((ops[1] as Map)['workout'] as Map)['dayOffset'], 3);
    // REPLACE s dayOffset je nevalidní.
    final bad = deep(adjustment);
    (((bad['operations'] as List)[0] as Map)['workout'] as Map)['dayOffset'] =
        1;
    expect(validateAdjustmentProposalV2Payload(bad), isNull);
    // v1 validátor sections nezná — kanonizace je zahodí (neznámé pole);
    // proto se pro nové výstupy používá výhradně v2 (PS2-012).
    final v1 = validateAdjustmentProposalPayload(adjustment)!;
    expect(
      (((v1['operations']! as List)[0] as Map)['workout'] as Map).containsKey(
        'sections',
      ),
      isFalse,
    );
  });

  test('schéma structured outputs zrcadlí tvar: enum katalogu, sekce, '
      'EXERCISE/REST varianty, adjustment operace (C52 §3.3)', () {
    final json = jsonEncode(planProposalSchemaV2);
    expect(json, contains('"HANGBOARD_MAX_HANG"'));
    expect(json, contains('"WARM_UP","MAIN","COOLDOWN"'));
    expect(json, contains('"REST"'));
    expect(json, contains('"customTitle"'));
    expect(json, isNot(contains('"exercises"')));
    final workoutSchema = workoutV2Schema(
      withDayOffset: false,
      withReason: false,
    );
    expect((workoutSchema['required']! as List), isNot(contains('dayOffset')));
    final adjustmentJson = jsonEncode(adjustmentProposalSchemaV2);
    expect(adjustmentJson, contains('"REPLACE"'));
    expect(adjustmentJson, contains('"toDayOffset"'));
    // Enum katalogu = aktivní kódy C51.
    expect(json.contains(activeExerciseCodes().last), isTrue);
  });
}
