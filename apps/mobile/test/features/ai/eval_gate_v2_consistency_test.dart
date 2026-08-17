import 'dart:convert';
import 'dart:io';

import 'package:ai_trainer_mobile/features/ai/data/plan_proposal_v2_validator.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/exercise_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// R8-02 eval gate plánu v2 (C52 PS2-011/014, C32 vzor): sdílený dataset
/// `packages/contracts/eval/plan-proposal-v2` (reálný výstup ze živé sondy
/// + nevalidní varianty) přes klientský validátor v2 — verdikty se shodují
/// a validní návrhy mají jen katalogové kroky nebo vlastní s popisem.
void main() {
  final datasetDir = Directory(
    '../../packages/contracts/eval/plan-proposal-v2',
  );

  test('eval v2: klientský verdikt = očekávaný; validní návrhy jsou '
      'proveditelné (katalog/vlastní s popisem, sekce, sady)', () {
    final files =
        datasetDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    expect(files.length, greaterThanOrEqualTo(7), reason: 'dataset se zmenšil');

    final failures = <String>[];
    var validCount = 0;
    for (final file in files) {
      final caseJson =
          jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final name = caseJson['name']! as String;
      final expected = caseJson['expected']! as Map<String, Object?>;
      final payload = jsonDecode(caseJson['modelOutput']! as String);
      final canonical = validatePlanProposalV2Payload(payload);
      final verdict = canonical == null ? 'INVALID' : 'VALID';
      if (verdict != expected['verdict']) {
        failures.add(
          '$name: klient $verdict, očekáváno ${expected['verdict']}',
        );
        continue;
      }
      if (canonical == null) {
        continue;
      }
      validCount++;
      final workouts = (canonical['workouts']! as List).cast<Map>();
      final expectedCount = expected['workoutCount'];
      if (expectedCount is int && workouts.length != expectedCount) {
        failures.add(
          '$name: workoutCount ${workouts.length} != $expectedCount',
        );
      }
      for (final workout in workouts) {
        final sections = (workout['sections'] as List).cast<Map>();
        if (!sections.any((s) => s['sectionType'] == 'MAIN')) {
          failures.add('$name: workout bez MAIN');
        }
        for (final section in sections) {
          for (final step in (section['steps'] as List).cast<Map>()) {
            if (step['stepType'] == 'REST') {
              continue;
            }
            final code = step['exerciseCode'];
            if (code != null && !isKnownExerciseCode(code as String)) {
              failures.add('$name: neznámý kód $code');
            }
            if (code == null &&
                '${step['instructions'] ?? ''}'.trim().isEmpty) {
              failures.add('$name: vlastní cvik bez popisu');
            }
            if ((step['sets'] as List).isEmpty) {
              failures.add('$name: krok bez sad');
            }
          }
        }
      }
    }
    expect(validCount, greaterThanOrEqualTo(1));
    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}
