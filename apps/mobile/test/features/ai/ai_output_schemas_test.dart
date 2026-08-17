import 'package:ai_trainer_mobile/features/ai/data/ai_output_schemas.dart';
import 'package:ai_trainer_mobile/features/ai/data/ai_prompt_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// On-device nález 8: structured outputs odmítly `adjustment-proposal-schema-v2`
/// (30 volitelných vlastností > limit 24) → HTTP 400 → „nelze provést změnu".
/// Strážní test drží všechna odesílaná schémata pod limitem.
void main() {
  test('počítadlo volitelných vlastností napříč stromem včetně anyOf', () {
    expect(
      optionalPropertyCount({
        'type': 'object',
        'properties': {
          'a': {'type': 'string'},
          'b': {
            'type': 'array',
            'items': {
              'anyOf': [
                {
                  'type': 'object',
                  'properties': {
                    'x': {'type': 'integer'},
                    'y': {'type': 'integer'},
                  },
                  'required': ['x'],
                },
                {
                  'type': 'object',
                  'properties': {
                    'z': {'type': 'integer'},
                  },
                  'required': [],
                },
              ],
            },
          },
        },
        'required': ['a'],
      }),
      3,
    );
  });

  test(
    'všechna schémata structured outputs jsou pod limitem 24 volitelných',
    () {
      for (final (name, schema) in [
        ('plan v2', planProposalSchemaV2),
        ('adjustment v2', adjustmentProposalSchemaV2),
        ('chat reply', chatReplySchema),
      ]) {
        final count = optionalPropertyCount(schema);
        expect(
          count,
          lessThanOrEqualTo(structuredOutputOptionalLimit),
          reason: '$name má $count volitelných vlastností',
        );
      }
      // Úpravy: workout jednou (REPLACE/ADD sdílená větev, nález 8b) = 8 +
      // volitelný `target` a `dayOffset` = 10; plán = 8 (2 varianty × 4).
      expect(optionalPropertyCount(adjustmentProposalSchemaV2), 10);
      expect(optionalPropertyCount(planProposalSchemaV2), 8);
    },
  );
}
