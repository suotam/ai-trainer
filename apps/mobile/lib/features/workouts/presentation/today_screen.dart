import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../recommendation/presentation/today_recommendation_card.dart';
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
  static const Key aiActionKey = Key('today_ai_action');
  static const Key checkInActionKey = Key('today_checkin_action');
  static const Key summaryActionKey = Key('today_summary_action');
  static const Key moreActionsKey = Key('today_more_actions');
  static const Key chatActionKey = Key('today_chat_action');

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
          // Chat s trenérem (R7-02) — první akce; domovem se stane, až
          // umí jednat (R7-04).
          IconButton(
            key: chatActionKey,
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: l10n.chatOpenTooltip,
            onPressed: () => context.push(AppRoutes.chatPath),
          ),
          IconButton(
            key: checkInActionKey,
            icon: const Icon(Icons.monitor_heart_outlined),
            tooltip: l10n.checkinOpenTooltip,
            onPressed: () => context.push(AppRoutes.checkInPath),
          ),
          IconButton(
            key: aiActionKey,
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: l10n.aiOpenTooltip,
            onPressed: () => context.push(AppRoutes.aiProposalsPath),
          ),
          IconButton(
            key: planActionKey,
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: l10n.planOpenTooltip,
            onPressed: () => context.push(AppRoutes.planPath),
          ),
          IconButton(
            key: historyActionKey,
            icon: const Icon(Icons.history),
            tooltip: l10n.historyOpenTooltip,
            onPressed: () => context.push(AppRoutes.historyPath),
          ),
          // Na šířku telefonu se všech 10 akcí nevejde (on-device nález) —
          // méně frekventované cíle žijí v overflow menu.
          PopupMenuButton<String>(
            key: moreActionsKey,
            icon: const Icon(Icons.more_vert),
            onSelected: (path) => context.push(path),
            itemBuilder: (context) => [
              PopupMenuItem(
                key: accountActionKey,
                value: AppRoutes.accountPath,
                child: ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(l10n.accountOpenTooltip),
                ),
              ),
              PopupMenuItem(
                key: sportsActionKey,
                value: AppRoutes.sportsProfilePath,
                child: ListTile(
                  leading: const Icon(Icons.sports_gymnastics),
                  title: Text(l10n.sportsOpenTooltip),
                ),
              ),
              PopupMenuItem(
                key: goalsActionKey,
                value: AppRoutes.goalsPath,
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(l10n.goalsOpenTooltip),
                ),
              ),
              PopupMenuItem(
                key: availabilityActionKey,
                value: AppRoutes.availabilityPath,
                child: ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(l10n.availabilityOpenTooltip),
                ),
              ),
              PopupMenuItem(
                key: summaryActionKey,
                value: AppRoutes.summaryPath,
                child: ListTile(
                  leading: const Icon(Icons.summarize_outlined),
                  title: Text(l10n.summaryOpenTooltip),
                ),
              ),
              PopupMenuItem(
                key: activityActionKey,
                value: AppRoutes.activityPath,
                child: ListTile(
                  leading: const Icon(Icons.insights_outlined),
                  title: Text(l10n.activityOpenTooltip),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Deterministické doporučení dne (R5-03, C35) — aditivní blok,
          // R1 stavy Today zůstávají nedotčené (TDR-011).
          const TodayRecommendationCard(),
          Expanded(
            child: today.when(
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
          ),
        ],
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
