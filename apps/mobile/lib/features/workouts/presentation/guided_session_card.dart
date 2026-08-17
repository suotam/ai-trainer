import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/guided_session_providers.dart';
import '../domain/exercise_catalog.dart';
import '../domain/guided_session.dart';
import '../domain/workout_read_model.dart';
import 'exercise_illustration.dart';
import 'session_time_format.dart';

/// Průvodce aktivní session (C53 §8): aktuální krok s popisem a cue z
/// katalogu C51, sada X/Y, časovač/odpočet fáze, akce podle fáze,
/// předchozí/další/přeskočit, pauza/pokračovat, uplynulý čas a postup.
/// Stav je odvozený ([guidedSessionStateProvider]); karta nedrží doménový
/// stav (GSP-002).
class GuidedSessionCard extends ConsumerWidget {
  const GuidedSessionCard({required this.sessionId, super.key});

  final String sessionId;

  static const Key cardKey = Key('guided_card');
  static const Key stepTitleKey = Key('guided_step_title');
  static const Key phaseTimerKey = Key('guided_phase_timer');
  static const Key primaryActionKey = Key('guided_primary_action');
  static const Key nextKey = Key('guided_next');
  static const Key previousKey = Key('guided_previous');
  static const Key skipKey = Key('guided_skip');
  static const Key pauseKey = Key('guided_pause');
  static const Key elapsedKey = Key('guided_elapsed');
  static const Key progressKey = Key('guided_progress');
  static const Key doneKey = Key('guided_done');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(guidedSessionStateProvider(sessionId));
    final busy = ref.watch(guidedSessionControllerProvider);
    if (state == null || state.steps.isEmpty) {
      return const SizedBox.shrink();
    }
    final controller = ref.read(guidedSessionControllerProvider.notifier);
    final step = state.currentStep!;
    final set = state.currentSet;
    final entry = step.exerciseCode == null
        ? null
        : exerciseCatalogEntry(step.exerciseCode!);
    final title = step.isRest
        ? l10n.guidedRestStep
        : entry == null
        ? step.title
        : l10n.exerciseName(entry.code);
    final instructions = entry == null
        ? step.instructions
        : l10n.exerciseInstructions(entry.code);
    final cue = entry == null ? null : l10n.exerciseCue(entry.code);
    final isDurationSet =
        step.prescriptionType == StepPrescriptionType.duration ||
        (set?.plannedDurationSeconds != null &&
            set?.plannedRepetitions == null);

    return Card(
      key: cardKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Postup + uplynulý čas + pauza.
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.guidedProgress(
                      state.currentStepIndex + 1,
                      state.steps.length,
                      state.completedSets,
                      state.totalSets,
                    ),
                    key: progressKey,
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                Text(
                  formatElapsed(state.elapsedActiveSeconds),
                  key: elapsedKey,
                  style: theme.textTheme.labelLarge,
                ),
                IconButton(
                  key: pauseKey,
                  tooltip: state.isPaused
                      ? l10n.guidedResume
                      : l10n.guidedPause,
                  onPressed: busy
                      ? null
                      : () => state.isPaused
                            ? controller.resume(sessionId)
                            : controller.pause(sessionId),
                  icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
                ),
              ],
            ),
            if (state.isPaused)
              Text(
                l10n.guidedPausedBanner,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            const SizedBox(height: 8),
            Text(step.sectionTitle, style: theme.textTheme.labelSmall),
            Text(title, key: stepTitleKey, style: theme.textTheme.titleLarge),
            // Schematická ilustrace (C54): animace stojí v pauze (EXI-009);
            // bez archetypu nic — text zůstává vždy (EXI-004/006).
            if (step.exerciseCode != null)
              Center(
                child: ExerciseIllustration(
                  exerciseCode: step.exerciseCode!,
                  animate: !state.isPaused,
                  size: 140,
                ),
              ),
            if (entry != null && !entry.bilateral)
              Text(l10n.stepPerSide, style: theme.textTheme.bodySmall),
            if (instructions != null && instructions.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(instructions, style: theme.textTheme.bodyMedium),
              )
            else if (!step.isRest)
              Padding(
                padding: const EdgeInsets.only(top: 4),
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
            if (step.purpose != null && step.purpose!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(step.purpose!, style: theme.textTheme.bodySmall),
              ),
            const SizedBox(height: 12),
            _PhaseArea(
              sessionId: sessionId,
              state: state,
              step: step,
              set: set,
              isDurationSet: isDurationSet,
              busy: busy,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  key: previousKey,
                  onPressed: busy || !state.hasPrevious
                      ? null
                      : () => controller.goToStep(
                          sessionId,
                          state.steps[state.currentStepIndex - 1].stepId,
                        ),
                  icon: const Icon(Icons.chevron_left),
                  label: Text(l10n.guidedPrevious),
                ),
                const Spacer(),
                if (step.isTracked && !step.isCompleted)
                  TextButton(
                    key: skipKey,
                    onPressed: busy
                        ? null
                        : () => controller.skipStep(sessionId, step),
                    child: Text(l10n.guidedSkip),
                  ),
                TextButton.icon(
                  key: nextKey,
                  onPressed: busy || !state.hasNext
                      ? null
                      : () => controller.goToStep(
                          sessionId,
                          state.steps[state.currentStepIndex + 1].stepId,
                        ),
                  icon: const Icon(Icons.chevron_right),
                  label: Text(l10n.guidedNext),
                ),
              ],
            ),
            if (state.isDone)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.guidedAllDone,
                  key: doneKey,
                  style: theme.textTheme.titleSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Fáze: sada (opakování → Hotovo; čas → Start/odpočet → Hotovo), pauza po
/// sadě (odpočet → Další sada), REST krok (Start → odpočet → Další).
class _PhaseArea extends ConsumerWidget {
  const _PhaseArea({
    required this.sessionId,
    required this.state,
    required this.step,
    required this.set,
    required this.isDurationSet,
    required this.busy,
  });

  final String sessionId;
  final GuidedSessionState state;
  final GuidedStep step;
  final GuidedSet? set;
  final bool isDurationSet;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(guidedSessionControllerProvider.notifier);
    final timerStyle = theme.textTheme.displaySmall;

    switch (state.phase) {
      case GuidedPhase.restAfterSet:
        return Column(
          children: [
            Text(l10n.guidedRestAfterSet, style: theme.textTheme.titleSmall),
            Text(
              formatElapsed(state.remainingSeconds),
              key: GuidedSessionCard.phaseTimerKey,
              style: timerStyle,
            ),
            if (state.remainingSeconds == 0)
              Text(l10n.guidedTimerDone, style: theme.textTheme.bodySmall),
            FilledButton(
              key: GuidedSessionCard.primaryActionKey,
              onPressed: busy ? null : () => controller.finishPhase(sessionId),
              child: Text(l10n.guidedNextSet),
            ),
          ],
        );
      case GuidedPhase.restStep:
        return Column(
          children: [
            Text(
              formatElapsed(state.remainingSeconds),
              key: GuidedSessionCard.phaseTimerKey,
              style: timerStyle,
            ),
            if (state.remainingSeconds == 0)
              Text(l10n.guidedTimerDone, style: theme.textTheme.bodySmall),
            FilledButton(
              key: GuidedSessionCard.primaryActionKey,
              onPressed: busy ? null : () => controller.finishPhase(sessionId),
              child: Text(l10n.guidedNext),
            ),
          ],
        );
      case GuidedPhase.setRunning:
        return Column(
          children: [
            Text(
              l10n.guidedSetLabel(
                (state.currentSetIndex ?? 0) + 1,
                step.sets.length,
              ),
              style: theme.textTheme.titleSmall,
            ),
            Text(
              formatElapsed(state.remainingSeconds),
              key: GuidedSessionCard.phaseTimerKey,
              style: timerStyle,
            ),
            if (state.remainingSeconds == 0)
              Text(l10n.guidedTimerDone, style: theme.textTheme.bodySmall),
            FilledButton(
              key: GuidedSessionCard.primaryActionKey,
              onPressed: busy || set == null
                  ? null
                  : () => controller.completeSet(
                      sessionId,
                      step,
                      set!,
                      actualDurationSeconds: _measuredDuration(set!),
                    ),
              child: Text(l10n.guidedDone),
            ),
          ],
        );
      case GuidedPhase.done:
      case GuidedPhase.idle:
        if (step.isRest) {
          return Column(
            children: [
              Text(
                formatElapsed(step.plannedDurationSeconds ?? 0),
                key: GuidedSessionCard.phaseTimerKey,
                style: timerStyle,
              ),
              FilledButton(
                key: GuidedSessionCard.primaryActionKey,
                onPressed: busy
                    ? null
                    : () => controller.startRestStep(sessionId, step),
                child: Text(l10n.guidedStartRest),
              ),
            ],
          );
        }
        if (set == null) {
          // Krok bez otevřené sady (hotový/přeskočený/bez sad).
          return Text(
            step.isSkipped
                ? l10n.guidedStepSkipped
                : step.isCompleted
                ? l10n.guidedStepCompleted
                : l10n.guidedNoSets,
            style: theme.textTheme.bodyMedium,
          );
        }
        final planned = isDurationSet
            ? formatElapsed(set!.plannedDurationSeconds ?? 0)
            : [
                if (set!.plannedRepetitions != null)
                  l10n.workoutSetPlanReps(set!.plannedRepetitions!),
                if (set!.plannedWeightKg != null)
                  l10n.workoutSetPlanWeight('${set!.plannedWeightKg}'),
              ].join(' · ');
        return Column(
          children: [
            Text(
              l10n.guidedSetLabel(
                (state.currentSetIndex ?? 0) + 1,
                step.sets.length,
              ),
              style: theme.textTheme.titleSmall,
            ),
            Text(
              planned,
              key: GuidedSessionCard.phaseTimerKey,
              style: timerStyle,
            ),
            if ((set!.restAfterSeconds ?? 0) > 0)
              Text(
                l10n.workoutSetPlanRest(set!.restAfterSeconds!),
                style: theme.textTheme.bodySmall,
              ),
            FilledButton(
              key: GuidedSessionCard.primaryActionKey,
              onPressed: busy
                  ? null
                  : isDurationSet
                  ? () => controller.startSet(sessionId, step, set!)
                  : () => controller.completeSet(sessionId, step, set!),
              child: Text(
                isDurationSet ? l10n.guidedStartSet : l10n.guidedDone,
              ),
            ),
          ],
        );
    }
  }

  /// Skutečná doba DURATION sady = min(plán, měřený čas) (GSP-010).
  int? _measuredDuration(GuidedSet set) {
    final planned = set.plannedDurationSeconds;
    if (planned == null) {
      return null;
    }
    final measured = planned - state.remainingSeconds;
    return measured < 0 ? 0 : (measured > planned ? planned : measured);
  }
}
