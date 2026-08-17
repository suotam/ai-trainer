import 'package:ai_trainer_mobile/features/workouts/domain/exercise_catalog.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/exercise_illustrations.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/exercise_pose.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/exercise_illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// R8-04 testy ilustrací (C54 EXI-010): úplnost mapování kód → archetyp
/// (každý kód C51 má záznam), archetypy validní (snímky = topologie,
/// body v 0..1), deterministická interpolace, widget kreslí i fallback.
void main() {
  test('každý katalogový kód má záznam v mapování (EXI-007); archetypy jsou '
      'validní a existují', () {
    for (final entry in exerciseCatalog) {
      expect(
        exerciseIllustrationByCode.containsKey(entry.code),
        isTrue,
        reason: 'chybí mapování ${entry.code}',
      );
      final archetype = exerciseIllustrationByCode[entry.code];
      if (archetype != null) {
        expect(
          poseArchetypes.containsKey(archetype),
          isTrue,
          reason: 'neznámý archetyp $archetype (${entry.code})',
        );
        expect(illustrationFor(entry.code), isNotNull);
      }
    }
    // Mapování nemá kódy mimo katalog.
    for (final code in exerciseIllustrationByCode.keys) {
      expect(isKnownExerciseCode(code), isTrue, reason: code);
    }
    for (final MapEntry(key: name, value: animation)
        in poseArchetypes.entries) {
      expect(animation.isValid, isTrue, reason: name);
      for (final frame in animation.frames) {
        for (final point in frame) {
          expect(point.dx, inInclusiveRange(-0.1, 1.1), reason: name);
          expect(point.dy, inInclusiveRange(-0.1, 1.1), reason: name);
        }
      }
    }
    expect(illustrationFor('NOT_A_CODE'), isNull);
  });

  test('poseAt je deterministická: krajní snímky, střed, ping-pong zpět, '
      'cyklus dokola (EXI-002)', () {
    final animation = ExercisePoseAnimation(
      topology: forearmTopology,
      frames: [
        [const Offset(0, 0), const Offset(0.5, 0), const Offset(1, 0)],
        [const Offset(0, 1), const Offset(0.5, 1), const Offset(1, 1)],
      ],
    );
    expect(poseAt(animation, 0).map((p) => p.dy), [0, 0, 0]);
    expect(poseAt(animation, 0.5).map((p) => p.dy), [1, 1, 1]);
    // Ping-pong: t=0.25 = uprostřed cesty tam (eased 0.5), t=0.75 zpět.
    expect(poseAt(animation, 0.25).first.dy, closeTo(0.5, 1e-9));
    expect(poseAt(animation, 0.75).first.dy, closeTo(0.5, 1e-9));
    expect(poseAt(animation, 1.0).map((p) => p.dy), [0, 0, 0]);
    expect(poseAt(animation, 0.3), poseAt(animation, 1.3));

    final cycle = ExercisePoseAnimation(
      topology: forearmTopology,
      loop: PoseLoop.cycle,
      frames: [
        [const Offset(0, 0), const Offset(0, 0), const Offset(0, 0)],
        [const Offset(1, 0), const Offset(1, 0), const Offset(1, 0)],
      ],
    );
    expect(poseAt(cycle, 0).first.dx, 0);
    expect(poseAt(cycle, 0.5).first.dx, 1);
    // Druhá polovina cyklu jde z 1 zpět do 0 (dokola).
    expect(poseAt(cycle, 0.75).first.dx, closeTo(0.5, 1e-9));
    // Jediný snímek = statická poloha.
    final single = ExercisePoseAnimation(
      topology: forearmTopology,
      frames: [
        [
          const Offset(0.1, 0.2),
          const Offset(0.3, 0.4),
          const Offset(0.5, 0.6),
        ],
      ],
    );
    expect(poseAt(single, 0.42), single.frames.first);
  });

  testWidgets('widget kreslí archetyp (statický i animovaný) a pro kód bez '
      'archetypu nic (EXI-004/009)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ExerciseIllustration(exerciseCode: 'PULL_UP', animate: false),
              ExerciseIllustration(exerciseCode: 'PLANK'),
              ExerciseIllustration(exerciseCode: 'NOT_A_CODE'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.byKey(ExerciseIllustration.illustrationKey('PULL_UP')),
      findsOneWidget,
    );
    expect(
      find.byKey(ExerciseIllustration.illustrationKey('PLANK')),
      findsOneWidget,
    );
    expect(
      find.byKey(ExerciseIllustration.illustrationKey('NOT_A_CODE')),
      findsNothing,
    );
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(2));
    // Animovaná ilustrace s více snímky běží; statická ne.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ExerciseIllustration(exerciseCode: 'PUSH_UP')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.byKey(ExerciseIllustration.illustrationKey('PUSH_UP')),
      findsOneWidget,
    );
    // Změna kódu ve stejném elementu (průvodce přepne krok): nový controller
    // bez chyby tickeru, klíč sleduje kód (regrese z R8 E2E).
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExerciseIllustration(exerciseCode: 'BODYWEIGHT_SQUAT'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(ExerciseIllustration.illustrationKey('BODYWEIGHT_SQUAT')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
