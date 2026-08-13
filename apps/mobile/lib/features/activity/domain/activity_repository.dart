import 'manual_activity.dart';

/// Port ručních aktivit a statistik (R3-06, C22/C23). Offline-first.
abstract interface class ActivityRepository {
  /// Aktivity aktuálního vlastníka, datum sestupně, pak title (MAC-010).
  Future<List<ManualActivity>> activitiesForCurrentOwner();

  /// Vytvoří (`existingId == null`) nebo upraví current-state (MAC-005).
  Future<ActivityWriteResult> saveActivity(
    ManualActivityInput input, {
    String? existingId,
    required String newId,
    required DateTime now,
  });

  /// Deterministické statistiky za období (C23 §3) — čtení bez vedlejších
  /// efektů (PST-013), device-local scope (PST-008).
  Future<ProgressStatistics> statisticsForPeriod({
    required String fromLocalDate,
    required String toLocalDate,
  });
}
