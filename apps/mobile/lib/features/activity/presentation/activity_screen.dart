import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../sports/application/sports_profile_providers.dart';
import '../application/activity_providers.dart';
import '../domain/manual_activity.dart';

/// Aktivita a progres (R3-06, C22/C23): statistiky posledních 7/30 dní
/// (deterministický read model, PST-001) a ruční aktivity (fakta po
/// skutečnosti, MAC-004). Poctivé empty stavy a „—" pro nedefinované
/// hodnoty (PST-004/009). Offline-first.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  static const Key screenKey = Key('activity_screen');
  static const Key emptyKey = Key('activity_empty');
  static const Key addButtonKey = Key('activity_add');
  static const Key errorBannerKey = Key('activity_error');
  static const Key weekCardKey = Key('activity_stats_week');
  static const Key monthCardKey = Key('activity_stats_month');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final activities = ref.watch(manualActivitiesProvider);
    final saveState = ref.watch(activityControllerProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.activityTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: addButtonKey,
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _ActivityForm(),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.activityAdd),
      ),
      body: ListView(
        children: [
          if (saveState is ActivityFailure)
            MaterialBanner(
              key: errorBannerKey,
              content: Text(l10n.activityErrorValidation),
              actions: [const SizedBox.shrink()],
            ),
          _StatsCard(
            cardKey: weekCardKey,
            title: l10n.activityStatsWeek,
            days: 7,
          ),
          _StatsCard(
            cardKey: monthCardKey,
            title: l10n.activityStatsMonth,
            days: 30,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n.activityListSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          activities.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text(l10n.activityErrorValidation)),
            data: (items) => items.isEmpty
                ? Padding(
                    key: emptyKey,
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.activityEmpty,
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      for (final activity in items)
                        _ActivityTile(activity: activity),
                    ],
                  ),
          ),
          const SizedBox(height: 88),
        ],
      ),
    );
  }
}

class _StatsCard extends ConsumerWidget {
  const _StatsCard({
    required this.cardKey,
    required this.title,
    required this.days,
  });

  final Key cardKey;
  final String title;
  final int days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(progressStatisticsProvider(days)).value;
    String rate() {
      final value = stats?.completionRate;
      // Nedefinovaná hodnota se neprezentuje jako číslo (PST-004).
      if (value == null) {
        return l10n.activityStatsNoData;
      }
      return '${(value * 100).round()} %';
    }

    return Card(
      key: cardKey,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Text(
                  '${l10n.activityStatsPlanned}: ${stats?.plannedCount ?? 0}',
                ),
                Text(
                  '${l10n.activityStatsCompleted}: ${stats?.completedCount ?? 0}',
                ),
                Text('${l10n.activityStatsCompletion}: ${rate()}'),
                Text(
                  '${l10n.activityStatsManual}: '
                  '${stats?.manualActivityCount ?? 0}',
                ),
                Text(
                  '${l10n.activityStatsManualMinutes}: '
                  '${stats?.manualMinutes ?? 0}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final ManualActivity activity;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      activity.localDate,
      if (activity.durationMinutes != null) '${activity.durationMinutes} min',
      if (activity.note != null) activity.note!,
    ];
    return ListTile(
      key: Key('activity_tile_${activity.id}'),
      dense: true,
      title: Text(activity.title),
      subtitle: Text(subtitleParts.join(' · ')),
    );
  }
}

/// Formulář ruční aktivity (C22 §3) — povinný jen popis a datum (MAC-002).
class _ActivityForm extends ConsumerStatefulWidget {
  const _ActivityForm();

  @override
  ConsumerState<_ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends ConsumerState<_ActivityForm> {
  late final TextEditingController _title;
  late final TextEditingController _date;
  late final TextEditingController _duration;
  late final TextEditingController _note;
  String? _sportId;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _date = TextEditingController(
      text: formatLocalDate(ref.read(clockProvider)()),
    );
    _duration = TextEditingController();
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _date.dispose();
    _duration.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sports = ref.watch(userSportsProvider).value ?? const [];
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('activity_form_title'),
              controller: _title,
              decoration: InputDecoration(labelText: l10n.activityFieldTitle),
            ),
            TextField(
              key: const Key('activity_form_date'),
              controller: _date,
              decoration: InputDecoration(labelText: l10n.activityFieldDate),
            ),
            TextField(
              controller: _duration,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.activityFieldDuration,
              ),
            ),
            DropdownButtonFormField<String?>(
              initialValue: _sportId,
              decoration: InputDecoration(labelText: l10n.activityFieldSport),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.activityNoSport),
                ),
                for (final sport in sports)
                  DropdownMenuItem(
                    value: sport.id,
                    child: Text(
                      sport.isCustom
                          ? (sport.customName ?? '')
                          : l10n.sportName(sport.sportCode!),
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _sportId = value),
            ),
            TextField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.activityFieldNote),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('activity_form_save'),
              onPressed: _save,
              child: Text(l10n.activitySave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await ref
        .read(activityControllerProvider.notifier)
        .save(
          ManualActivityInput(
            title: _title.text,
            localDate: _date.text.trim(),
            durationMinutes: int.tryParse(_duration.text.trim()),
            userSportId: _sportId,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          ),
        );
    if (mounted && ref.read(activityControllerProvider) is ActivitySaved) {
      Navigator.of(context).pop();
    }
  }
}
