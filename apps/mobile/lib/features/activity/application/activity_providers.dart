import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../data/drift_activity_repository.dart';
import '../domain/activity_repository.dart';
import '../domain/manual_activity.dart';

/// Composition ručních aktivit a statistik (R3-06, C22/C23).
final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => DriftActivityRepository(ref.watch(appDatabaseProvider)),
);

final manualActivitiesProvider = FutureProvider<List<ManualActivity>>(
  (ref) => ref.watch(activityRepositoryProvider).activitiesForCurrentOwner(),
  retry: (retryCount, error) => null,
);

/// Statistiky posledních N dní vč. dneška (C23 §5, PST-012 — clock
/// injektovaný).
final progressStatisticsProvider =
    FutureProvider.family<ProgressStatistics, int>((ref, days) {
      final now = ref.watch(clockProvider)();
      final from = now.subtract(Duration(days: days - 1));
      return ref
          .watch(activityRepositoryProvider)
          .statisticsForPeriod(
            fromLocalDate: formatLocalDate(from),
            toLocalDate: formatLocalDate(now),
          );
    }, retry: (retryCount, error) => null);

/// UI stav zápisu aktivity.
sealed class ActivitySaveState {
  const ActivitySaveState();
}

class ActivityIdle extends ActivitySaveState {
  const ActivityIdle();
}

class ActivitySaving extends ActivitySaveState {
  const ActivitySaving();
}

class ActivitySaved extends ActivitySaveState {
  const ActivitySaved();
}

class ActivityFailure extends ActivitySaveState {
  const ActivityFailure(this.result);
  final ActivityWriteResult result;
}

/// Controller zápisů aktivit: double-submit guard, typované chyby, po
/// úspěchu invalidace read modelů (vč. statistik). Žádný automatický retry.
class ActivityController extends Notifier<ActivitySaveState> {
  bool _inFlight = false;

  @override
  ActivitySaveState build() => const ActivityIdle();

  Future<void> save(ManualActivityInput input, {String? existingId}) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const ActivitySaving();
    try {
      final result = await ref
          .read(activityRepositoryProvider)
          .saveActivity(
            input,
            existingId: existingId,
            newId: ref.read(idGeneratorProvider).newId(),
            now: ref.read(clockProvider)(),
          );
      switch (result) {
        case ActivityWriteSaved():
          ref
            ..invalidate(manualActivitiesProvider)
            ..invalidate(progressStatisticsProvider);
          state = const ActivitySaved();
        default:
          state = ActivityFailure(result);
      }
    } catch (_) {
      // Raw persistence výjimka se nepropaguje do UI.
      state = const ActivityFailure(ActivityWriteValidationFailed());
    } finally {
      _inFlight = false;
    }
  }
}

final activityControllerProvider =
    NotifierProvider<ActivityController, ActivitySaveState>(
      ActivityController.new,
    );
