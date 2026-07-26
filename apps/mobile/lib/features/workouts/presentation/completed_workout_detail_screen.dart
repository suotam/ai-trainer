import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/workout_completion_providers.dart';
import '../domain/session_tracker.dart';
import '../domain/workout_feedback.dart';
import '../domain/workout_history.dart';
import 'session_time_format.dart';

/// Read-only detail dokončeného workoutu (R1-06). Reusuje tracker read model
/// v čistě read-only režimu — žádné inputy, žádné Save/Done/Complete, žádná
/// reaktivace session. Jasně odlišuje dokončený stav od aktivního trackeru.
class CompletedWorkoutDetailScreen extends ConsumerWidget {
  const CompletedWorkoutDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  static const Key screenKey = Key('completed_workout_screen');
  static const Key loadingKey = Key('completed_workout_loading');
  static const Key notFoundKey = Key('completed_workout_not_found');
  static const Key errorKey = Key('completed_workout_error');
  static const Key contentKey = Key('completed_workout_content');
  static const Key completedLabelKey = Key('completed_workout_label');
  static const Key feedbackSectionKey = Key('completed_workout_feedback');
  static const Key feedbackNoneKey = Key('completed_workout_feedback_none');

  static Key setRowKey(String id) => Key('completed_set_$id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(completedWorkoutDetailProvider(sessionId));

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.completedWorkoutTitle)),
      body: detail.when(
        loading: () => const Center(
          child: Padding(
            key: loadingKey,
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, _) => Center(
          child: Padding(
            key: errorKey,
            padding: const EdgeInsets.all(24),
            child: Text(l10n.historyError, textAlign: TextAlign.center),
          ),
        ),
        data: (data) => data == null
            ? Center(
                child: Padding(
                  key: notFoundKey,
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.completedWorkoutNotFound,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _CompletedContent(detail: data),
      ),
    );
  }
}

class _CompletedContent extends StatelessWidget {
  const _CompletedContent({required this.detail});

  final CompletedWorkoutDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final entry = detail.entry;

    return ListView(
      key: CompletedWorkoutDetailScreen.contentKey,
      padding: const EdgeInsets.all(16),
      children: [
        Text(entry.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.completedWorkoutTitle,
          key: CompletedWorkoutDetailScreen.completedLabelKey,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(l10n.completedWorkoutStartedAt(formatStartedAt(entry.startedAt))),
        Text(l10n.historyCompletedAt(formatStartedAt(entry.completedAt))),
        const SizedBox(height: 16),
        _FeedbackSection(feedback: detail.feedback),
        const SizedBox(height: 16),
        for (final exercise in detail.tracker.exercises)
          _ExerciseBlock(exercise: exercise),
      ],
    );
  }
}

/// Read-only zobrazení uloženého feedbacku (reload). Když uživatel feedback
/// přeskočil, zobrazí bezpečnou informaci místo prázdna.
class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({required this.feedback});

  final WorkoutFeedbackSnapshot? feedback;

  String _feelingLabel(AppLocalizations l10n, WorkoutFeeling feeling) =>
      switch (feeling) {
        WorkoutFeeling.great => l10n.feelingGreat,
        WorkoutFeeling.good => l10n.feelingGood,
        WorkoutFeeling.okay => l10n.feelingOkay,
        WorkoutFeeling.tired => l10n.feelingTired,
        WorkoutFeeling.rough => l10n.feelingRough,
      };

  static String _effort(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final data = feedback;

    if (data == null || !_hasContent(data)) {
      return Text(
        l10n.completedFeedbackNone,
        key: CompletedWorkoutDetailScreen.feedbackNoneKey,
        style: theme.textTheme.bodyMedium,
      );
    }

    return Column(
      key: CompletedWorkoutDetailScreen.feedbackSectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.completedFeedbackTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        if (data.overallEffort != null)
          Text(l10n.completedFeedbackEffort(_effort(data.overallEffort!))),
        if (data.feeling != null)
          Text(
            l10n.completedFeedbackFeeling(_feelingLabel(l10n, data.feeling!)),
          ),
        if (data.painReported) Text(l10n.completedFeedbackPain),
        if (data.notes != null && data.notes!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(data.notes!),
          ),
      ],
    );
  }

  static bool _hasContent(WorkoutFeedbackSnapshot f) =>
      f.overallEffort != null ||
      f.feeling != null ||
      f.painReported ||
      (f.notes != null && f.notes!.trim().isNotEmpty);
}

class _ExerciseBlock extends StatelessWidget {
  const _ExerciseBlock({required this.exercise});

  final TrackerExercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final set in exercise.sets) _SetRow(set: set),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.set});

  final TrackerSet set;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      key: CompletedWorkoutDetailScreen.setRowKey(set.setPerformanceId),
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.trackerSetLabel(set.position + 1)} · '
                  '${l10n.trackerPlannedSet(_text(set.plannedRepetitions), _text(set.plannedWeightKg))}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (set.isCompleted)
                Icon(
                  Icons.check_circle,
                  semanticLabel: l10n.trackerCompleted,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.completedActualValue(
              _text(set.actualRepetitions),
              _text(set.actualWeightKg),
            ),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  static String _text(Object? value) => value?.toString() ?? '–';
}
