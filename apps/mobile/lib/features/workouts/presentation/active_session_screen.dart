import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/session_providers.dart';
import '../application/workout_detail_providers.dart';
import '../domain/workout_session.dart';
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
        // Tracker výkonu (R1-04) — plánované vs. skutečné hodnoty, zápis.
        SessionTrackerView(sessionId: session.id),
      ],
    );
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
