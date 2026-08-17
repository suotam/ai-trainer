import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/session_providers.dart';
import '../application/session_tracker_providers.dart';
import '../application/workout_completion_providers.dart';
import '../application/workout_detail_providers.dart';
import '../domain/session_tracker.dart';
import '../domain/workout_session.dart';
import 'feedback_confirm_dialog.dart';
import 'guided_session_card.dart';
import 'session_time_format.dart';
import 'session_tracker_view.dart';

/// Minimální read-only obrazovka aktivní session (R1-03).
///
/// Zobrazuje název workoutu, že session je aktivní, bezpečný start
/// timestamp a plánovaný snapshot v read-only podobě. Neumožňuje zápis
/// výkonu, dokončení ani zrušení (pozdější slices). Neplatné/neexistující
/// session ID končí bezpečným not-found stavem.
class ActiveSessionScreen extends ConsumerWidget {
  const ActiveSessionScreen({required this.sessionId, super.key});

  final String sessionId;

  static const Key screenKey = Key('active_session_screen');
  static const Key loadingKey = Key('active_session_loading');
  static const Key contentKey = Key('active_session_content');
  static const Key notFoundKey = Key('active_session_not_found');
  static const Key errorKey = Key('active_session_error');
  static const Key activeLabelKey = Key('active_session_active_label');
  static const Key completeButtonKey = Key('active_session_complete');
  static const Key completingKey = Key('active_session_completing');
  static const Key completeErrorKey = Key('active_session_complete_error');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionByIdProvider(sessionId));

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.activeSessionScreenTitle)),
      body: session.when(
        loading: () => Center(
          child: Column(
            key: loadingKey,
            mainAxisSize: MainAxisSize.min,
            children: const [CircularProgressIndicator()],
          ),
        ),
        error: (_, _) =>
            _Message(message: l10n.activeSessionError, stateKey: errorKey),
        data: (snapshot) => snapshot == null
            ? _Message(
                message: l10n.activeSessionNotFound,
                stateKey: notFoundKey,
              )
            : _ActiveSessionContent(session: snapshot),
      ),
    );
  }
}

class _ActiveSessionContent extends ConsumerWidget {
  const _ActiveSessionContent({required this.session});

  final WorkoutSessionSnapshot session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final detail = ref.watch(workoutDetailProvider(session.workoutInstanceId));

    final title = detail.maybeWhen(
      data: (workout) => workout?.title,
      orElse: () => null,
    );

    return ListView(
      key: ActiveSessionScreen.contentKey,
      padding: const EdgeInsets.all(16),
      children: [
        if (title != null) Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.activeSessionLabel,
          key: ActiveSessionScreen.activeLabelKey,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(l10n.activeSessionStartedAt(formatStartedAt(session.startedAt))),
        const SizedBox(height: 16),
        // Průvodce (R8-03, C53 §8): krok za krokem s časovači — primární
        // část; plochý zápis výkonů zůstává pod ním.
        GuidedSessionCard(sessionId: session.id),
        const SizedBox(height: 16),
        Text(l10n.trackerListTitle, style: theme.textTheme.titleMedium),
        // Tracker výkonu (R1-04) — plánované vs. skutečné hodnoty, zápis.
        SessionTrackerView(sessionId: session.id),
        const SizedBox(height: 24),
        // Dokončení workoutu (R1-06).
        _CompleteWorkoutSection(sessionId: session.id),
      ],
    );
  }
}

/// Dokončení aktivní session (R1-06): potvrzovací dialog, ochrana proti
/// dvojitému tapu, navigace do historie po úspěchu a bezpečný error stav.
class _CompleteWorkoutSection extends ConsumerWidget {
  const _CompleteWorkoutSection({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final completion = ref.watch(workoutCompletionControllerProvider);
    final isCompleting = completion is CompletionInProgress;

    // Po úspěšném dokončení odejdi z active trackeru do historie.
    ref.listen<WorkoutCompletionState>(workoutCompletionControllerProvider, (
      previous,
      next,
    ) {
      if (next is CompletionDone) {
        ref.read(workoutCompletionControllerProvider.notifier).reset();
        context.go(AppRoutes.historyPath);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          key: ActiveSessionScreen.completeButtonKey,
          onPressed: isCompleting ? null : () => _onComplete(context, ref),
          child: isCompleting
              ? Text(
                  l10n.completeWorkoutCompleting,
                  key: ActiveSessionScreen.completingKey,
                )
              : Text(l10n.completeWorkoutButton),
        ),
        if (completion is CompletionError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.completeWorkoutError,
              key: ActiveSessionScreen.completeErrorKey,
            ),
          ),
      ],
    );
  }

  Future<void> _onComplete(BuildContext context, WidgetRef ref) async {
    final tracker = ref.read(sessionTrackerProvider(sessionId)).value;
    final counts = _setCounts(tracker);

    // Bezpečný potvrzovací dialog s volitelným feedbackem (R1-07). Dialog
    // sám data nemění; při zrušení vrací null a nic se nezapíše.
    final feedback = await FeedbackConfirmDialog.show(
      context,
      completedSets: counts.completed,
      totalSets: counts.total,
    );
    if (feedback == null) {
      return;
    }
    // Zápis až po potvrzení; prázdný feedback se přeskočí (neukládá se).
    await ref
        .read(workoutCompletionControllerProvider.notifier)
        .complete(sessionId, feedback: feedback.hasContent ? feedback : null);
  }

  static ({int completed, int total}) _setCounts(SessionTracker? tracker) {
    var completed = 0;
    var total = 0;
    for (final exercise in tracker?.exercises ?? const <TrackerExercise>[]) {
      for (final set in exercise.sets) {
        total += 1;
        if (set.isCompleted) {
          completed += 1;
        }
      }
    }
    return (completed: completed, total: total);
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message, required this.stateKey});

  final String message;
  final Key stateKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        key: stateKey,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
