import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../notifications/application/notification_providers.dart';
import '../application/summary_providers.dart';

/// Týdenní souhrn (R5-07, C39): fakta 7 dní + trend + check-in agregáty,
/// opatrné formulace (WKS-005), poctivé prázdné stavy (WKS-004). Součástí
/// obrazovky jsou opt-in připomínky (C40) — nikdy nejednají (NTF-001).
class WeeklySummaryScreen extends ConsumerWidget {
  const WeeklySummaryScreen({super.key});

  static const Key screenKey = Key('summary_screen');
  static const Key explanationKey = Key('summary_explanation');
  static const Key checkInReminderKey = Key('summary_reminder_checkin');
  static const Key workoutReminderKey = Key('summary_reminder_workout');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(weeklySummaryProvider);
    final settings = ref.watch(reminderSettingsProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.summaryTitle)),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.summaryError)),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.summaryPeriod(data.fromLocalDate, data.toLocalDate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.summaryExplanation(data.explanation.code),
              key: explanationKey,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _factRow(
              l10n.summaryPlanned,
              '${data.current.plannedCount}',
              key: const Key('summary_planned'),
            ),
            _factRow(
              l10n.summaryCompleted,
              '${data.current.completedCount}'
              ' (${l10n.summaryPreviousWeek(data.previous.completedCount)})',
              key: const Key('summary_completed'),
            ),
            _factRow(
              l10n.summaryCompletionRate,
              data.current.completionRate == null
                  ? '—'
                  : '${(data.current.completionRate! * 100).round()} %',
            ),
            _factRow(
              l10n.summaryManualActivities,
              '${data.current.manualActivityCount}'
              ' · ${data.current.manualMinutes} min',
            ),
            const Divider(height: 24),
            Text(
              l10n.summaryCheckInsHeader,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (data.checkIns.checkInCount == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.summaryCheckInsEmpty),
              )
            else ...[
              _factRow(
                l10n.summaryCheckInCount,
                '${data.checkIns.checkInCount}',
              ),
              _factRow(l10n.checkinEnergy, '${data.checkIns.averageEnergy}'),
              _factRow(l10n.checkinFatigue, '${data.checkIns.averageFatigue}'),
              _factRow(l10n.summaryPainDays, '${data.checkIns.painDays}'),
            ],
            const Divider(height: 24),
            Text(
              l10n.remindersHeader,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              l10n.remindersNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            settings.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (reminder) => Column(
                children: [
                  SwitchListTile(
                    key: checkInReminderKey,
                    title: Text(l10n.reminderCheckIn),
                    value: reminder.checkInEnabled,
                    onChanged: (enabled) => ref
                        .read(reminderSettingsControllerProvider.notifier)
                        .setCheckInEnabled(enabled),
                  ),
                  SwitchListTile(
                    key: workoutReminderKey,
                    title: Text(l10n.reminderWorkout),
                    value: reminder.workoutEnabled,
                    onChanged: (enabled) => ref
                        .read(reminderSettingsControllerProvider.notifier)
                        .setWorkoutEnabled(enabled),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _factRow(String label, String value, {Key? key}) => Padding(
    key: key,
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    ),
  );
}
