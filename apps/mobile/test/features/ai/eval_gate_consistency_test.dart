import 'dart:convert';
import 'dart:io';

import 'package:ai_trainer_mobile/features/ai/data/adjustment_proposal_client_validator.dart';
import 'package:ai_trainer_mobile/features/ai/data/plan_proposal_client_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// R4-07 mobilní strana eval gate (C32 §3, EVG-009): tentýž sdílený dataset
/// přes klientský validátor — konzistence dvojí validace (SOV-003).
/// Fence extrakce a volný text jsou serverová záležitost: cases, jejichž
/// `modelOutput` není přímo JSON payload, se poctivě přeskočí a hlídá se
/// minimální počet klientsky vyhodnotitelných cases (C32 §4.4).
void main() {
  // flutter test běží s working dir apps/mobile.
  final datasetDir = Directory('../../packages/contracts/eval/plan-proposal');

  test('eval gate konzistence: klientský verdikt = očekávaný verdikt '
      '(EVG-003/004/009)', () {
    final files =
        datasetDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    expect(
      files.length,
      greaterThanOrEqualTo(10),
      reason: 'dataset se zmenšil (EVG-007)',
    );

    final failures = <String>[];
    var applicable = 0;
    for (final file in files) {
      final caseJson =
          jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final name = caseJson['name']! as String;
      final expected = caseJson['expected']! as Map<String, Object?>;
      final expectedVerdict = expected['verdict']! as String;

      Object? payload;
      try {
        payload = jsonDecode(caseJson['modelOutput']! as String);
      } on FormatException {
        // Server-only case (fence/volný text) — klient dostává už čistý
        // JSON payload z API, tyhle tvary k němu nikdy nedorazí.
        continue;
      }
      applicable++;

      final canonical = validatePlanProposalPayload(payload);
      final verdict = canonical == null ? 'INVALID' : 'VALID';
      if (verdict != expectedVerdict) {
        failures.add('$name: klient $verdict, očekáváno $expectedVerdict');
        continue;
      }
      if (canonical == null) {
        continue;
      }
      // Kvalitativní vlastnosti validních návrhů (C32 §4.2).
      final workouts = (canonical['workouts']! as List)
          .cast<Map<String, Object?>>();
      if (workouts.isEmpty || workouts.length > 14) {
        failures.add('$name: počet workoutů ${workouts.length} mimo 1–14');
      }
      for (final workout in workouts) {
        final reason = workout['reason'];
        if (reason is! String || reason.trim().isEmpty) {
          failures.add('$name: workout bez reason (EVG-005)');
        }
      }
      final expectedCount = expected['workoutCount'];
      if (expectedCount is int && workouts.length != expectedCount) {
        failures.add(
          '$name: workoutCount ${workouts.length} != $expectedCount',
        );
      }
      final serialized = jsonEncode(canonical);
      final mustNotContain = expected['mustNotContain'];
      if (mustNotContain is List) {
        for (final forbidden in mustNotContain.cast<String>()) {
          if (serialized.contains(forbidden)) {
            failures.add('$name: kanonický výstup obsahuje "$forbidden"');
          }
        }
      }
    }

    expect(
      applicable,
      greaterThanOrEqualTo(8),
      reason: 'málo klientsky vyhodnotitelných cases (C32 §4.4)',
    );
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  test('adjustment eval konzistence: klientský verdikt = očekávaný verdikt '
      '(C37 ASJ-013)', () {
    final files =
        Directory('../../packages/contracts/eval/adjustment-proposal')
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    expect(
      files.length,
      greaterThanOrEqualTo(6),
      reason: 'adjustment dataset se zmenšil (ASJ-013)',
    );

    final failures = <String>[];
    var applicable = 0;
    for (final file in files) {
      final caseJson =
          jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final name = caseJson['name']! as String;
      final expected = caseJson['expected']! as Map<String, Object?>;
      final expectedVerdict = expected['verdict']! as String;

      Object? payload;
      try {
        payload = jsonDecode(caseJson['modelOutput']! as String);
      } on FormatException {
        continue;
      }
      applicable++;

      final canonical = validateAdjustmentProposalPayload(payload);
      final verdict = canonical == null ? 'INVALID' : 'VALID';
      if (verdict != expectedVerdict) {
        failures.add('$name: klient $verdict, očekáváno $expectedVerdict');
        continue;
      }
      if (canonical == null) {
        continue;
      }
      final operations = (canonical['operations']! as List)
          .cast<Map<String, Object?>>();
      for (final operation in operations) {
        final reason = operation['reason'];
        if (reason is! String || reason.trim().isEmpty) {
          failures.add('$name: operace bez reason (ASJ-002)');
        }
      }
      final expectedCount = expected['operationCount'];
      if (expectedCount is int && operations.length != expectedCount) {
        failures.add(
          '$name: operationCount ${operations.length} != $expectedCount',
        );
      }
      final serialized = jsonEncode(canonical);
      final mustNotContain = expected['mustNotContain'];
      if (mustNotContain is List) {
        for (final forbidden in mustNotContain.cast<String>()) {
          if (serialized.contains(forbidden)) {
            failures.add('$name: kanonický výstup obsahuje "$forbidden"');
          }
        }
      }
    }

    expect(
      applicable,
      greaterThanOrEqualTo(6),
      reason: 'málo klientsky vyhodnotitelných adjustment cases',
    );
    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}
