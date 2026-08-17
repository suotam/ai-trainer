@Tags(['live'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:ai_trainer_mobile/features/ai/data/adjustment_proposal_client_validator.dart';
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
      expect(response.promptVersion, 'plan-proposal-v4');
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

  test(
    'live adjustment v2 (on-device nález 8): schéma úprav projde API a '
    'reálný návrh validátorem v2',
    () async {
      final client = AnthropicDirectClient(
        keyStore: _EnvKeyStore(),
        httpClient: http.Client(),
        timeout: const Duration(seconds: 120),
      );
      final response = await client.requestPlanProposal(
        requestType: 'ADJUSTMENT_PROPOSAL',
        context: const {
          'requestType': 'ADJUSTMENT_PROPOSAL',
          'sports': [
            {
              'sportCode': 'CLIMBING',
              'role': 'PRIMARY',
              'priority': 'CRITICAL',
              'frequencyPerWeek': 3,
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
          ],
          'equipment': ['HANGBOARD', 'GYMNASTIC_RINGS', 'FOAM_ROLLER'],
          'constraints': [],
          'statistics': {
            'periodDays': 30,
            'plannedCount': 4,
            'completedCount': 2,
            'manualActivityCount': 0,
            'manualMinutes': 0,
          },
          'weekPlan': [
            {
              'dayOffset': 0,
              'title': 'Lezecký den',
              'workoutType': 'STRENGTH',
              'status': 'PLANNED',
              'plannedDurationMinutes': 90,
            },
            {
              'dayOffset': 2,
              'title': 'Kompenzace',
              'workoutType': 'STRENGTH',
              'status': 'PLANNED',
              'plannedDurationMinutes': 45,
            },
          ],
          'checkIns': {
            'today': {'energyLevel': 2, 'fatigueLevel': 4, 'hasPain': false},
            'aggregates': {'periodDays': 7, 'checkInCount': 1},
          },
          'safety': {'state': 'CAUTION', 'flags': []},
          'athleteRequest':
              'Dnes večer chci místo lezení jen 20minutový strečink.',
        },
      );
      Directory('build/live-smoke').createSync(recursive: true);
      File(
        'build/live-smoke/adjustment-v2-raw.json',
      ).writeAsStringSync(jsonEncode(response.proposal));
      expect(response.schemaVersion, 'adjustment-proposal-schema-v2');
      expect(response.promptVersion, 'adjustment-proposal-v4');
      final canonical = validateAdjustmentProposalV2Payload(response.proposal);
      File('build/live-smoke/adjustment-v2-verdict.txt').writeAsStringSync(
        canonical == null
            ? 'INVALID'
            : 'VALID operations=${(canonical['operations']! as List).length}',
      );
      expect(canonical, isNotNull, reason: 'raw viz build/live-smoke');
      expect(canonical!['operations'], isNotEmpty);
    },
    skip: !live ? 'opt-in: AITRAINER_LIVE_SMOKE=1' : null,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
