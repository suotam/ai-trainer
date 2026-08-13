import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/availability_providers.dart';
import '../domain/availability_profile.dart';

/// Dostupnost a tréninkový kontext (R3-03, C19): typický týden, vybavení
/// a základní omezení. Deklarace, ne vynucení (AVC-005); den bez deklarace
/// je „nezadáno", ne nedostupný (AVC-004); archivace/vyřešení jsou stavy,
/// ne mazání (AVC-007). Offline-first.
class AvailabilityScreen extends ConsumerWidget {
  const AvailabilityScreen({super.key});

  static const Key screenKey = Key('availability_screen');
  static const Key errorBannerKey = Key('availability_error');
  static const Key equipmentAddKey = Key('availability_equipment_add');
  static const Key constraintAddKey = Key('availability_constraint_add');

  static Key dayKey(String day) => Key('availability_day_$day');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final week = ref.watch(availabilityWeekProvider);
    final equipment = ref.watch(equipmentProvider);
    final constraints = ref.watch(constraintsProvider);
    final saveState = ref.watch(availabilityControllerProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.availabilityTitle)),
      body: ListView(
        children: [
          if (saveState is AvailabilityFailure)
            MaterialBanner(
              key: errorBannerKey,
              content: Text(switch (saveState.result) {
                AvailabilityWriteDuplicate() => l10n.availabilityErrorDuplicate,
                _ => l10n.availabilityErrorValidation,
              }),
              actions: [const SizedBox.shrink()],
            ),
          _SectionHeader(title: l10n.availabilityWeekSection),
          for (final day in weekDays)
            _DayTile(
              day: day,
              rule: week.value?.where((r) => r.dayOfWeek == day).firstOrNull,
            ),
          _SectionHeader(
            title: l10n.availabilityEquipmentSection,
            action: IconButton(
              key: equipmentAddKey,
              icon: const Icon(Icons.add),
              tooltip: l10n.equipmentAdd,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _EquipmentForm(),
              ),
            ),
          ),
          for (final item in equipment.value ?? const <EquipmentItem>[])
            _EquipmentTile(item: item),
          _SectionHeader(
            title: l10n.availabilityConstraintsSection,
            action: IconButton(
              key: constraintAddKey,
              icon: const Icon(Icons.add),
              tooltip: l10n.constraintsAdd,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _ConstraintForm(),
              ),
            ),
          ),
          for (final constraint
              in constraints.value ?? const <BasicConstraint>[])
            _ConstraintTile(constraint: constraint),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        ?action,
      ],
    ),
  );
}

class _DayTile extends ConsumerWidget {
  const _DayTile({required this.day, required this.rule});

  final String day;
  final AvailabilityRule? rule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final declared = rule;
    final subtitle = declared == null
        ? l10n.availabilityDayNotSet
        : [
            l10n.availabilityLevelLabel(declared.level),
            if (declared.budgetMinutes != null) '${declared.budgetMinutes} min',
            if (declared.preferredPartOfDay != null)
              l10n.partOfDayLabel(declared.preferredPartOfDay!),
          ].join(' · ');
    return ListTile(
      key: AvailabilityScreen.dayKey(day),
      dense: true,
      title: Text(l10n.weekDayLabel(day)),
      subtitle: Text(subtitle),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _DayForm(day: day, rule: declared),
      ),
    );
  }
}

/// Formulář deklarace dne — upsert (AVC-003) a zpětvzetí (AVC-008).
class _DayForm extends ConsumerStatefulWidget {
  const _DayForm({required this.day, required this.rule});

  final String day;
  final AvailabilityRule? rule;

  @override
  ConsumerState<_DayForm> createState() => _DayFormState();
}

class _DayFormState extends ConsumerState<_DayForm> {
  late String _level;
  String? _partOfDay;
  late final TextEditingController _minutes;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _level = widget.rule?.level ?? 'AVAILABLE';
    _partOfDay = widget.rule?.preferredPartOfDay;
    _minutes = TextEditingController(
      text: widget.rule?.budgetMinutes?.toString() ?? '',
    );
    _note = TextEditingController(text: widget.rule?.note ?? '');
  }

  @override
  void dispose() {
    _minutes.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.weekDayLabel(widget.day),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          DropdownButtonFormField<String>(
            key: const Key('day_form_level'),
            initialValue: _level,
            decoration: InputDecoration(labelText: l10n.availabilityFieldLevel),
            items: [
              for (final level in availabilityLevels)
                DropdownMenuItem(
                  value: level,
                  child: Text(l10n.availabilityLevelLabel(level)),
                ),
            ],
            onChanged: (value) => setState(() => _level = value ?? _level),
          ),
          TextField(
            controller: _minutes,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.availabilityFieldMinutes,
            ),
          ),
          DropdownButtonFormField<String?>(
            initialValue: _partOfDay,
            decoration: InputDecoration(
              labelText: l10n.availabilityFieldPartOfDay,
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n.availabilityNotSet),
              ),
              for (final part in partsOfDay)
                DropdownMenuItem(
                  value: part,
                  child: Text(l10n.partOfDayLabel(part)),
                ),
            ],
            onChanged: (value) => setState(() => _partOfDay = value),
          ),
          TextField(
            controller: _note,
            decoration: InputDecoration(labelText: l10n.availabilityFieldNote),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('day_form_save'),
            onPressed: _save,
            child: Text(l10n.availabilitySave),
          ),
          if (widget.rule != null)
            TextButton(
              key: const Key('day_form_remove'),
              onPressed: _remove,
              child: Text(l10n.availabilityRemoveDay),
            ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await ref
        .read(availabilityControllerProvider.notifier)
        .upsertDay(
          dayOfWeek: widget.day,
          level: _level,
          budgetMinutes: int.tryParse(_minutes.text.trim()),
          preferredPartOfDay: _partOfDay,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    if (mounted &&
        ref.read(availabilityControllerProvider) is AvailabilitySaved) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _remove() async {
    await ref
        .read(availabilityControllerProvider.notifier)
        .removeDay(widget.day);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _EquipmentTile extends ConsumerWidget {
  const _EquipmentTile({required this.item});

  final EquipmentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(availabilityControllerProvider.notifier);
    final archived = item.status == 'ARCHIVED';
    return ListTile(
      key: Key('equipment_tile_${item.id}'),
      dense: true,
      title: Text(
        item.isCustom
            ? (item.customName ?? '')
            : l10n.equipmentName(item.equipmentCode!),
      ),
      subtitle: archived ? Text(l10n.equipmentArchivedLabel) : null,
      enabled: !archived,
      trailing: TextButton(
        key: Key('equipment_toggle_${item.id}'),
        onPressed: () => controller.setEquipmentStatus(
          item.id,
          archived ? 'ACTIVE' : 'ARCHIVED',
        ),
        child: Text(
          archived ? l10n.equipmentReactivate : l10n.equipmentArchive,
        ),
      ),
    );
  }
}

class _EquipmentForm extends ConsumerStatefulWidget {
  const _EquipmentForm();

  @override
  ConsumerState<_EquipmentForm> createState() => _EquipmentFormState();
}

class _EquipmentFormState extends ConsumerState<_EquipmentForm> {
  static const _customSentinel = '__CUSTOM__';
  String _selection = equipmentCatalog.first;
  final _customName = TextEditingController();

  @override
  void dispose() {
    _customName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCustom = _selection == _customSentinel;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            key: const Key('equipment_form_item'),
            initialValue: _selection,
            decoration: InputDecoration(labelText: l10n.equipmentFieldItem),
            items: [
              for (final code in equipmentCatalog)
                DropdownMenuItem(
                  value: code,
                  child: Text(l10n.equipmentName(code)),
                ),
              DropdownMenuItem(
                value: _customSentinel,
                child: Text(l10n.equipmentCustomOption),
              ),
            ],
            onChanged: (value) =>
                setState(() => _selection = value ?? _selection),
          ),
          if (isCustom)
            TextField(
              key: const Key('equipment_form_custom_name'),
              controller: _customName,
              decoration: InputDecoration(
                labelText: l10n.equipmentFieldCustomName,
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('equipment_form_save'),
            onPressed: _save,
            child: Text(l10n.availabilitySave),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final isCustom = _selection == _customSentinel;
    await ref
        .read(availabilityControllerProvider.notifier)
        .addEquipment(
          equipmentCode: isCustom ? null : _selection,
          customName: isCustom ? _customName.text.trim() : null,
        );
    if (mounted &&
        ref.read(availabilityControllerProvider) is AvailabilitySaved) {
      Navigator.of(context).pop();
    }
  }
}

class _ConstraintTile extends ConsumerWidget {
  const _ConstraintTile({required this.constraint});

  final BasicConstraint constraint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(availabilityControllerProvider.notifier);
    final resolved = constraint.status == 'RESOLVED';
    return ListTile(
      key: Key('constraint_tile_${constraint.id}'),
      dense: true,
      title: Text(constraint.title),
      subtitle: resolved ? Text(l10n.constraintsResolvedLabel) : null,
      enabled: !resolved,
      trailing: TextButton(
        key: Key('constraint_toggle_${constraint.id}'),
        onPressed: () => controller.setConstraintStatus(
          constraint.id,
          resolved ? 'ACTIVE' : 'RESOLVED',
        ),
        child: Text(
          resolved ? l10n.constraintsReactivate : l10n.constraintsResolve,
        ),
      ),
    );
  }
}

class _ConstraintForm extends ConsumerStatefulWidget {
  const _ConstraintForm();

  @override
  ConsumerState<_ConstraintForm> createState() => _ConstraintFormState();
}

class _ConstraintFormState extends ConsumerState<_ConstraintForm> {
  final _title = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('constraint_form_title'),
            controller: _title,
            decoration: InputDecoration(labelText: l10n.constraintsFieldTitle),
          ),
          TextField(
            controller: _note,
            decoration: InputDecoration(labelText: l10n.availabilityFieldNote),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('constraint_form_save'),
            onPressed: _save,
            child: Text(l10n.availabilitySave),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await ref
        .read(availabilityControllerProvider.notifier)
        .addConstraint(
          title: _title.text,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    if (mounted &&
        ref.read(availabilityControllerProvider) is AvailabilitySaved) {
      Navigator.of(context).pop();
    }
  }
}
