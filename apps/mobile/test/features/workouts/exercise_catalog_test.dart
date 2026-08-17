import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/availability/domain/availability_profile.dart';
import 'package:ai_trainer_mobile/features/workouts/data/workout_row_mappers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/exercise_catalog.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_read_model.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// R8-01 testy katalogu cviků (C51 §10): stabilní unikátní kódy, úplnost
/// cs+en textů (EXC-007), vybavení jen známé kódy C19+rozšíření (EXC-013),
/// deprecated mimo nový výběr (EXC-002), mapper odmítá neznámý kód
/// (EXC-011) a historické řádky bez kódu jsou vlastní cviky (EXC-009).
void main() {
  test('katalog má 112 unikátních kódů ve formátu UPPER_SNAKE (C51 §5)', () {
    expect(exerciseCatalog, hasLength(112));
    final codes = exerciseCatalog.map((e) => e.code).toList();
    expect(codes.toSet(), hasLength(codes.length));
    for (final code in codes) {
      expect(code, matches(RegExp(r'^[A-Z][A-Z0-9_]{2,39}$')), reason: code);
      expect(isKnownExerciseCode(code), isTrue);
      expect(exerciseCatalogEntry(code)!.code, code);
    }
    expect(isKnownExerciseCode('SOCCER_DRILL'), isFalse);
    expect(exerciseCatalogEntry('SOCCER_DRILL'), isNull);
  });

  test(
    'každý kód má název, popis provedení i cue v cs a en (EXC-007)',
    () async {
      for (final locale in const [Locale('cs'), Locale('en')]) {
        final l10n = await AppLocalizations.delegate.load(locale);
        for (final entry in exerciseCatalog) {
          final name = l10n.exerciseName(entry.code);
          final instructions = l10n.exerciseInstructions(entry.code);
          final cue = l10n.exerciseCue(entry.code);
          expect(
            name,
            isNot(entry.code),
            reason: '${locale.languageCode} name ${entry.code}',
          );
          expect(name.trim(), isNotEmpty);
          expect(
            instructions,
            isNot(entry.code),
            reason: '${locale.languageCode} instructions ${entry.code}',
          );
          expect(
            instructions.length,
            greaterThan(20),
            reason: '${locale.languageCode} instructions ${entry.code}',
          );
          expect(
            cue.trim(),
            isNotEmpty,
            reason: '${locale.languageCode} cue ${entry.code}',
          );
        }
      }
    },
  );

  test('vybavení cviků jsou jen kódy katalogu C19 vč. aditivního rozšíření '
      '(EXC-013) a rozšíření má překlady', () async {
    for (final entry in exerciseCatalog) {
      for (final equipment in entry.equipment) {
        expect(equipmentCatalog, contains(equipment), reason: entry.code);
      }
      expect(
        entry.primaryMuscles.toSet(),
        hasLength(entry.primaryMuscles.length),
      );
    }
    for (final locale in const [Locale('cs'), Locale('en')]) {
      final l10n = await AppLocalizations.delegate.load(locale);
      for (final code in const [
        'GYMNASTIC_RINGS',
        'SUSPENSION_TRAINER',
        'HANGBOARD',
        'JUMP_ROPE',
        'FOAM_ROLLER',
        'STEP_BOX',
        'ROWING_MACHINE',
      ]) {
        expect(l10n.equipmentName(code), isNot(code));
      }
    }
  });

  test(
    'aktivní katalog vynechává deprecated položky; dnes žádná (EXC-002)',
    () {
      expect(activeExerciseCatalog(), hasLength(exerciseCatalog.length));
      expect(activeExerciseCodes().first, 'JUMPING_JACKS');
      expect(exerciseCatalog.where((e) => e.deprecated), isEmpty);
      // Kategorie a výchozí předpis: DURATION cviky mají smysl na čas.
      expect(
        exerciseCatalogEntry('PLANK')!.defaultPrescription,
        ExercisePrescription.duration,
      );
      expect(
        exerciseCatalogEntry('PUSH_UP')!.defaultPrescription,
        ExercisePrescription.setRep,
      );
      expect(exerciseCatalogEntry('SIDE_PLANK')!.bilateral, isFalse);
      expect(
        exerciseCatalogEntry('HANGBOARD_MAX_HANG')!.category,
        ExerciseCategory.climbing,
      );
    },
  );

  test('mapper: neznámý persistovaný kód je typovaná chyba, deprecated se čte, '
      'řádek bez kódu je vlastní cvik (EXC-009/011)', () {
    LocalWorkoutStepRow row(String? code) => LocalWorkoutStepRow(
      id: 's1',
      sectionId: 'sec',
      position: 0,
      stepType: 'EXERCISE',
      title: 'x',
      priority: 'REQUIRED',
      isSkippable: false,
      prescriptionType: 'SET_REP',
      exerciseCode: code,
      createdAt: 0,
      updatedAt: 0,
    );
    final custom = mapStep(row(null), setPlans: const [], childSteps: const []);
    expect(custom.exerciseCode, isNull);
    final catalog = mapStep(
      row('PULL_UP'),
      setPlans: const [],
      childSteps: const [],
    );
    expect(catalog.exerciseCode, 'PULL_UP');
    expect(
      () =>
          mapStep(row('NOT_A_CODE'), setPlans: const [], childSteps: const []),
      throwsA(isA<UnsupportedPersistedValue>()),
    );
  });
}
