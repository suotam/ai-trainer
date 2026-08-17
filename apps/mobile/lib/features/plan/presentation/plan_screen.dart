import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../workouts/domain/exercise_catalog.dart';
import '../application/plan_providers.dart';
import '../domain/calendar_operations.dart';
import '../domain/training_plan.dart';

/// Ruční tréninkový plán (R3-04, C20): vytvoření plánu (nejvýše jeden
/// ACTIVE, MPC-002), přidávání workoutů (atomická R1 struktura, MPC-004)
/// a seznam workoutů plánu (MPC-013). Workouty se objevují v Today —
/// interní kalendář jsou existující R1 read modely (C20 §6).
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  static const Key screenKey = Key('plan_screen');
  static const Key emptyKey = Key('plan_empty');
  static const Key createFieldKey = Key('plan_create_field');
  static const Key createButtonKey = Key('plan_create_button');
  static const Key addWorkoutKey = Key('plan_add_workout');
  static const Key errorBannerKey = Key('plan_error');
  static const Key workoutsEmptyKey = Key('plan_workouts_empty');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plans = ref.watch(trainingPlansProvider);
    final saveState = ref.watch(planControllerProvider);
    final activePlan = plans.value?.where((p) => p.isActive).firstOrNull;

    return Scaffold(
      key: screenKey,
      appBar: AppBar(
        title: Text(activePlan?.title ?? l10n.planTitle),
        actions: [
          if (activePlan != null)
            IconButton(
              key: const Key('plan_archive_action'),
              icon: const Icon(Icons.archive_outlined),
              tooltip: l10n.planArchive,
              onPressed: () => ref
                  .read(planControllerProvider.notifier)
                  .setPlanStatus(activePlan.id, 'ARCHIVED'),
            ),
        ],
      ),
      floatingActionButton: activePlan == null
          ? null
          : FloatingActionButton.extended(
              key: addWorkoutKey,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => _WorkoutForm(planId: activePlan.id),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.planAddWorkout),
            ),
      body: Column(
        children: [
          if (saveState is PlanFailure)
            MaterialBanner(
              key: errorBannerKey,
              content: Text(switch (saveState.result) {
                PlanWriteActiveConflict() => l10n.planErrorConflict,
                _ => l10n.planErrorValidation,
              }),
              actions: [const SizedBox.shrink()],
            ),
          if (saveState is PlanCalendarFailure)
            MaterialBanner(
              key: errorBannerKey,
              content: Text(switch (saveState.result) {
                CalendarOpNotAllowed() => l10n.planErrorNotAllowed,
                _ => l10n.planErrorValidation,
              }),
              actions: [const SizedBox.shrink()],
            ),
          Expanded(
            child: activePlan == null
                ? _CreatePlanSection(archived: plans.value ?? const [])
                : _PlanWorkoutsList(planId: activePlan.id),
          ),
        ],
      ),
    );
  }
}

class _CreatePlanSection extends ConsumerStatefulWidget {
  const _CreatePlanSection({required this.archived});

  final List<TrainingPlan> archived;

  @override
  ConsumerState<_CreatePlanSection> createState() => _CreatePlanSectionState();
}

class _CreatePlanSectionState extends ConsumerState<_CreatePlanSection> {
  final _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          key: PlanScreen.emptyKey,
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(l10n.planEmpty, textAlign: TextAlign.center),
        ),
        TextField(
          key: PlanScreen.createFieldKey,
          controller: _title,
          decoration: InputDecoration(labelText: l10n.planCreateField),
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: PlanScreen.createButtonKey,
          onPressed: () => ref
              .read(planControllerProvider.notifier)
              .createPlan(title: _title.text),
          child: Text(l10n.planCreate),
        ),
        for (final plan in widget.archived.where((p) => !p.isActive))
          ListTile(
            key: Key('plan_archived_${plan.id}'),
            dense: true,
            title: Text(plan.title),
            subtitle: Text(l10n.planArchivedLabel),
            enabled: false,
          ),
      ],
    );
  }
}

class _PlanWorkoutsList extends ConsumerWidget {
  const _PlanWorkoutsList({required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final workouts = ref.watch(planWorkoutsProvider(planId));
    return workouts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.planErrorValidation)),
      data: (items) => items.isEmpty
          ? Center(
              child: Padding(
                key: PlanScreen.workoutsEmptyKey,
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.planWorkoutsEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              children: [
                for (final workout in items) _PlanWorkoutTile(workout: workout),
                const SizedBox(height: 88),
              ],
            ),
    );
  }
}

class _PlanWorkoutTile extends ConsumerWidget {
  const _PlanWorkoutTile({required this.workout});

  final PlannedWorkoutSummary workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(planControllerProvider.notifier);
    final cancelled = workout.status == 'CANCELLED';
    final subtitleParts = [
      l10n.planWorkoutSubtitle(
        workout.scheduledLocalDate,
        l10n.manualWorkoutTypeLabel(workout.workoutType),
        workout.exerciseCount,
      ),
      if (cancelled) l10n.planCancelledLabel,
    ];
    // Operace jen na budoucích/nezapočatých READY instancích (CAL-002/008);
    // guardy vynucuje repository, UI menu jen nenabízí u zjevných stavů.
    final operable = workout.status == 'READY';
    return ListTile(
      key: Key('plan_workout_${workout.instanceId}'),
      title: Text(workout.title),
      subtitle: Text(subtitleParts.join(' · ')),
      enabled: !cancelled,
      trailing: !operable
          ? null
          : PopupMenuButton<String>(
              key: Key('plan_workout_menu_${workout.instanceId}'),
              onSelected: (action) {
                switch (action) {
                  case 'move':
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => _MoveSheet(
                        instanceId: workout.instanceId,
                        currentDate: workout.scheduledLocalDate,
                      ),
                    );
                  case 'cancel':
                    controller.cancelWorkout(workout.instanceId);
                  case 'replace':
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) =>
                          _WorkoutForm(replaceInstanceId: workout.instanceId),
                    );
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'move', child: Text(l10n.planActionMove)),
                PopupMenuItem(
                  value: 'cancel',
                  child: Text(l10n.planActionCancel),
                ),
                PopupMenuItem(
                  value: 'replace',
                  child: Text(l10n.planActionReplace),
                ),
              ],
            ),
    );
  }
}

/// Sheet přesunu workoutu (C21 §4.1).
class _MoveSheet extends ConsumerStatefulWidget {
  const _MoveSheet({required this.instanceId, required this.currentDate});

  final String instanceId;
  final String currentDate;

  @override
  ConsumerState<_MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends ConsumerState<_MoveSheet> {
  late final TextEditingController _date;

  @override
  void initState() {
    super.initState();
    _date = TextEditingController(text: widget.currentDate);
  }

  @override
  void dispose() {
    _date.dispose();
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
            key: const Key('move_sheet_date'),
            controller: _date,
            decoration: InputDecoration(labelText: l10n.planMoveDateField),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('move_sheet_confirm'),
            onPressed: _save,
            child: Text(l10n.planMoveConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await ref
        .read(planControllerProvider.notifier)
        .moveWorkout(widget.instanceId, _date.text.trim());
    if (mounted && ref.read(planControllerProvider) is PlanSaved) {
      Navigator.of(context).pop();
    }
  }
}

/// Formulář ručního workoutu (C20 §5.1) — title, typ, datum, délka a
/// dynamický seznam cviků (série × opakování × volitelná váha).
/// V replace režimu (C21 §4.3) nahrazuje existující workout.
class _WorkoutForm extends ConsumerStatefulWidget {
  const _WorkoutForm({this.planId, this.replaceInstanceId})
    : assert(
        (planId != null) != (replaceInstanceId != null),
        'Právě jeden režim: add do plánu XOR replace instance.',
      );

  final String? planId;
  final String? replaceInstanceId;

  @override
  ConsumerState<_WorkoutForm> createState() => _WorkoutFormState();
}

class _ExerciseDraft {
  _ExerciseDraft()
    : title = TextEditingController(),
      sets = TextEditingController(text: '3'),
      reps = TextEditingController(text: '10'),
      weight = TextEditingController(),
      instructions = TextEditingController(),
      titleFocus = FocusNode();

  final TextEditingController title;
  final FocusNode titleFocus;
  final TextEditingController sets;

  /// Opakování (SET_REP) nebo sekundy (DURATION) — dle vybraného cviku.
  final TextEditingController reps;
  final TextEditingController weight;
  final TextEditingController instructions;

  /// Vybraný katalogový cvik (C51); `null` = vlastní cvik s povinným
  /// popisem (EXC-008).
  String? exerciseCode;

  bool get isDuration =>
      exerciseCode != null &&
      exerciseCatalogEntry(exerciseCode!)?.defaultPrescription ==
          ExercisePrescription.duration;

  void dispose() {
    title.dispose();
    sets.dispose();
    reps.dispose();
    weight.dispose();
    instructions.dispose();
    titleFocus.dispose();
  }
}

/// Pole jednoho cviku ručního formuláře (C51 §6/§10): název jako výběr
/// z katalogu (Autocomplete nad lokalizovanými názvy) nebo volný text =
/// vlastní cvik s povinným popisem; u DURATION cviku sekundy místo opakování.
class _ExerciseFields extends StatelessWidget {
  const _ExerciseFields({
    required this.index,
    required this.draft,
    required this.onCatalogChanged,
  });

  final int index;
  final _ExerciseDraft draft;
  final VoidCallback onCatalogChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = activeExerciseCatalog();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RawAutocomplete<ExerciseCatalogEntry>(
          key: Key('exercise_autocomplete_$index'),
          textEditingController: draft.title,
          focusNode: draft.titleFocus,
          displayStringForOption: (entry) => l10n.exerciseName(entry.code),
          optionsBuilder: (value) {
            final query = value.text.trim().toLowerCase();
            if (query.isEmpty) {
              return const Iterable<ExerciseCatalogEntry>.empty();
            }
            return catalog.where(
              (entry) =>
                  l10n.exerciseName(entry.code).toLowerCase().contains(query) ||
                  entry.code.toLowerCase().contains(query),
            );
          },
          onSelected: (entry) {
            draft.exerciseCode = entry.code;
            if (draft.isDuration && (int.tryParse(draft.reps.text) ?? 0) < 15) {
              draft.reps.text = '30';
            }
            onCatalogChanged();
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
              TextField(
                key: Key('exercise_name_$index'),
                controller: controller,
                focusNode: focusNode,
                onChanged: (text) {
                  // Ruční přepis názvu ruší vazbu na katalog — vlastní cvik.
                  final selected = draft.exerciseCode;
                  if (selected != null &&
                      text.trim() != l10n.exerciseName(selected)) {
                    draft.exerciseCode = null;
                    onCatalogChanged();
                  }
                },
                decoration: InputDecoration(
                  labelText: l10n.planExerciseName,
                  hintText: l10n.planExerciseCatalogHint,
                  suffixIcon: draft.exerciseCode == null
                      ? null
                      : const Icon(Icons.menu_book_outlined, size: 18),
                ),
              ),
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 220,
                  maxWidth: 360,
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final option in options.take(12))
                      ListTile(
                        key: Key('exercise_option_${option.code}'),
                        dense: true,
                        title: Text(l10n.exerciseName(option.code)),
                        onTap: () => onSelected(option),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: Key('exercise_sets_$index'),
                controller: draft.sets,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.planExerciseSets),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                key: Key('exercise_reps_$index'),
                controller: draft.reps,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: draft.isDuration
                      ? l10n.planExerciseSeconds
                      : l10n.planExerciseReps,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: draft.weight,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.planExerciseWeight),
              ),
            ),
          ],
        ),
        if (draft.exerciseCode == null)
          TextField(
            key: Key('exercise_instructions_$index'),
            controller: draft.instructions,
            decoration: InputDecoration(
              labelText: l10n.planExerciseInstructions,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _WorkoutFormState extends ConsumerState<_WorkoutForm> {
  late final TextEditingController _title;
  String _type = 'STRENGTH';
  late final TextEditingController _date;
  late final TextEditingController _duration;
  final List<_ExerciseDraft> _exercises = [];

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    // Předvyplněné dnešní datum z injektovaného clocku.
    final now = ref.read(clockProvider)();
    _date = TextEditingController(
      text:
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}',
    );
    _duration = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _date.dispose();
    _duration.dispose();
    for (final exercise in _exercises) {
      exercise.dispose();
    }
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('workout_form_title'),
              controller: _title,
              decoration: InputDecoration(
                labelText: l10n.planFieldWorkoutTitle,
              ),
            ),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.planFieldType),
              items: [
                for (final type in manualWorkoutTypes)
                  DropdownMenuItem(
                    value: type,
                    child: Text(l10n.manualWorkoutTypeLabel(type)),
                  ),
              ],
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            TextField(
              key: const Key('workout_form_date'),
              controller: _date,
              decoration: InputDecoration(labelText: l10n.planFieldDate),
            ),
            TextField(
              controller: _duration,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.planFieldDuration),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.planExercises,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (var i = 0; i < _exercises.length; i++)
              _ExerciseFields(
                index: i,
                draft: _exercises[i],
                onCatalogChanged: () => setState(() {}),
              ),
            if (_customWithoutInstructions)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.planExerciseCustomNeedsInstructions,
                  key: const Key('workout_form_custom_needs_instructions'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            TextButton.icon(
              key: const Key('workout_form_add_exercise'),
              onPressed: () => setState(() => _exercises.add(_ExerciseDraft())),
              icon: const Icon(Icons.add),
              label: Text(l10n.planAddExercise),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('workout_form_save'),
              onPressed: _save,
              child: Text(l10n.planSave),
            ),
          ],
        ),
      ),
    );
  }

  bool _customWithoutInstructions = false;

  Future<void> _save() async {
    // Vlastní cvik bez popisu provedení se neuloží (C51 EXC-008).
    final missing = _exercises.any(
      (e) =>
          e.exerciseCode == null &&
          e.title.text.trim().isNotEmpty &&
          e.instructions.text.trim().isEmpty,
    );
    if (missing != _customWithoutInstructions) {
      setState(() => _customWithoutInstructions = missing);
    }
    if (missing) {
      return;
    }
    final input = PlannedWorkoutInput(
      title: _title.text,
      workoutType: _type,
      scheduledLocalDate: _date.text.trim(),
      plannedDurationMinutes: int.tryParse(_duration.text.trim()),
      exercises: [
        for (final exercise in _exercises)
          PlannedExerciseInput(
            title: exercise.title.text,
            sets: int.tryParse(exercise.sets.text.trim()) ?? 0,
            repetitions: exercise.isDuration
                ? 0
                : int.tryParse(exercise.reps.text.trim()) ?? 0,
            durationSeconds: exercise.isDuration
                ? int.tryParse(exercise.reps.text.trim()) ?? 0
                : null,
            weightKg: double.tryParse(exercise.weight.text.trim()),
            exerciseCode: exercise.exerciseCode,
            instructions: exercise.exerciseCode == null
                ? exercise.instructions.text
                : null,
          ),
      ],
    );
    final controller = ref.read(planControllerProvider.notifier);
    if (widget.replaceInstanceId != null) {
      await controller.replaceWorkout(widget.replaceInstanceId!, input);
    } else {
      await controller.addWorkout(widget.planId!, input);
    }
    if (mounted && ref.read(planControllerProvider) is PlanSaved) {
      Navigator.of(context).pop();
    }
  }
}
