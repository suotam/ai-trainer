import '../../../core/database/app_database.dart';
import '../domain/reminder_plan.dart';

const String _checkInKey = 'reminder_checkin_enabled';
const String _workoutKey = 'reminder_workout_enabled';

/// Persistence opt-in přepínačů v lokálním app state (C40 §2, NTF-008)
/// — vlastnost zařízení, ne účtu; nesynchronizuje se.
class AppStateReminderSettingsRepository implements ReminderSettingsRepository {
  AppStateReminderSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<ReminderSettings> load() async {
    Future<bool> flag(String key) async =>
        (await (_db.select(
          _db.localAppState,
        )..where((t) => t.key.equals(key))).getSingleOrNull())?.value ==
        '1';
    return ReminderSettings(
      checkInEnabled: await flag(_checkInKey),
      workoutEnabled: await flag(_workoutKey),
    );
  }

  @override
  Future<void> save(ReminderSettings settings) async {
    Future<void> write(String key, bool enabled) => _db
        .into(_db.localAppState)
        .insertOnConflictUpdate(
          LocalAppStateCompanion.insert(
            key: key,
            value: enabled ? '1' : '0',
            updatedAt: 0,
          ),
        );
    await write(_checkInKey, settings.checkInEnabled);
    await write(_workoutKey, settings.workoutEnabled);
  }
}

/// P0 no-op hranice platformy (NTF-007): plán se přijme a zahodí;
/// registrace pluginu + doručení = dokumentovaný platformní dluh.
class NoopNotificationGate implements NotificationGate {
  const NoopNotificationGate();

  @override
  Future<void> applyPlan(List<PlannedReminder> plan) async {}
}
