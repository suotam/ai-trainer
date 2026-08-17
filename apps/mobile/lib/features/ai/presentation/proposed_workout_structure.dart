import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../workouts/domain/exercise_catalog.dart';

/// Čitelná struktura navrženého workoutu (C52 §6, CHP-001): v2 = sekce →
/// kroky (název z katalogu C51 nebo vlastní, předpis, sady, čas, pauzy);
/// v1 = počet cviků. Čte kanonický payload C29 — chat ani AI obrazovka
/// nedrží kopii obsahu.
class ProposedWorkoutStructure extends StatelessWidget {
  const ProposedWorkoutStructure({required this.workout, super.key});

  final Map workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodySmall;
    final sections = workout['sections'];
    if (sections is! List) {
      final exercises = workout['exercises'];
      return exercises is List && exercises.isNotEmpty
          ? Text(l10n.aiExerciseCount(exercises.length), style: style)
          : const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections.cast<Map>()) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (section['title'] as String?) ??
                  l10n.aiSectionLabel('${section['sectionType']}'),
              style: style?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          for (final step
              in ((section['steps'] as List?) ?? const []).cast<Map>())
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(_stepLine(l10n, step), style: style),
            ),
        ],
      ],
    );
  }

  String _stepLine(AppLocalizations l10n, Map step) {
    if (step['stepType'] == 'REST') {
      return '· ${l10n.aiRestStep(step['durationSeconds'] as int? ?? 0)}';
    }
    final code = step['exerciseCode'] as String?;
    final name = code != null && isKnownExerciseCode(code)
        ? l10n.exerciseName(code)
        : '${step['customTitle'] ?? code ?? ''}';
    final sets = (step['sets'] as List?)?.cast<Map>() ?? const [];
    final isDuration = step['prescription'] == 'DURATION';
    final first = sets.isEmpty ? null : sets.first;
    final rest = first?['restAfterSeconds'] as int?;
    final parts = <String>[
      name,
      if (sets.isNotEmpty)
        isDuration
            ? l10n.aiSetsDuration(
                sets.length,
                first?['durationSeconds'] as int? ?? 0,
              )
            : l10n.aiSetsReps(sets.length, first?['repetitions'] as int? ?? 0),
      if (first?['weightKg'] != null)
        l10n.workoutSetPlanWeight('${first!['weightKg']}'),
      if (rest != null && rest > 0) l10n.workoutSetPlanRest(rest),
    ];
    return '· ${parts.join(' · ')}';
  }
}
