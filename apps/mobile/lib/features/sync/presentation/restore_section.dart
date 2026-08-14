import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity/application/activity_providers.dart';
import '../../checkin/application/checkin_providers.dart';
import '../../plan/application/plan_providers.dart';
import '../../summary/application/summary_providers.dart';
import '../../workouts/application/today_providers.dart';
import '../application/local_sync_providers.dart';
import '../application/pull_engine.dart';

/// Obnova dat ze serveru (R6-05, C45): explicitní akce přihlášeného
/// uživatele (DRS-002) — restore = plný pull existujícím mechanismem
/// (DRS-001), přerušitelný a idempotentní (DRS-003). Poctivé hranice
/// obnovy přiznává text (DRS-007); typované stavy (DRS-009).
class RestoreSection extends ConsumerWidget {
  const RestoreSection({super.key});

  static const Key restoreButtonKey = Key('restore_button');
  static const Key resultKey = Key('restore_result');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(restoreControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.restoreHeader, style: Theme.of(context).textTheme.titleSmall),
        Text(l10n.restoreNote, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: restoreButtonKey,
          icon: state is RestoreRunning
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_download_outlined),
          label: Text(l10n.restoreAction),
          onPressed: state is RestoreRunning
              ? null
              : () => ref.read(restoreControllerProvider.notifier).restore(),
        ),
        if (_resultText(l10n, state) != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_resultText(l10n, state)!, key: resultKey),
          ),
      ],
    );
  }

  String? _resultText(AppLocalizations l10n, RestoreState state) =>
      switch (state) {
        RestoreCompleted(:final result) => l10n.restoreCompleted(
          result.applied,
          result.conflictSkipped + result.skippedDependency,
        ),
        RestoreFailedAnonymous() => l10n.restoreSignInRequired,
        RestoreFailedUnavailable() => l10n.restoreUnavailable,
        _ => null,
      };
}

/// Typované stavy restore flow (DRS-009).
sealed class RestoreState {
  const RestoreState();
}

class RestoreIdle extends RestoreState {
  const RestoreIdle();
}

class RestoreRunning extends RestoreState {
  const RestoreRunning();
}

class RestoreCompleted extends RestoreState {
  const RestoreCompleted(this.result);
  final PullRunCompleted result;
}

class RestoreFailedAnonymous extends RestoreState {
  const RestoreFailedAnonymous();
}

class RestoreFailedUnavailable extends RestoreState {
  const RestoreFailedUnavailable();
}

/// Controller restore: double-run guard, typované stavy, po dokončení
/// invalidace read modelů (DRS-012). Žádný auto-retry.
class RestoreController extends Notifier<RestoreState> {
  bool _inFlight = false;

  @override
  RestoreState build() => const RestoreIdle();

  Future<void> restore() async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const RestoreRunning();
    try {
      final result = await ref
          .read(pullEngineProvider)
          .pullChanges(now: ref.read(clockProvider)());
      state = switch (result) {
        PullRunCompleted() => RestoreCompleted(result),
        PullSkippedAnonymous() => const RestoreFailedAnonymous(),
        PullUnavailable() => const RestoreFailedUnavailable(),
      };
      if (result is PullRunCompleted) {
        ref
          ..invalidate(todayWorkoutsProvider)
          ..invalidate(trainingPlansProvider)
          ..invalidate(planWorkoutsProvider)
          ..invalidate(todayCheckInProvider)
          ..invalidate(checkInHistoryProvider)
          ..invalidate(weeklySummaryProvider)
          ..invalidate(manualActivitiesProvider);
      }
    } catch (_) {
      state = const RestoreFailedUnavailable();
    } finally {
      _inFlight = false;
    }
  }
}

final restoreControllerProvider =
    NotifierProvider<RestoreController, RestoreState>(RestoreController.new);
