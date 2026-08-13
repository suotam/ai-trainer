import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../data/drift_user_sport_repository.dart';
import '../domain/user_sport.dart';
import '../domain/user_sport_repository.dart';

/// Composition sportovního profilu (R3-01, C17). Presentation čte jen tyto
/// providery — nikdy Drift typy (PDR-008).
final userSportRepositoryProvider = Provider<UserSportRepository>(
  (ref) => DriftUserSportRepository(ref.watch(appDatabaseProvider)),
);

/// Sporty aktuálního vlastníka v deterministickém pořadí (ASP-014).
final userSportsProvider = FutureProvider<List<UserSport>>(
  (ref) => ref.watch(userSportRepositoryProvider).sportsForCurrentOwner(),
  retry: (retryCount, error) => null,
);

/// UI stav zápisu sportovního profilu.
sealed class SportsProfileSaveState {
  const SportsProfileSaveState();
}

class SportsProfileIdle extends SportsProfileSaveState {
  const SportsProfileIdle();
}

class SportsProfileSaving extends SportsProfileSaveState {
  const SportsProfileSaving();
}

class SportsProfileSaved extends SportsProfileSaveState {
  const SportsProfileSaved();
}

class SportsProfileFailure extends SportsProfileSaveState {
  const SportsProfileFailure(this.result);
  final SaveUserSportResult result;
}

/// Controller zápisů profilu: double-submit guard, typované chyby, po
/// úspěchu invalidace read modelu. Žádný automatický retry.
class SportsProfileController extends Notifier<SportsProfileSaveState> {
  bool _inFlight = false;

  @override
  SportsProfileSaveState build() => const SportsProfileIdle();

  Future<void> save(UserSportInput input, {String? existingId}) => _run(
    () => ref
        .read(userSportRepositoryProvider)
        .saveSport(
          input,
          existingId: existingId,
          newId: ref.read(idGeneratorProvider).newId(),
          now: ref.read(clockProvider)(),
        ),
  );

  Future<void> changeStatus(String id, String newStatus) => _run(
    () => ref
        .read(userSportRepositoryProvider)
        .changeStatus(id, newStatus, now: ref.read(clockProvider)()),
  );

  Future<void> _run(Future<SaveUserSportResult> Function() action) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const SportsProfileSaving();
    try {
      final result = await action();
      switch (result) {
        case UserSportSaved():
          ref.invalidate(userSportsProvider);
          state = const SportsProfileSaved();
        default:
          state = SportsProfileFailure(result);
      }
    } catch (_) {
      // Raw persistence výjimka se nepropaguje do UI.
      state = const SportsProfileFailure(UserSportValidationFailed());
    } finally {
      _inFlight = false;
    }
  }
}

final sportsProfileControllerProvider =
    NotifierProvider<SportsProfileController, SportsProfileSaveState>(
      SportsProfileController.new,
    );
