import '../../../l10n/generated/app_localizations.dart';

/// Bezpečný lokalizovaný popis plánované délky v celých minutách, nebo
/// `null`, pokud read model délku nemá.
String? formatDurationLabel(AppLocalizations l10n, int? plannedSeconds) {
  if (plannedSeconds == null || plannedSeconds <= 0) {
    return null;
  }
  final minutes = (plannedSeconds / 60).round();
  return l10n.workoutDurationMinutes(minutes);
}
