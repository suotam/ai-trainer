import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../workouts/application/quick_complete_workout.dart';
import '../../workouts/domain/workout_read_model.dart';
import '../application/calendar_providers.dart';

/// Kalendář tréninků (R7-05, C50 §2): čistý read model nad C16 —
/// měsíční mřížka MON–SUN, výběr dne, poctivé stavy instancí (CQC-001).
/// Rychlé dokončení jde výhradně C22 cestou (CQC-003); statistiky a
/// souhrn jsou odkazy na C23/C39 (CQC-007).
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  static const Key screenKey = Key('calendar_screen');
  static const Key prevMonthKey = Key('calendar_prev_month');
  static const Key nextMonthKey = Key('calendar_next_month');
  static const Key resultKey = Key('calendar_quick_result');

  static Key dayKey(String localDate) => Key('calendar_day_$localDate');
  static Key quickCompleteKey(String workoutId) =>
      Key('calendar_quick_$workoutId');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final month = ref.watch(calendarMonthProvider);
    final selectedDate = ref.watch(calendarSelectedDateProvider);
    final workouts = ref.watch(calendarMonthWorkoutsProvider);
    final quickResult = ref.watch(quickCompleteControllerProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            tooltip: l10n.summaryOpenTooltip,
            onPressed: () => context.push(AppRoutes.summaryPath),
          ),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: l10n.activityOpenTooltip,
            onPressed: () => context.push(AppRoutes.activityPath),
          ),
        ],
      ),
      body: workouts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.aiErrorUnavailable)),
        data: (byDate) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _MonthHeader(month: month),
            const SizedBox(height: 8),
            _MonthGrid(month: month, byDate: byDate, selected: selectedDate),
            const SizedBox(height: 16),
            if (quickResult != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(key: resultKey, switch (quickResult) {
                  QuickCompleted() ||
                  QuickAlreadyCompleted() => l10n.quickCompleteDone,
                  QuickBlockedByOtherSession() => l10n.quickCompleteBlocked,
                  _ => l10n.quickCompleteFailed,
                }),
              ),
            Text(selectedDate, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            ...switch (byDate[selectedDate] ?? const []) {
              [] => [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(l10n.calendarEmptyDay),
                ),
              ],
              final dayWorkouts => [
                for (final workout in dayWorkouts)
                  _WorkoutTile(workout: workout),
              ],
            },
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends ConsumerWidget {
  const _MonthHeader({required this.month});

  final String month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          key: CalendarScreen.prevMonthKey,
          icon: const Icon(Icons.chevron_left),
          onPressed: () => ref.read(calendarMonthProvider.notifier).shift(-1),
        ),
        Text(month, style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          key: CalendarScreen.nextMonthKey,
          icon: const Icon(Icons.chevron_right),
          onPressed: () => ref.read(calendarMonthProvider.notifier).shift(1),
        ),
      ],
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({
    required this.month,
    required this.byDate,
    required this.selected,
  });

  final String month;
  final Map<String, List<WorkoutInstanceSummary>> byDate;
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final monthNumber = int.parse(parts[1]);
    final firstWeekday = DateTime(year, monthNumber, 1).weekday; // MON=1
    final daysInMonth = DateTime(year, monthNumber + 1, 0).day;

    String dateOf(int day) => '$month-${day.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Row(
          children: [
            for (final label in ['Po', 'Út', 'St', 'Čt', 'Pá', 'So', 'Ne'])
              Expanded(
                child: Center(
                  child: Text(label, style: theme.textTheme.labelSmall),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < firstWeekday - 1; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              InkWell(
                key: CalendarScreen.dayKey(dateOf(day)),
                onTap: () => ref
                    .read(calendarSelectedDateProvider.notifier)
                    .select(dateOf(day)),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: selected == dateOf(day)
                        ? theme.colorScheme.primaryContainer
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$day'),
                      if ((byDate[dateOf(day)] ?? const []).isNotEmpty)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _WorkoutTile extends ConsumerWidget {
  const _WorkoutTile({required this.workout});

  final WorkoutInstanceSummary workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Quick-complete jen pro neuzavřené stavy — PARTIALLY_COMPLETED je
    // poctivý výsledek quick-complete dle C22 (CQC-004).
    final isCompleted =
        workout.status.code == 'COMPLETED' ||
        workout.status.code == 'PARTIALLY_COMPLETED';
    final isCancelled = workout.status.code == 'CANCELLED';
    return ListTile(
      title: Text(workout.title),
      subtitle: Text(
        '${workout.workoutType} · '
        '${l10n.calendarWorkoutStatus(workout.status.code)}',
      ),
      // Tap vede na existující detail (mutace výhradně C21/C22 cestami,
      // CQC-008).
      onTap: () => context.push(AppRoutes.workoutDetailLocation(workout.id)),
      trailing: isCompleted || isCancelled
          ? null
          : TextButton(
              key: CalendarScreen.quickCompleteKey(workout.id),
              onPressed: () => ref
                  .read(quickCompleteControllerProvider.notifier)
                  .quickComplete(workout.id),
              child: Text(l10n.quickCompleteButton),
            ),
    );
  }
}
