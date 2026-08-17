@Tags(['live'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:ai_trainer_mobile/features/ai/data/anthropic_direct_client.dart';
import 'package:ai_trainer_mobile/features/ai/data/plan_proposal_v2_validator.dart';
import 'package:ai_trainer_mobile/features/ai/domain/byok_key_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Živá opt-in sonda plánu v2 (C52 PS2-014, AITRAINER_LIVE_SMOKE=1): přesná
/// telefonní cesta (prompt v3 + structured outputs + validátor v2) proti
/// reálnému modelu; raw i kanonický výstup se ukládá do build/live-smoke
/// jako kandidát eval fixture.
class _EnvKeyStore implements ByokKeyStore {
  @override
  Future<String?> read() async =>
      Platform.environment['AITRAINER_AI_ANTHROPIC_APIKEY'];

  @override
  Future<void> write(String key) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  final live = Platform.environment['AITRAINER_LIVE_SMOKE'] == '1';

  test(
    'live plan v2: reálný návrh projde validátorem v2 a má sekce',
    () async {
      final client = AnthropicDirectClient(
        keyStore: _EnvKeyStore(),
        httpClient: http.Client(),
        timeout: const Duration(seconds: 120),
      );
      final response = await client.requestPlanProposal(
        context: const {
          'requestType': 'PLAN_PROPOSAL',
          'sports': [
            {
              'sportCode': 'CLIMBING',
              'role': 'PRIMARY',
              'priority': 'CRITICAL',
              'frequencyPerWeek': 3,
            },
            {
              'sportCode': 'FLOORBALL',
              'role': 'SECONDARY',
              'priority': 'MEDIUM',
              'frequencyPerWeek': 2,
            },
          ],
          'goals': [
            {
              'title': 'Lézt 7a na skále',
              'goalType': 'PERFORMANCE',
              'priority': 'PRIMARY',
            },
          ],
          'typicalWeek': [
            {'dayOfWeek': 'MON', 'level': 'AVAILABLE', 'budgetMinutes': 90},
            {'dayOfWeek': 'WED', 'level': 'AVAILABLE', 'budgetMinutes': 90},
            {'dayOfWeek': 'FRI', 'level': 'AVAILABLE', 'budgetMinutes': 60},
          ],
          'equipment': [
            'GYMNASTIC_RINGS',
            'SUSPENSION_TRAINER',
            'HANGBOARD',
            'PULL_UP_BAR',
            'RESISTANCE_BANDS',
            'CLIMBING_WALL_ACCESS',
          ],
          'constraints': [
            {'title': 'Citlivé prsty po zranění'},
          ],
          'statistics': {
            'periodDays': 30,
            'plannedCount': 0,
            'completedCount': 0,
            'manualActivityCount': 0,
            'manualMinutes': 0,
          },
        },
      );
      Directory('build/live-smoke').createSync(recursive: true);
      File(
        'build/live-smoke/plan-v2-raw.json',
      ).writeAsStringSync(jsonEncode(response.proposal));
      expect(response.schemaVersion, 'plan-proposal-schema-v2');
      expect(response.promptVersion, 'plan-proposal-v3');
      final canonical = validatePlanProposalV2Payload(response.proposal);
      File('build/live-smoke/plan-v2-verdict.txt').writeAsStringSync(
        canonical == null
            ? 'INVALID'
            : 'VALID workouts=${(canonical['workouts']! as List).length}',
      );
      expect(canonical, isNotNull, reason: 'raw viz build/live-smoke');
      final workouts = canonical!['workouts']! as List;
      expect(workouts, isNotEmpty);
      for (final w in workouts.cast<Map>()) {
        expect(w['sections'], isA<List>());
      }
      File(
        'build/live-smoke/plan-v2-canonical.json',
      ).writeAsStringSync(jsonEncode(canonical));
    },
    skip: !live ? 'opt-in: AITRAINER_LIVE_SMOKE=1' : null,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
