import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/today_providers.dart';
import '../domain/workout_read_model.dart';
import 'workout_duration_format.dart';

/// Today obrazovka (read-only, VSP §13, screen-spec §21).
///
/// Zobrazuje dnešní naplánované workouty z lokálního snapshotu bez sítě.
/// Neimplementuje start workoutu ani akce pozdějších slices — pouze
/// otevření detailu.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  static const Key screenKey = Key('today_screen');
  static const Key loadingKey = Key('today_loading');
  static const Key emptyKey = Key('today_empty');
  static const Key errorKey = Key('today_error');
  static const Key retryKey = Key('today_retry');
  static const Key listKey = Key('today_workout_list');
  static const Key historyActionKey = Key('today_history_action');
  static const Key accountActionKey = Key('today_account_action');
  static const Key sportsActionKey = Key('today_sports_action');
  static const Key goalsActionKey = Key('today_goals_action');
  static const Key availabilityActionKey = Key('today_availability_action');
  static const Key planActionKey = Key('today_plan_action');
  static const Key activityActionKey = Key('today_activity_action');

  static Key cardKey(String workoutId) => Key('today_workout_card_$workoutId');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayWorkoutsProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(
        title: Text(l10n.todayScreenTitle),
        actions: [
          IconButton(
            key: planActionKey,
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: l10n.planOpenTooltip,
            onPressed: () => context.push(AppRoutes.planPath),
          ),
          IconButton(
            key: sportsActionKey,
            icon: const Icon(Icons.sports_gymnastics),
            tooltip: l10n.sportsOpenTooltip,
            onPressed: () => context.push(AppRoutes.sportsProfilePath),
          ),
          IconButton(
            key: goalsActionKey,
            icon: const Icon(Icons.flag_outlined),
            tooltip: l10n.goalsOpenTooltip,
            onPressed: () => context.push(AppRoutes.goalsPath),
          ),
          IconButton(
            key: availabilityActionKey,
            icon: const Icon(Icons.event_available_outlined),
            tooltip: l10n.availabilityOpenTooltip,
            onPressed: () => context.push(AppRoutes.availabilityPath),
          ),
          IconButton(
            key: activityActionKey,
            icon: const Icon(Icons.insights_outlined),
            tooltip: l10n.activityOpenTooltip,
            onPressed: () => context.push(AppRoutes.activityPath),
          ),
          IconButton(
            key: historyActionKey,
            icon: const Icon(Icons.history),
            tooltip: l10n.historyOpenTooltip,
            onPressed: () => context.push(AppRoutes.historyPath),
          ),
          IconButton(
            key: accountActionKey,
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: l10n.accountOpenTooltip,
            onPressed: () => context.push(AppRoutes.accountPath),
          ),
        ],
      ),
      body: today.when(
        loading: () =>
            _Loading(message: l10n.todayLoading, keyValue: loadingKey),
        error: (_, _) => _ErrorState(
          message: l10n.todayError,
          onRetry: () => refreshToday(ref),
          stateKey: errorKey,
          retryLabel: l10n.commonRetry,
        ),
        data: (workouts) => workouts.isEmpty
            ? _Empty(message: l10n.todayEmpty)
            : _TodayList(workouts: workouts),
      ),
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList({required this.workouts});

  final List<WorkoutInstanceSummary> workouts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView.builder(
      key: TodayScreen.listKey,
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        final duration = formatDurationLabel(
          l10n,
          workout.plannedDurationSeconds,
        );
        return Card(
          key: TodayScreen.cardKey(workout.id),
          child: ListTile(
            title: Text(workout.title),
            subtitle: Text([workout.workoutType, ?duration].join(' · ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.push(AppRoutes.workoutDetailLocation(workout.id)),
          ),
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.message, required this.keyValue});

  final String message;
  final Key keyValue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        key: keyValue,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        key: TodayScreen.emptyKey,
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.stateKey,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final Key stateKey;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        key: stateKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(
            key: TodayScreen.retryKey,
            onPressed: onRetry,
            child: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}
