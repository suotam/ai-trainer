import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../sports/application/sports_profile_providers.dart';
import '../application/goals_providers.dart';
import '../domain/goal.dart';

/// Cíle (R3-02, C18): seznam cílů s přidáním, úpravou a lifecycle akcemi
/// (pause/resume/complete/abandon — uzavření je stav, ne mazání, GLC-005).
/// Offline-first, poctivý empty stav (GLC-013), typované chyby (GLC-004/006).
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  static const Key screenKey = Key('goals_screen');
  static const Key emptyKey = Key('goals_empty');
  static const Key listKey = Key('goals_list');
  static const Key addButtonKey = Key('goals_add');
  static const Key errorBannerKey = Key('goals_error');

  static Key tileKey(String id) => Key('goals_tile_$id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goals = ref.watch(goalsProvider);
    final saveState = ref.watch(goalsControllerProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: addButtonKey,
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.goalsAdd),
      ),
      body: Column(
        children: [
          if (saveState is GoalsFailure)
            MaterialBanner(
              key: errorBannerKey,
              content: Text(_failureText(l10n, saveState.result)),
              actions: [const SizedBox.shrink()],
            ),
          Expanded(
            child: goals.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.goalsErrorValidation)),
              data: (items) => items.isEmpty
                  ? Center(
                      child: Padding(
                        key: emptyKey,
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.goalsEmpty,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView(
                      key: listKey,
                      children: [
                        for (final goal in items)
                          _GoalTile(
                            goal: goal,
                            onEdit: () => _openForm(context, existing: goal),
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

  String _failureText(AppLocalizations l10n, SaveGoalResult result) =>
      switch (result) {
        GoalInvalidTransition() => l10n.goalsErrorTransition,
        _ => l10n.goalsErrorValidation,
      };

  Future<void> _openForm(BuildContext context, {Goal? existing}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _GoalForm(existing: existing),
      );
}

class _GoalTile extends ConsumerWidget {
  const _GoalTile({required this.goal, required this.onEdit});

  final Goal goal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(goalsControllerProvider.notifier);
    final subtitleParts = [
      l10n.goalTypeLabel(goal.goalType),
      l10n.goalPriorityLabel(goal.priority),
      l10n.goalHorizonLabel(goal.horizon),
      if (goal.targetLocalDate != null) goal.targetLocalDate!,
      if (goal.status != 'ACTIVE') l10n.goalStatusLabel(goal.status),
    ];
    return ListTile(
      key: GoalsScreen.tileKey(goal.id),
      title: Text(goal.title),
      subtitle: Text(subtitleParts.join(' · ')),
      enabled: !goal.isTerminal,
      trailing: goal.isTerminal
          ? null
          : PopupMenuButton<String>(
              key: Key('goals_menu_${goal.id}'),
              onSelected: (action) {
                switch (action) {
                  case 'edit':
                    onEdit();
                  case 'pause':
                    controller.changeStatus(goal.id, 'PAUSED');
                  case 'resume':
                    controller.changeStatus(goal.id, 'ACTIVE');
                  case 'complete':
                    controller.changeStatus(goal.id, 'COMPLETED');
                  case 'abandon':
                    controller.changeStatus(goal.id, 'ABANDONED');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.goalsActionEdit)),
                if (goal.status == 'ACTIVE')
                  PopupMenuItem(
                    value: 'pause',
                    child: Text(l10n.goalsActionPause),
                  ),
                if (goal.status == 'PAUSED')
                  PopupMenuItem(
                    value: 'resume',
                    child: Text(l10n.goalsActionResume),
                  ),
                PopupMenuItem(
                  value: 'complete',
                  child: Text(l10n.goalsActionComplete),
                ),
                PopupMenuItem(
                  value: 'abandon',
                  child: Text(l10n.goalsActionAbandon),
                ),
              ],
            ),
    );
  }
}

/// Formulář cíle — vytvoření i úprava ne-terminálního current-state
/// (GLC-006). Povinný je jen title (GLC-003).
class _GoalForm extends ConsumerStatefulWidget {
  const _GoalForm({required this.existing});

  final Goal? existing;

  static const Key titleKey = Key('goal_form_title');
  static const Key typeKey = Key('goal_form_type');
  static const Key priorityKey = Key('goal_form_priority');
  static const Key saveKey = Key('goal_form_save');

  @override
  ConsumerState<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<_GoalForm> {
  late final TextEditingController _title;
  late String _type;
  late String _priority;
  late String _horizon;
  String? _sportId;
  late final TextEditingController _targetDate;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _title = TextEditingController(text: existing?.title ?? '');
    _type = existing?.goalType ?? 'PERFORMANCE';
    _priority = existing?.priority ?? 'PRIMARY';
    _horizon = existing?.horizon ?? 'OPEN_ENDED';
    _sportId = existing?.userSportId;
    _targetDate = TextEditingController(text: existing?.targetLocalDate ?? '');
    _note = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _targetDate.dispose();
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
              key: _GoalForm.titleKey,
              controller: _title,
              decoration: InputDecoration(labelText: l10n.goalsFieldTitle),
            ),
            DropdownButtonFormField<String>(
              key: _GoalForm.typeKey,
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.goalsFieldType),
              items: [
                for (final type in goalTypes)
                  DropdownMenuItem(
                    value: type,
                    child: Text(l10n.goalTypeLabel(type)),
                  ),
              ],
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            DropdownButtonFormField<String>(
              key: _GoalForm.priorityKey,
              initialValue: _priority,
              decoration: InputDecoration(labelText: l10n.goalsFieldPriority),
              items: [
                for (final priority in goalPriorities)
                  DropdownMenuItem(
                    value: priority,
                    child: Text(l10n.goalPriorityLabel(priority)),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _priority = value ?? _priority),
            ),
            DropdownButtonFormField<String>(
              initialValue: _horizon,
              decoration: InputDecoration(labelText: l10n.goalsFieldHorizon),
              items: [
                for (final horizon in goalHorizons)
                  DropdownMenuItem(
                    value: horizon,
                    child: Text(l10n.goalHorizonLabel(horizon)),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _horizon = value ?? _horizon),
            ),
            DropdownButtonFormField<String?>(
              initialValue: _sportId,
              decoration: InputDecoration(labelText: l10n.goalsFieldSport),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.goalsNoSport)),
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
              controller: _targetDate,
              decoration: InputDecoration(labelText: l10n.goalsFieldTargetDate),
            ),
            TextField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.goalsFieldNote),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: _GoalForm.saveKey,
              onPressed: _save,
              child: Text(l10n.goalsSave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final input = GoalInput(
      title: _title.text,
      goalType: _type,
      priority: _priority,
      horizon: _horizon,
      userSportId: _sportId,
      targetLocalDate: _targetDate.text.trim().isEmpty
          ? null
          : _targetDate.text.trim(),
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    final controller = ref.read(goalsControllerProvider.notifier);
    await controller.save(input, existingId: widget.existing?.id);
    final state = ref.read(goalsControllerProvider);
    if (mounted && state is GoalsSaved) {
      Navigator.of(context).pop();
    }
  }
}
