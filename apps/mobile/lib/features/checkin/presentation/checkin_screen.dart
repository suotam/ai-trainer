import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/tables/checkin_tables.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/checkin_providers.dart';
import '../domain/daily_check_in.dart';

/// Denní check-in (R5-01, C33): dnešní stav s editací (DCI-002/014),
/// definované škály 1–5 (DCI-003), bolest strukturovaně (DCI-004),
/// poznámka výhradně lokální (DCI-006) a historie (DCI-007). Check-in
/// není nikdy povinný (DCI-001); beta označení bez medicínských tvrzení
/// (R5P-003).
class CheckInScreen extends ConsumerWidget {
  const CheckInScreen({super.key});

  static const Key screenKey = Key('checkin_screen');
  static const Key saveKey = Key('checkin_save');
  static const Key savedBannerKey = Key('checkin_saved');
  static const Key errorBannerKey = Key('checkin_error');
  static const Key noteFieldKey = Key('checkin_note');
  static const Key historyHeaderKey = Key('checkin_history');

  static Key levelKey(String section, int level) =>
      Key('checkin_${section}_$level');
  static Key painAreaKey(String code) => Key('checkin_pain_area_$code');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayCheckInProvider);
    final saveState = ref.watch(checkInControllerProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.checkinTitle)),
      body: Column(
        children: [
          if (saveState is CheckInSavedState)
            MaterialBanner(
              key: savedBannerKey,
              content: Text(l10n.checkinSaved),
              actions: const [SizedBox.shrink()],
            ),
          if (saveState is CheckInFailure)
            MaterialBanner(
              key: errorBannerKey,
              content: Text(l10n.checkinError),
              actions: const [SizedBox.shrink()],
            ),
          Expanded(
            child: today.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.checkinError)),
              // Formulář se přestaví po každém uložení (nový updatedAt) —
              // uložené hodnoty jsou viditelné a editovatelné (DCI-014).
              data: (checkIn) => _CheckInForm(
                key: ValueKey(checkIn?.updatedAtMillis),
                initial: checkIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInForm extends ConsumerStatefulWidget {
  const _CheckInForm({super.key, required this.initial});

  final DailyCheckIn? initial;

  @override
  ConsumerState<_CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends ConsumerState<_CheckInForm> {
  late int _energy;
  late int _fatigue;
  int? _sleep;
  int? _pain;
  String? _painArea;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _energy = initial?.energyLevel ?? 3;
    _fatigue = initial?.fatigueLevel ?? 3;
    _sleep = initial?.sleepQuality;
    _pain = initial?.painLevel;
    _painArea = initial?.painAreaCode;
    _note = TextEditingController(text: initial?.note ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saving = ref.watch(checkInControllerProvider) is CheckInSaving;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.checkinBetaNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        _LevelPicker(
          label: l10n.checkinEnergy,
          section: 'energy',
          value: _energy,
          onChanged: (level) => setState(() => _energy = level ?? _energy),
        ),
        _LevelPicker(
          label: l10n.checkinFatigue,
          section: 'fatigue',
          value: _fatigue,
          onChanged: (level) => setState(() => _fatigue = level ?? _fatigue),
        ),
        _LevelPicker(
          label: l10n.checkinSleep,
          section: 'sleep',
          value: _sleep,
          clearable: true,
          onChanged: (level) => setState(() => _sleep = level),
        ),
        _LevelPicker(
          label: l10n.checkinPain,
          section: 'pain',
          value: _pain,
          clearable: true,
          onChanged: (level) => setState(() {
            _pain = level;
            if (level == null) {
              _painArea = null;
            }
          }),
        ),
        if (_pain != null) ...[
          const SizedBox(height: 4),
          Text(l10n.checkinPainArea),
          Wrap(
            spacing: 8,
            children: [
              for (final code in painAreaCodes)
                ChoiceChip(
                  key: CheckInScreen.painAreaKey(code),
                  label: Text(l10n.checkinPainAreaLabel(code)),
                  selected: _painArea == code,
                  onSelected: (_) => setState(() => _painArea = code),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          key: CheckInScreen.noteFieldKey,
          controller: _note,
          decoration: InputDecoration(labelText: l10n.checkinNote),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: CheckInScreen.saveKey,
          onPressed: saving
              ? null
              : () => ref
                    .read(checkInControllerProvider.notifier)
                    .saveToday(
                      DailyCheckInInput(
                        energyLevel: _energy,
                        fatigueLevel: _fatigue,
                        sleepQuality: _sleep,
                        painLevel: _pain,
                        painAreaCode: _painArea,
                        note: _note.text.trim().isEmpty
                            ? null
                            : _note.text.trim(),
                      ),
                    ),
          child: Text(l10n.checkinSave),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.checkinHistoryHeader,
          key: CheckInScreen.historyHeaderKey,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const _HistoryList(),
      ],
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(checkInHistoryProvider);
    return history.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) => items.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.checkinHistoryEmpty),
            )
          : Column(
              children: [
                for (final item in items)
                  ListTile(
                    key: Key('checkin_history_${item.localDate}'),
                    dense: true,
                    title: Text(item.localDate),
                    subtitle: Text(
                      [
                        '${l10n.checkinEnergy} ${item.energyLevel}',
                        '${l10n.checkinFatigue} ${item.fatigueLevel}',
                        if (item.hasPain)
                          '${l10n.checkinPainAreaLabel(item.painAreaCode!)} '
                              '${item.painLevel}',
                      ].join(' · '),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Škála 1–5 s definovaným významem (DCI-003). U volitelných sekcí
/// opětovný tap vybraný stupeň zruší (hodnota není povinná, DCI-001).
class _LevelPicker extends StatelessWidget {
  const _LevelPicker({
    required this.label,
    required this.section,
    required this.value,
    required this.onChanged,
    this.clearable = false,
  });

  final String label;
  final String section;
  final int? value;
  final ValueChanged<int?> onChanged;
  final bool clearable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Wrap(
            spacing: 8,
            children: [
              for (var level = 1; level <= 5; level++)
                ChoiceChip(
                  key: CheckInScreen.levelKey(section, level),
                  label: Text('$level'),
                  selected: value == level,
                  onSelected: (_) =>
                      onChanged(clearable && value == level ? null : level),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
