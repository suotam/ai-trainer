/// Feedback po dokončení workoutu (VSP §18, fyzický model §12). V R1 je
/// feedback volitelný a minimalistický (workout-model §40.3): subjektivní
/// náročnost (RPE 0–10), pocit, flag bolesti a volitelná poznámka. Neobsahuje
/// Drift typy (PDR-008).
library;

/// Stabilní kód pocitu po workoutu. Fyzický model §12 vyžaduje „stabilní kód
/// pocitu" (TEXT), ale nedefinuje množinu — tato sada je kanonická pro R1.
enum WorkoutFeeling {
  great('GREAT'),
  good('GOOD'),
  okay('OKAY'),
  tired('TIRED'),
  rough('ROUGH');

  const WorkoutFeeling(this.code);
  final String code;

  static WorkoutFeeling? fromCode(String? code) {
    if (code == null) {
      return null;
    }
    for (final f in WorkoutFeeling.values) {
      if (f.code == code) {
        return f;
      }
    }
    return null;
  }
}

/// Vstup feedbacku z UI. Všechny hodnocené položky jsou volitelné (feedback
/// lze přeskočit); `painReported` je pouze flag v R1 (§12, řádek 329) —
/// aplikace při něm jen bezpečně upozorní, žádná diagnostika ani AI.
class WorkoutFeedbackInput {
  const WorkoutFeedbackInput({
    this.overallEffort,
    this.feeling,
    this.painReported = false,
    this.notes,
  });

  /// RPE 0–10.
  final double? overallEffort;
  final WorkoutFeeling? feeling;
  final bool painReported;
  final String? notes;

  /// Zda uživatel skutečně něco vyplnil — prázdný feedback se neukládá.
  bool get hasContent =>
      overallEffort != null ||
      feeling != null ||
      painReported ||
      (notes != null && notes!.trim().isNotEmpty);
}

/// Uložený feedback pro read-only zobrazení v historii (reload).
class WorkoutFeedbackSnapshot {
  const WorkoutFeedbackSnapshot({
    this.overallEffort,
    this.feeling,
    this.painReported = false,
    this.notes,
  });

  final double? overallEffort;
  final WorkoutFeeling? feeling;
  final bool painReported;
  final String? notes;
}
