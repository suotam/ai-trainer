import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../checkin/application/checkin_providers.dart';
import '../../workouts/application/today_providers.dart';
import '../../workouts/domain/workout_read_model.dart';
import '../data/app_state_reminder_boundaries.dart';
import '../domain/reminder_plan.dart';

/// Composition lokálních připomínek (R5-07, C40). Platforma výhradně za
/// portem (NTF-006); P0 gate je no-op hranice (NTF-007).
final reminderSettingsRepositoryProvider = Provider<ReminderSettingsRepository>(
  (ref) => AppStateReminderSettingsRepository(ref.watch(appDatabaseProvider)),
);

final notificationGateProvider = Provider<NotificationGate>(
  (ref) => const NoopNotificationGate(),
);

final reminderSettingsProvider = FutureProvider<ReminderSettings>(
  (ref) => ref.watch(reminderSettingsRepositoryProvider).load(),
  retry: (retryCount, error) => null,
);

/// Deterministický denní plán (NTF-003/004) — přepočet při změně
/// nastavení a otevření aplikace (NTF-012).
final todayReminderPlanProvider = FutureProvider<List<PlannedReminder>>((
  ref,
) async {
  final settings = await ref.watch(reminderSettingsProvider.future);
  final checkIn = await ref.watch(todayCheckInProvider.future);
  final todayWorkouts = await ref.watch(todayWorkoutsProvider.future);
  return computeDailyReminderPlan(
    settings: settings,
    hasCheckInToday: checkIn != null,
    pendingWorkoutsToday: todayWorkouts
        .where((w) => w.status == WorkoutInstanceStatus.ready)
        .length,
  );
}, retry: (retryCount, error) => null);

/// Controller přepínačů: uložit → přepočítat → aplikovat přes port.
/// Selhání gate je tiché a bezpečné (NTF-010).
class ReminderSettingsController extends Notifier<void> {
  @override
  void build() {}

  Future<void> setCheckInEnabled(bool enabled) async {
    final current = await ref.read(reminderSettingsRepositoryProvider).load();
    await _apply(
      ReminderSettings(
        checkInEnabled: enabled,
        workoutEnabled: current.workoutEnabled,
      ),
    );
  }

  Future<void> setWorkoutEnabled(bool enabled) async {
    final current = await ref.read(reminderSettingsRepositoryProvider).load();
    await _apply(
      ReminderSettings(
        checkInEnabled: current.checkInEnabled,
        workoutEnabled: enabled,
      ),
    );
  }

  Future<void> _apply(ReminderSettings settings) async {
    await ref.read(reminderSettingsRepositoryProvider).save(settings);
    ref.invalidate(reminderSettingsProvider);
    try {
      final plan = await ref.read(todayReminderPlanProvider.future);
      await ref.read(notificationGateProvider).applyPlan(plan);
    } catch (_) {
      // NTF-010: platforma nikdy neshodí aplikaci.
    }
  }
}

final reminderSettingsControllerProvider =
    NotifierProvider<ReminderSettingsController, void>(
      ReminderSettingsController.new,
    );
