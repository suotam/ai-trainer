import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../data/drift_availability_profile_repository.dart';
import '../domain/availability_profile.dart';
import '../domain/availability_profile_repository.dart';

/// Composition dostupnosti a kontextu (R3-03, C19). Presentation čte jen
/// tyto providery — nikdy Drift typy (PDR-008).
final availabilityProfileRepositoryProvider =
    Provider<AvailabilityProfileRepository>(
      (ref) =>
          DriftAvailabilityProfileRepository(ref.watch(appDatabaseProvider)),
    );

final availabilityWeekProvider = FutureProvider<List<AvailabilityRule>>(
  (ref) =>
      ref.watch(availabilityProfileRepositoryProvider).weekForCurrentOwner(),
  retry: (retryCount, error) => null,
);

final equipmentProvider = FutureProvider<List<EquipmentItem>>(
  (ref) => ref
      .watch(availabilityProfileRepositoryProvider)
      .equipmentForCurrentOwner(),
  retry: (retryCount, error) => null,
);

final constraintsProvider = FutureProvider<List<BasicConstraint>>(
  (ref) => ref
      .watch(availabilityProfileRepositoryProvider)
      .constraintsForCurrentOwner(),
  retry: (retryCount, error) => null,
);

/// UI stav zápisu dostupnostního profilu.
sealed class AvailabilitySaveState {
  const AvailabilitySaveState();
}

class AvailabilityIdle extends AvailabilitySaveState {
  const AvailabilityIdle();
}

class AvailabilitySaving extends AvailabilitySaveState {
  const AvailabilitySaving();
}

class AvailabilitySaved extends AvailabilitySaveState {
  const AvailabilitySaved();
}

class AvailabilityFailure extends AvailabilitySaveState {
  const AvailabilityFailure(this.result);
  final AvailabilityWriteResult result;
}

/// Controller zápisů: double-submit guard, typované chyby, po úspěchu
/// invalidace dotčeného read modelu. Žádný automatický retry.
class AvailabilityController extends Notifier<AvailabilitySaveState> {
  bool _inFlight = false;

  @override
  AvailabilitySaveState build() => const AvailabilityIdle();

  Future<void> upsertDay({
    required String dayOfWeek,
    required String level,
    int? budgetMinutes,
    String? preferredPartOfDay,
    String? note,
  }) => _run(
    () => ref
        .read(availabilityProfileRepositoryProvider)
        .upsertDay(
          dayOfWeek: dayOfWeek,
          level: level,
          budgetMinutes: budgetMinutes,
          preferredPartOfDay: preferredPartOfDay,
          note: note,
          newId: ref.read(idGeneratorProvider).newId(),
          now: ref.read(clockProvider)(),
        ),
    () => ref.invalidate(availabilityWeekProvider),
  );

  Future<void> removeDay(String dayOfWeek) => _run(
    () => ref.read(availabilityProfileRepositoryProvider).removeDay(dayOfWeek),
    () => ref.invalidate(availabilityWeekProvider),
  );

  Future<void> addEquipment({
    String? equipmentCode,
    String? customName,
    String? note,
  }) => _run(
    () => ref
        .read(availabilityProfileRepositoryProvider)
        .addEquipment(
          equipmentCode: equipmentCode,
          customName: customName,
          note: note,
          newId: ref.read(idGeneratorProvider).newId(),
          now: ref.read(clockProvider)(),
        ),
    () => ref.invalidate(equipmentProvider),
  );

  Future<void> setEquipmentStatus(String id, String status) => _run(
    () => ref
        .read(availabilityProfileRepositoryProvider)
        .setEquipmentStatus(id, status, now: ref.read(clockProvider)()),
    () => ref.invalidate(equipmentProvider),
  );

  Future<void> addConstraint({required String title, String? note}) => _run(
    () => ref
        .read(availabilityProfileRepositoryProvider)
        .addConstraint(
          title: title,
          note: note,
          newId: ref.read(idGeneratorProvider).newId(),
          now: ref.read(clockProvider)(),
        ),
    () => ref.invalidate(constraintsProvider),
  );

  Future<void> setConstraintStatus(String id, String status) => _run(
    () => ref
        .read(availabilityProfileRepositoryProvider)
        .setConstraintStatus(id, status, now: ref.read(clockProvider)()),
    () => ref.invalidate(constraintsProvider),
  );

  Future<void> _run(
    Future<AvailabilityWriteResult> Function() action,
    void Function() invalidate,
  ) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const AvailabilitySaving();
    try {
      final result = await action();
      switch (result) {
        case AvailabilityWriteSaved():
          invalidate();
          state = const AvailabilitySaved();
        default:
          state = AvailabilityFailure(result);
      }
    } catch (_) {
      // Raw persistence výjimka se nepropaguje do UI.
      state = const AvailabilityFailure(AvailabilityWriteValidationFailed());
    } finally {
      _inFlight = false;
    }
  }
}

final availabilityControllerProvider =
    NotifierProvider<AvailabilityController, AvailabilitySaveState>(
      AvailabilityController.new,
    );
