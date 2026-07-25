import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/session_tracker_providers.dart';
import '../domain/session_tracker.dart';

/// Tracker aktivní session (R1-04): cviky se sety, plánované vs. skutečné
/// hodnoty, zápis a completion. UI nesahá na SQL/Drift — čte jen providery.
class SessionTrackerView extends ConsumerWidget {
  const SessionTrackerView({required this.sessionId, super.key});

  final String sessionId;

  static const Key trackerKey = Key('session_tracker');
  static const Key loadingKey = Key('session_tracker_loading');
  static const Key errorKey = Key('session_tracker_error');
  static const Key emptyKey = Key('session_tracker_empty');

  static Key setRowKey(String id) => Key('tracker_set_$id');
  static Key repsFieldKey(String id) => Key('tracker_reps_$id');
  static Key weightFieldKey(String id) => Key('tracker_weight_$id');
  static Key saveButtonKey(String id) => Key('tracker_save_$id');
  static Key doneToggleKey(String id) => Key('tracker_done_$id');
  static Key savingKey(String id) => Key('tracker_saving_$id');
  static Key savedKey(String id) => Key('tracker_saved_$id');
  static Key saveErrorKey(String id) => Key('tracker_save_error_$id');
  static Key validationErrorKey(String id) => Key('tracker_validation_$id');
  static Key completedMarkKey(String id) => Key('tracker_completed_$id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tracker = ref.watch(sessionTrackerProvider(sessionId));

    return tracker.when(
      loading: () => const Padding(
        key: loadingKey,
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Padding(
        key: errorKey,
        padding: const EdgeInsets.all(16),
        child: Text(l10n.activeSessionError),
      ),
      data: (data) {
        final exercises = data?.exercises ?? const [];
        if (exercises.isEmpty) {
          return Padding(
            key: emptyKey,
            padding: const EdgeInsets.all(16),
            child: Text(l10n.trackerNoExercises),
          );
        }
        return Column(
          key: trackerKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final exercise in exercises)
              _ExerciseBlock(sessionId: sessionId, exercise: exercise),
          ],
        );
      },
    );
  }
}

class _ExerciseBlock extends StatelessWidget {
  const _ExerciseBlock({required this.sessionId, required this.exercise});

  final String sessionId;
  final TrackerExercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final set in exercise.sets)
            _SetRow(
              key: SessionTrackerView.setRowKey(set.setPerformanceId),
              sessionId: sessionId,
              set: set,
            ),
        ],
      ),
    );
  }
}

class _SetRow extends ConsumerStatefulWidget {
  const _SetRow({required this.sessionId, required this.set, super.key});

  final String sessionId;
  final TrackerSet set;

  @override
  ConsumerState<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends ConsumerState<_SetRow> {
  late final TextEditingController _reps;
  late final TextEditingController _weight;

  @override
  void initState() {
    super.initState();
    // Seed z uložených skutečných hodnot (recovery po restartu/reload).
    _reps = TextEditingController(
      text: widget.set.actualRepetitions?.toString() ?? '',
    );
    _weight = TextEditingController(
      text: _formatWeight(widget.set.actualWeightKg),
    );
  }

  @override
  void dispose() {
    _reps.dispose();
    _weight.dispose();
    super.dispose();
  }

  static String _formatWeight(double? value) {
    if (value == null) {
      return '';
    }
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final set = widget.set;
    final id = set.setPerformanceId;
    final saveState = ref.watch(trackerControllerProvider);
    final isSaving =
        saveState is TrackerSaving && saveState.setPerformanceId == id;

    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.trackerSetLabel(set.position + 1)} · '
                  '${l10n.trackerPlannedSet(_planned(set.plannedRepetitions), _planned(set.plannedWeightKg))}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (set.isCompleted)
                Icon(
                  key: SessionTrackerView.completedMarkKey(id),
                  Icons.check_circle,
                  semanticLabel: l10n.trackerCompleted,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  key: SessionTrackerView.repsFieldKey(id),
                  controller: _reps,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                  ],
                  decoration: InputDecoration(labelText: l10n.trackerRepsLabel),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: SessionTrackerView.weightFieldKey(id),
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.trackerWeightLabel,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              OutlinedButton(
                key: SessionTrackerView.saveButtonKey(id),
                onPressed: isSaving ? null : _onSave,
                child: isSaving
                    ? Text(
                        l10n.trackerSaving,
                        key: SessionTrackerView.savingKey(id),
                      )
                    : Text(l10n.trackerSave),
              ),
              const SizedBox(width: 8),
              FilterChip(
                key: SessionTrackerView.doneToggleKey(id),
                label: Text(l10n.trackerMarkDone),
                selected: set.isCompleted,
                onSelected: isSaving
                    ? null
                    : (value) => ref
                          .read(trackerControllerProvider.notifier)
                          .toggleCompleted(
                            sessionId: widget.sessionId,
                            setPerformanceId: id,
                            completed: value,
                          ),
              ),
            ],
          ),
          _statusLine(l10n, saveState, id),
        ],
      ),
    );
  }

  Widget _statusLine(AppLocalizations l10n, TrackerSaveState state, String id) {
    if (state is TrackerSaved && state.setPerformanceId == id) {
      return Text(l10n.trackerSaved, key: SessionTrackerView.savedKey(id));
    }
    if (state is TrackerValidationError && state.setPerformanceId == id) {
      return Text(
        l10n.trackerValidationError,
        key: SessionTrackerView.validationErrorKey(id),
      );
    }
    if (state is TrackerError && state.setPerformanceId == id) {
      return Text(
        l10n.trackerSaveError,
        key: SessionTrackerView.saveErrorKey(id),
      );
    }
    return const SizedBox.shrink();
  }

  void _onSave() {
    ref
        .read(trackerControllerProvider.notifier)
        .saveActuals(
          sessionId: widget.sessionId,
          setPerformanceId: widget.set.setPerformanceId,
          actualRepetitions: _reps.text.trim().isEmpty
              ? null
              : int.tryParse(_reps.text.trim()),
          actualWeightKg: _weight.text.trim().isEmpty
              ? null
              : double.tryParse(_weight.text.trim()),
        );
  }

  static String _planned(Object? value) => value?.toString() ?? '–';
}
