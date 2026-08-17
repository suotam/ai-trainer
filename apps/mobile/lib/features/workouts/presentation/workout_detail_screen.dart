import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/session_providers.dart';
import '../application/workout_detail_providers.dart';
import '../domain/exercise_catalog.dart';
import '../domain/start_session_result.dart';
import '../domain/workout_read_model.dart';
import 'exercise_illustration.dart';
import 'workout_duration_format.dart';

/// Detail workoutu (VSP §13/§14, screen-spec §34).
///
/// Zobrazuje stabilní snapshot: sekce, kroky a plánované série v pořadí.
/// Od R1-03 umožňuje pouze **start** session (žádná editace, zápis výkonu
/// ani dokončení). Neplatné/neexistující ID končí bezpečným not-found stavem.
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({required this.workoutId, super.key});

  final String workoutId;

  static const Key screenKey = Key('workout_detail_screen');
  static const Key loadingKey = Key('workout_detail_loading');
  static const Key contentKey = Key('workout_detail_content');
  static const Key notFoundKey = Key('workout_detail_not_found');
  static const Key errorKey = Key('workout_detail_error');
  static const Key retryKey = Key('workout_detail_retry');
  static const Key startButtonKey = Key('workout_detail_start');
  static const Key startProgressKey = Key('workout_detail_start_progress');
  static const Key startErrorKey = Key('workout_detail_start_error');
  static const Key startNotFoundKey = Key('workout_detail_start_not_found');
  static const Key conflictKey = Key('workout_detail_conflict');
  static const Key conflictOpenKey = Key('workout_detail_conflict_open');
  static const Key finishedKey = Key('workout_detail_finished');

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
      bottomNavigationBar: detail.maybeWhen(
        data: (workout) => workout == null
            ? null
            : _StartActionBar(workoutId: workoutId, status: workout.status),
        orElse: () => null,
      ),
    );
  }
}

/// Spodní akční lišta se startem session (R1-03).
class _StartActionBar extends ConsumerWidget {
  const _StartActionBar({required this.workoutId, required this.status});

  final String workoutId;
  final WorkoutInstanceStatus status;

  /// Uzavřené workouty (nález 9) nemají start — místo tlačítka poctivý stav.
  bool get _isFinished => switch (status) {
    WorkoutInstanceStatus.completed ||
    WorkoutInstanceStatus.partiallyCompleted ||
    WorkoutInstanceStatus.skipped ||
    WorkoutInstanceStatus.cancelled => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final startState = ref.watch(startSessionControllerProvider);

    // Navigace po úspěšném created/resumed jako side effect (ne v build).
    ref.listen<StartSessionUiState>(startSessionControllerProvider, (
      previous,
      next,
    ) {
      if (next is StartSessionSuccess) {
        final result = next.result;
        final String? sessionId = switch (result) {
          SessionCreated(:final sessionId) => sessionId,
          SessionResumedExisting(:final sessionId) => sessionId,
          _ => null,
        };
        if (sessionId != null) {
          ref.read(startSessionControllerProvider.notifier).reset();
          context.push(AppRoutes.activeSessionLocation(sessionId));
        }
      }
    });

    final isStarting = startState is StartSessionInProgress;
    if (_isFinished ||
        (startState is StartSessionSuccess &&
            startState.result is WorkoutAlreadyFinished)) {
      return SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Text(
          l10n.startWorkoutFinished,
          key: WorkoutDetailScreen.finishedKey,
          textAlign: TextAlign.center,
        ),
      );
    }

    final children = <Widget>[
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          key: WorkoutDetailScreen.startButtonKey,
          onPressed: isStarting
              ? null
              : () => ref
                    .read(startSessionControllerProvider.notifier)
                    .start(workoutId),
          child: isStarting
              ? Row(
                  key: WorkoutDetailScreen.startProgressKey,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.startWorkoutStarting),
                  ],
                )
              : Text(l10n.startWorkoutButton),
        ),
      ),
    ];

    if (startState is StartSessionSuccess) {
      final result = startState.result;
      if (result is ConflictWithAnotherSession) {
        children.addAll([
          const SizedBox(height: 8),
          Text(
            l10n.startWorkoutConflict,
            key: WorkoutDetailScreen.conflictKey,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          OutlinedButton(
            key: WorkoutDetailScreen.conflictOpenKey,
            onPressed: () {
              ref.read(startSessionControllerProvider.notifier).reset();
              context.push(
                AppRoutes.activeSessionLocation(result.activeSessionId),
              );
            },
            child: Text(l10n.startWorkoutConflictOpen),
          ),
        ]);
      } else if (result is WorkoutNotFound) {
        children.addAll([
          const SizedBox(height: 8),
          Text(
            l10n.startWorkoutNotFound,
            key: WorkoutDetailScreen.startNotFoundKey,
            textAlign: TextAlign.center,
          ),
        ]);
      }
    } else if (startState is StartSessionFailure) {
      children.addAll([
        const SizedBox(height: 8),
        Text(
          l10n.startWorkoutError,
          key: WorkoutDetailScreen.startErrorKey,
          textAlign: TextAlign.center,
        ),
      ]);
    }

    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
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

    // Katalogový cvik (C51): název, popis provedení a cue z katalogu;
    // vlastní cvik: title + instructions (nebo poctivě „bez popisu").
    final entry = step.exerciseCode == null
        ? null
        : exerciseCatalogEntry(step.exerciseCode!);
    final title = entry == null ? step.title : l10n.exerciseName(entry.code);
    final instructions = entry == null
        ? step.instructions
        : l10n.exerciseInstructions(entry.code);
    final cue = entry == null ? null : l10n.exerciseCue(entry.code);
    final isExercise =
        step.stepType == WorkoutStepType.exercise ||
        step.stepType == WorkoutStepType.mobilityPosition;

    final subtitleParts = <String>[
      if (step.setPlans.isNotEmpty) l10n.workoutStepSets(step.setPlans.length),
      ?duration,
      if (entry != null && !entry.bilateral) l10n.stepPerSide,
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
              // Statický náhled první polohy (C54 §3).
              if (entry != null)
                ExerciseIllustration(
                  exerciseCode: entry.code,
                  animate: false,
                  size: 44,
                ),
            ],
          ),
          if (subtitleParts.isNotEmpty)
            Text(subtitleParts.join(' · '), style: theme.textTheme.bodySmall),
          if (instructions != null && instructions.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(instructions, style: theme.textTheme.bodySmall),
            )
          else if (isExercise)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l10n.stepNoInstructions,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (cue != null && cue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                cue,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
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
      if (setPlan.plannedDurationSeconds != null)
        l10n.workoutSetPlanSeconds(setPlan.plannedDurationSeconds!),
      if (setPlan.plannedWeightKg != null)
        l10n.workoutSetPlanWeight(_formatWeight(setPlan.plannedWeightKg!)),
      if (setPlan.restAfterSeconds != null)
        l10n.workoutSetPlanRest(setPlan.restAfterSeconds!),
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
