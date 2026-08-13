import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../data/drift_daily_check_in_repository.dart';
import '../domain/daily_check_in.dart';
import '../domain/daily_check_in_repository.dart';

/// Composition denního check-inu (R5-01, C33). Presentation čte jen tyto
/// providery — nikdy Drift typy (PDR-008).
final dailyCheckInRepositoryProvider = Provider<DailyCheckInRepository>(
  (ref) => DriftDailyCheckInRepository(ref.watch(appDatabaseProvider)),
);

/// Dnešní check-in; null = validní stav bez check-inu (DCI-001).
final todayCheckInProvider = FutureProvider<DailyCheckIn?>(
  (ref) => ref
      .watch(dailyCheckInRepositoryProvider)
      .checkInForDate(ref.watch(todayLocalDateProvider)),
  retry: (retryCount, error) => null,
);

/// Historie check-inů (DCI-007).
final checkInHistoryProvider = FutureProvider<List<DailyCheckIn>>(
  (ref) => ref.watch(dailyCheckInRepositoryProvider).historyForCurrentOwner(),
  retry: (retryCount, error) => null,
);

/// UI stav zápisu check-inu.
sealed class CheckInSaveState {
  const CheckInSaveState();
}

class CheckInIdle extends CheckInSaveState {
  const CheckInIdle();
}

class CheckInSaving extends CheckInSaveState {
  const CheckInSaving();
}

class CheckInSavedState extends CheckInSaveState {
  const CheckInSavedState();
}

class CheckInFailure extends CheckInSaveState {
  const CheckInFailure();
}

/// Controller zápisu: double-submit guard, typované chyby, invalidace
/// read modelů. Žádný automatický retry.
class CheckInController extends Notifier<CheckInSaveState> {
  bool _inFlight = false;

  @override
  CheckInSaveState build() => const CheckInIdle();

  Future<void> saveToday(DailyCheckInInput input) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const CheckInSaving();
    try {
      final result = await ref
          .read(dailyCheckInRepositoryProvider)
          .saveForDate(
            ref.read(todayLocalDateProvider),
            input,
            newId: ref.read(idGeneratorProvider).newId(),
            now: ref.read(clockProvider)(),
          );
      switch (result) {
        case CheckInSaved():
          ref
            ..invalidate(todayCheckInProvider)
            ..invalidate(checkInHistoryProvider);
          state = const CheckInSavedState();
        case CheckInValidationFailed():
          state = const CheckInFailure();
      }
    } catch (_) {
      // Raw persistence výjimka se nepropaguje do UI.
      state = const CheckInFailure();
    } finally {
      _inFlight = false;
    }
  }
}

final checkInControllerProvider =
    NotifierProvider<CheckInController, CheckInSaveState>(
      CheckInController.new,
    );
