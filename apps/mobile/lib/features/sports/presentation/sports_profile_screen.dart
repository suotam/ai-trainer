import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/sports_profile_providers.dart';
import '../domain/sport_catalog.dart';
import '../domain/user_sport.dart';

/// Sportovní profil (R3-01, C17): seznam sportů uživatele s přidáním,
/// úpravou a lifecycle akcemi (pause/resume/end — konec je stav, ne
/// mazání, ASP-008). Offline-first, poctivý empty stav (ASP-014),
/// typované chyby invariantů (ASP-003/004).
class SportsProfileScreen extends ConsumerWidget {
  const SportsProfileScreen({super.key});

  static const Key screenKey = Key('sports_profile_screen');
  static const Key emptyKey = Key('sports_profile_empty');
  static const Key listKey = Key('sports_profile_list');
  static const Key addButtonKey = Key('sports_profile_add');
  static const Key errorBannerKey = Key('sports_profile_error');

  static Key tileKey(String id) => Key('sports_profile_tile_$id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sports = ref.watch(userSportsProvider);
    final saveState = ref.watch(sportsProfileControllerProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.sportsProfileTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: addButtonKey,
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.sportsAdd),
      ),
      body: Column(
        children: [
          if (saveState is SportsProfileFailure)
            MaterialBanner(
              key: errorBannerKey,
              content: Text(_failureText(l10n, saveState.result)),
              actions: [const SizedBox.shrink()],
            ),
          Expanded(
            child: sports.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.sportsErrorValidation)),
              data: (items) => items.isEmpty
                  ? Center(
                      child: Padding(
                        key: emptyKey,
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.sportsEmpty,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView(
                      key: listKey,
                      children: [
                        for (final sport in items)
                          _SportTile(
                            sport: sport,
                            onEdit: () =>
                                _openForm(context, ref, existing: sport),
                          ),
                        const SizedBox(height: 88),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _failureText(AppLocalizations l10n, SaveUserSportResult result) =>
      switch (result) {
        UserSportDuplicate() => l10n.sportsErrorDuplicate,
        UserSportPrimaryConflict() => l10n.sportsErrorPrimary,
        _ => l10n.sportsErrorValidation,
      };

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    UserSport? existing,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _SportForm(existing: existing),
  );
}

class _SportTile extends ConsumerWidget {
  const _SportTile({required this.sport, required this.onEdit});

  final UserSport sport;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(sportsProfileControllerProvider.notifier);
    final title = sport.isCustom
        ? (sport.customName ?? '')
        : l10n.sportName(sport.sportCode!);
    final subtitleParts = [
      l10n.sportRoleLabel(sport.role),
      l10n.sportPriorityLabel(sport.priority),
      l10n.sportExperienceLabel(sport.experienceLevel),
      if (sport.status != 'ACTIVE') l10n.sportStatusLabel(sport.status),
    ];
    return ListTile(
      key: SportsProfileScreen.tileKey(sport.id),
      title: Text(title),
      subtitle: Text(subtitleParts.join(' · ')),
      enabled: sport.status != 'ENDED',
      trailing: PopupMenuButton<String>(
        key: Key('sports_profile_menu_${sport.id}'),
        onSelected: (action) {
          switch (action) {
            case 'edit':
              onEdit();
            case 'pause':
              controller.changeStatus(sport.id, 'PAUSED');
            case 'resume':
              controller.changeStatus(sport.id, 'ACTIVE');
            case 'end':
              controller.changeStatus(sport.id, 'ENDED');
          }
        },
        itemBuilder: (_) => [
          if (sport.status != 'ENDED')
            PopupMenuItem(value: 'edit', child: Text(l10n.sportsActionEdit)),
          if (sport.status == 'ACTIVE')
            PopupMenuItem(value: 'pause', child: Text(l10n.sportsActionPause)),
          if (sport.status == 'PAUSED')
            PopupMenuItem(
              value: 'resume',
              child: Text(l10n.sportsActionResume),
            ),
          if (sport.status != 'ENDED')
            PopupMenuItem(value: 'end', child: Text(l10n.sportsActionEnd)),
        ],
      ),
    );
  }
}

/// Formulář sportu — vytvoření i úprava current-state (ASP-007).
/// Sport reference je katalogový kód XOR custom název (C17 §4.1);
/// všechna pattern pole jsou volitelná (ASP-010).
class _SportForm extends ConsumerStatefulWidget {
  const _SportForm({required this.existing});

  final UserSport? existing;

  static const Key sportFieldKey = Key('sport_form_sport');
  static const Key customNameKey = Key('sport_form_custom_name');
  static const Key roleFieldKey = Key('sport_form_role');
  static const Key saveKey = Key('sport_form_save');

  @override
  ConsumerState<_SportForm> createState() => _SportFormState();
}

class _SportFormState extends ConsumerState<_SportForm> {
  static const _customSentinel = '__CUSTOM__';

  late String _sportSelection;
  late final TextEditingController _customName;
  late String _role;
  late String _priority;
  late String _experience;
  String? _intensity;
  String? _environment;
  late final TextEditingController _frequency;
  late final TextEditingController _duration;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _sportSelection = existing == null
        ? sportCatalog.first.code
        : (existing.sportCode ?? _customSentinel);
    _customName = TextEditingController(text: existing?.customName ?? '');
    _role = existing?.role ?? 'RECREATIONAL';
    _priority = existing?.priority ?? 'MEDIUM';
    _experience = existing?.experienceLevel ?? 'UNKNOWN';
    _intensity = existing?.typicalIntensity;
    _environment = existing?.environment;
    _frequency = TextEditingController(
      text: existing?.frequencyPerWeek?.toString() ?? '',
    );
    _duration = TextEditingController(
      text: existing?.typicalDurationMinutes?.toString() ?? '',
    );
    _note = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _customName.dispose();
    _frequency.dispose();
    _duration.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCustom = _sportSelection == _customSentinel;

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
            DropdownButtonFormField<String>(
              key: _SportForm.sportFieldKey,
              initialValue: _sportSelection,
              decoration: InputDecoration(labelText: l10n.sportsFieldSport),
              items: [
                for (final entry in sportCatalog)
                  DropdownMenuItem(
                    value: entry.code,
                    child: Text(l10n.sportName(entry.code)),
                  ),
                DropdownMenuItem(
                  value: _customSentinel,
                  child: Text(l10n.sportsCustomOption),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _sportSelection = value ?? _sportSelection),
            ),
            if (isCustom)
              TextField(
                key: _SportForm.customNameKey,
                controller: _customName,
                decoration: InputDecoration(
                  labelText: l10n.sportsFieldCustomName,
                ),
              ),
            DropdownButtonFormField<String>(
              key: _SportForm.roleFieldKey,
              initialValue: _role,
              decoration: InputDecoration(labelText: l10n.sportsFieldRole),
              items: [
                for (final role in userSportRoles)
                  DropdownMenuItem(
                    value: role,
                    child: Text(l10n.sportRoleLabel(role)),
                  ),
              ],
              onChanged: (value) => setState(() => _role = value ?? _role),
            ),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: InputDecoration(labelText: l10n.sportsFieldPriority),
              items: [
                for (final priority in userSportPriorities)
                  DropdownMenuItem(
                    value: priority,
                    child: Text(l10n.sportPriorityLabel(priority)),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _priority = value ?? _priority),
            ),
            DropdownButtonFormField<String>(
              initialValue: _experience,
              decoration: InputDecoration(
                labelText: l10n.sportsFieldExperience,
              ),
              items: [
                for (final level in experienceLevels)
                  DropdownMenuItem(
                    value: level,
                    child: Text(l10n.sportExperienceLabel(level)),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _experience = value ?? _experience),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _frequency,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.sportsFieldFrequency,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.sportsFieldDuration,
                    ),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String?>(
              initialValue: _intensity,
              decoration: InputDecoration(labelText: l10n.sportsFieldIntensity),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.sportsNotSet)),
                for (final intensity in typicalIntensities)
                  DropdownMenuItem(
                    value: intensity,
                    child: Text(l10n.sportIntensityLabel(intensity)),
                  ),
              ],
              onChanged: (value) => setState(() => _intensity = value),
            ),
            DropdownButtonFormField<String?>(
              initialValue: _environment,
              decoration: InputDecoration(
                labelText: l10n.sportsFieldEnvironment,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.sportsNotSet)),
                for (final environment in sportEnvironments)
                  DropdownMenuItem(
                    value: environment,
                    child: Text(l10n.sportEnvironmentLabel(environment)),
                  ),
              ],
              onChanged: (value) => setState(() => _environment = value),
            ),
            TextField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.sportsFieldNote),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: _SportForm.saveKey,
              onPressed: _save,
              child: Text(l10n.sportsSave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final isCustom = _sportSelection == _customSentinel;
    final input = UserSportInput(
      sportCode: isCustom ? null : _sportSelection,
      customName: isCustom ? _customName.text.trim() : null,
      customCategory: isCustom ? 'CUSTOM' : null,
      role: _role,
      priority: _priority,
      experienceLevel: _experience,
      frequencyPerWeek: int.tryParse(_frequency.text.trim()),
      typicalDurationMinutes: int.tryParse(_duration.text.trim()),
      typicalIntensity: _intensity,
      environment: _environment,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      lastRegularActivityDate: widget.existing?.lastRegularActivityDate,
      returnAfterPause: widget.existing?.returnAfterPause ?? false,
      fixedDays: widget.existing?.fixedDays ?? const [],
    );
    final controller = ref.read(sportsProfileControllerProvider.notifier);
    await controller.save(input, existingId: widget.existing?.id);
    final state = ref.read(sportsProfileControllerProvider);
    if (mounted && state is SportsProfileSaved) {
      Navigator.of(context).pop();
    }
  }
}
