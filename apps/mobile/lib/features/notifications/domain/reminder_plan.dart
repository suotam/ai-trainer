import 'package:flutter/foundation.dart';

/// Typy P0 připomínek (C40 §2).
enum ReminderType {
  checkIn('CHECK_IN', '08:00'),
  workout('WORKOUT', '17:00');

  const ReminderType(this.code, this.defaultTime);

  final String code;

  /// Fixní P0 čas (NTF-011); vlastní časy = budoucí revize kontraktu.
  final String defaultTime;
}

/// Opt-in nastavení připomínek — default vypnuto (NTF-002).
@immutable
class ReminderSettings {
  const ReminderSettings({
    this.checkInEnabled = false,
    this.workoutEnabled = false,
  });

  final bool checkInEnabled;
  final bool workoutEnabled;
}

/// Naplánovaná připomínka: navigační pobídka, nikdy akce (NTF-001).
@immutable
class PlannedReminder {
  const PlannedReminder({required this.type, required this.localTime});

  final ReminderType type;
  final String localTime;
}

/// Deterministický denní reminder plán (C40 §2, NTF-003/004): opt-in +
/// relevance — check-in připomínka jen bez dnešního check-inu, workout
/// připomínka jen s dnešním neproběhlým workoutem.
List<PlannedReminder> computeDailyReminderPlan({
  required ReminderSettings settings,
  required bool hasCheckInToday,
  required int pendingWorkoutsToday,
}) => List.unmodifiable([
  if (settings.checkInEnabled && !hasCheckInToday)
    PlannedReminder(
      type: ReminderType.checkIn,
      localTime: ReminderType.checkIn.defaultTime,
    ),
  if (settings.workoutEnabled && pendingWorkoutsToday > 0)
    PlannedReminder(
      type: ReminderType.workout,
      localTime: ReminderType.workout.defaultTime,
    ),
]);

/// Port nastavení připomínek (device-local, NTF-008).
abstract interface class ReminderSettingsRepository {
  Future<ReminderSettings> load();
  Future<void> save(ReminderSettings settings);
}

/// Jediná cesta k platformě (NTF-006). P0 implementace je vědomě no-op
/// hranice — adapter, permission flow a on-device doručení jsou přiznaný
/// platformní dluh (NTF-007); selhání je tiché a bezpečné (NTF-010).
abstract interface class NotificationGate {
  Future<void> applyPlan(List<PlannedReminder> plan);
}
