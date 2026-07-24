import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/r1_seed_repository.dart';
import 'workout_providers.dart';

/// Application-level bootstrap lokálních workout dat (VSP §12).
///
/// Jediné vlastnící místo, kde se spouští idempotentní seed. Widgety ani
/// read providery nesmí seed volat přímo — čekají na
/// [workoutBootstrapProvider]. Bootstrap je bez závislosti na backendu.
class WorkoutBootstrap {
  const WorkoutBootstrap(this._seed);

  final R1SeedRepository _seed;

  /// Připraví lokální data do validního stavu. Idempotentní (PDR-010):
  /// opakované volání existující data nemění.
  Future<void> ensureReady() async {
    await _seed.applySeed();
  }
}

final workoutBootstrapProvider = Provider<WorkoutBootstrap>(
  (ref) => WorkoutBootstrap(ref.watch(r1SeedRepositoryProvider)),
);

/// Dokončení bootstrapu jako `AsyncValue`. Read providery na něj čekají,
/// takže Today read model se nezobrazí dřív, než je seed validní. Selhání
/// vede do error stavu s explicitním retry (invalidace) — automatický
/// retry Riverpodu je vypnutý, žádný nekonečný loop.
final workoutBootstrapCompletedProvider = FutureProvider<void>(
  (ref) => ref.watch(workoutBootstrapProvider).ensureReady(),
  retry: (retryCount, error) => null,
);
