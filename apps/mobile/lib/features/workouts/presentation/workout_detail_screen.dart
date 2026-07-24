import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/workout_detail_providers.dart';
import '../domain/workout_read_model.dart';
import 'workout_duration_format.dart';

/// Detail workoutu (read-only, VSP §13, screen-spec §34).
///
/// Zobrazuje stabilní snapshot: sekce, kroky a plánované série v pořadí.
/// Neumožňuje editaci ani start session. Neplatné/neexistující ID končí
/// bezpečným not-found stavem.
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({required this.workoutId, super.key});

  final String workoutId;

  static const Key screenKey = Key('workout_detail_screen');
  static const Key loadingKey = Key('workout_detail_loading');
  static const Key contentKey = Key('workout_detail_content');
  static const Key notFoundKey = Key('workout_detail_not_found');
  static const Key errorKey = Key('workout_detail_error');
  static const Key retryKey = Key('workout_detail_retry');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(workoutDetailProvider(workoutId));

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.workoutDetailScreenTitle)),
      body: detail.when(
        loading: () => Center(
          child: Column(
            key: loadingKey,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.workoutDetailLoading),
            ],
          ),
        ),
        error: (_, _) => _Message(
          message: l10n.workoutDetailError,
          stateKey: errorKey,
          onRetry: () => refreshWorkoutDetail(ref, workoutId),
          retryLabel: l10n.commonRetry,
        ),
        data: (workout) => workout == null
            ? _Message(
                message: l10n.workoutDetailNotFound,
                stateKey: notFoundKey,
              )
            : _DetailContent(workout: workout),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.workout});

  final WorkoutInstanceDetail workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final duration = formatDurationLabel(l10n, workout.plannedDurationSeconds);

    return ListView(
      key: WorkoutDetailScreen.contentKey,
      padding: const EdgeInsets.all(16),
      children: [
        Text(workout.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          [workout.workoutType, ?duration].join(' · '),
          style: theme.textTheme.bodyMedium,
        ),
        if (workout.description != null) ...[
          const SizedBox(height: 8),
          Text(workout.description!),
        ],
        const SizedBox(height: 16),
        for (final section in workout.sections) _SectionView(section: section),
      ],
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section});

  final WorkoutSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(section.title, style: theme.textTheme.titleMedium),
              ),
              if (section.isOptional)
                Chip(label: Text(l10n.workoutSectionOptional)),
            ],
          ),
          const SizedBox(height: 8),
          for (final step in section.steps) _StepView(step: step),
        ],
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({required this.step});

  final WorkoutStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final duration = formatDurationLabel(l10n, step.plannedDurationSeconds);

    final subtitleParts = <String>[
      if (step.setPlans.isNotEmpty) l10n.workoutStepSets(step.setPlans.length),
      ?duration,
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.title, style: theme.textTheme.bodyLarge),
          if (subtitleParts.isNotEmpty)
            Text(subtitleParts.join(' · '), style: theme.textTheme.bodySmall),
          for (final setPlan in step.setPlans)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                _formatSetPlan(l10n, setPlan),
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  String _formatSetPlan(AppLocalizations l10n, WorkoutSetPlan setPlan) {
    final parts = <String>[
      '${setPlan.position + 1}.',
      if (setPlan.plannedRepetitions != null)
        l10n.workoutSetPlanReps(setPlan.plannedRepetitions!),
      if (setPlan.plannedWeightKg != null)
        l10n.workoutSetPlanWeight(_formatWeight(setPlan.plannedWeightKg!)),
    ];
    return parts.join('  ');
  }

  String _formatWeight(double weightKg) {
    return weightKg == weightKg.roundToDouble()
        ? weightKg.toStringAsFixed(0)
        : weightKg.toStringAsFixed(1);
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.message,
    required this.stateKey,
    this.onRetry,
    this.retryLabel,
  });

  final String message;
  final Key stateKey;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        key: stateKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message, textAlign: TextAlign.center),
          ),
          if (onRetry != null && retryLabel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              key: WorkoutDetailScreen.retryKey,
              onPressed: onRetry,
              child: Text(retryLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
