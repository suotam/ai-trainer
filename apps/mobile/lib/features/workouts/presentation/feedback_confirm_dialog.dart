import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/workout_feedback.dart';

/// Bezpečný potvrzovací dialog dokončení workoutu se **volitelným** feedbackem
/// (VSP §18, screen-spec §3.9/§40). Sbírá subjektivní náročnost (RPE 0–10),
/// pocit, flag bolesti a volitelnou poznámku — vše lze přeskočit. Dialog sám
/// data nemění; vrací `WorkoutFeedbackInput` až po potvrzení (nebo `null` při
/// zrušení). Zápis provede až volající po potvrzení.
class FeedbackConfirmDialog extends StatefulWidget {
  const FeedbackConfirmDialog({
    required this.completedSets,
    required this.totalSets,
    super.key,
  });

  final int completedSets;
  final int totalSets;

  static const Key dialogKey = Key('feedback_confirm_dialog');
  static const Key cancelKey = Key('feedback_cancel');
  static const Key confirmKey = Key('feedback_confirm');
  static const Key painSwitchKey = Key('feedback_pain_switch');
  static const Key painWarningKey = Key('feedback_pain_warning');
  static const Key notesFieldKey = Key('feedback_notes');

  static Key effortChipKey(int value) => Key('feedback_effort_$value');
  static Key feelingChipKey(String code) => Key('feedback_feeling_$code');

  /// Otevře dialog a vrátí potvrzený feedback (může být „prázdný"), nebo
  /// `null`, pokud uživatel dokončení zrušil.
  static Future<WorkoutFeedbackInput?> show(
    BuildContext context, {
    required int completedSets,
    required int totalSets,
  }) {
    return showDialog<WorkoutFeedbackInput>(
      context: context,
      builder: (_) => FeedbackConfirmDialog(
        completedSets: completedSets,
        totalSets: totalSets,
      ),
    );
  }

  @override
  State<FeedbackConfirmDialog> createState() => _FeedbackConfirmDialogState();
}

class _FeedbackConfirmDialogState extends State<FeedbackConfirmDialog> {
  int? _effort;
  WorkoutFeeling? _feeling;
  bool _pain = false;
  final TextEditingController _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  String _feelingLabel(AppLocalizations l10n, WorkoutFeeling feeling) =>
      switch (feeling) {
        WorkoutFeeling.great => l10n.feelingGreat,
        WorkoutFeeling.good => l10n.feelingGood,
        WorkoutFeeling.okay => l10n.feelingOkay,
        WorkoutFeeling.tired => l10n.feelingTired,
        WorkoutFeeling.rough => l10n.feelingRough,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      key: FeedbackConfirmDialog.dialogKey,
      title: Text(l10n.completeWorkoutDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.completeWorkoutDialogMessage(
                widget.completedSets,
                widget.totalSets,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.feedbackOptionalHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),

            // Subjektivní náročnost (RPE 0–10), volitelné.
            Text(l10n.feedbackEffortLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (var value = 0; value <= 10; value++)
                  Semantics(
                    label: l10n.feedbackEffortValue(value),
                    selected: _effort == value,
                    button: true,
                    child: ChoiceChip(
                      key: FeedbackConfirmDialog.effortChipKey(value),
                      label: Text('$value'),
                      selected: _effort == value,
                      onSelected: (selected) =>
                          setState(() => _effort = selected ? value : null),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Pocit po workoutu, volitelné.
            Text(l10n.feedbackFeelingLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (final feeling in WorkoutFeeling.values)
                  ChoiceChip(
                    key: FeedbackConfirmDialog.feelingChipKey(feeling.code),
                    label: Text(_feelingLabel(l10n, feeling)),
                    selected: _feeling == feeling,
                    onSelected: (selected) =>
                        setState(() => _feeling = selected ? feeling : null),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Flag bolesti (jen flag v R1) + konzervativní bezpečné upozornění.
            SwitchListTile(
              key: FeedbackConfirmDialog.painSwitchKey,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.feedbackPainLabel),
              value: _pain,
              onChanged: (value) => setState(() => _pain = value),
            ),
            if (_pain)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.feedbackPainWarning,
                  key: FeedbackConfirmDialog.painWarningKey,
                  style: theme.textTheme.bodySmall,
                ),
              ),

            // Volitelná poznámka.
            TextField(
              key: FeedbackConfirmDialog.notesFieldKey,
              controller: _notes,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.feedbackNotesLabel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: FeedbackConfirmDialog.cancelKey,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: FeedbackConfirmDialog.confirmKey,
          onPressed: () => Navigator.of(context).pop(
            WorkoutFeedbackInput(
              overallEffort: _effort?.toDouble(),
              feeling: _feeling,
              painReported: _pain,
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            ),
          ),
          child: Text(l10n.completeWorkoutConfirmSave),
        ),
      ],
    );
  }
}
