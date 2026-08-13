import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/plan_providers.dart';
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
                for (final workout in items)
                  ListTile(
                    key: Key('plan_workout_${workout.instanceId}'),
                    title: Text(workout.title),
                    subtitle: Text(
                      l10n.planWorkoutSubtitle(
                        workout.scheduledLocalDate,
                        l10n.manualWorkoutTypeLabel(workout.workoutType),
                        workout.exerciseCount,
                      ),
                    ),
                  ),
                const SizedBox(height: 88),
              ],
            ),
    );
  }
}

/// Formulář ručního workoutu (C20 §5.1) — title, typ, datum, délka a
/// dynamický seznam cviků (série × opakování × volitelná váha).
class _WorkoutForm extends ConsumerStatefulWidget {
  const _WorkoutForm({required this.planId});

  final String planId;

  @override
  ConsumerState<_WorkoutForm> createState() => _WorkoutFormState();
}

class _ExerciseDraft {
  _ExerciseDraft()
    : title = TextEditingController(),
      sets = TextEditingController(text: '3'),
      reps = TextEditingController(text: '10'),
      weight = TextEditingController();

  final TextEditingController title;
  final TextEditingController sets;
  final TextEditingController reps;
  final TextEditingController weight;

  void dispose() {
    title.dispose();
    sets.dispose();
    reps.dispose();
    weight.dispose();
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
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      key: Key('exercise_name_$i'),
                      controller: _exercises[i].title,
                      decoration: InputDecoration(
                        labelText: l10n.planExerciseName,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _exercises[i].sets,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.planExerciseSets,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _exercises[i].reps,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.planExerciseReps,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _exercises[i].weight,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.planExerciseWeight,
                      ),
                    ),
                  ),
                ],
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

  Future<void> _save() async {
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
            repetitions: int.tryParse(exercise.reps.text.trim()) ?? 0,
            weightKg: double.tryParse(exercise.weight.text.trim()),
          ),
      ],
    );
    await ref
        .read(planControllerProvider.notifier)
        .addWorkout(widget.planId, input);
    if (mounted && ref.read(planControllerProvider) is PlanSaved) {
      Navigator.of(context).pop();
    }
  }
}
