import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/workout_read_model.dart';
import 'workout_bootstrap.dart';
import 'workout_providers.dart';

/// Detail jedné instance podle stabilního ID (read-only, VSP §13).
///
/// `null` znamená, že workout neexistuje (bezpečný not-found stav) — není
/// to chyba. Vyhozená výjimka je error stav. Bez sítě a backendu.
final workoutDetailProvider =
    FutureProvider.family<WorkoutInstanceDetail?, String>((
      ref,
      workoutId,
    ) async {
      await ref.watch(workoutBootstrapCompletedProvider.future);
      final trimmedId = workoutId.trim();
      if (trimmedId.isEmpty) {
        return null;
      }
      final repository = ref.watch(workoutInstanceRepositoryProvider);
      return repository.workoutInstanceById(trimmedId);
    }, retry: (retryCount, error) => null);

/// Explicitní retry detailu z UI (invaliduje i bootstrap).
void refreshWorkoutDetail(WidgetRef ref, String workoutId) {
  ref.invalidate(workoutBootstrapCompletedProvider);
  ref.invalidate(workoutDetailProvider(workoutId));
}
