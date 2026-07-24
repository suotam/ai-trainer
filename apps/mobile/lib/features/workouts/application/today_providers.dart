import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../domain/workout_read_model.dart';
import 'workout_bootstrap.dart';
import 'workout_providers.dart';

/// Dnešní workouty pro Today obrazovku (read-only, VSP §13).
///
/// Nejprve počká na bootstrap (seed), poté načte dnešní lokální datum
/// z read modelu. Bez sítě a backendu. Automatický retry je vypnutý —
/// opakování je pouze explicitní z UI (invalidace).
final todayWorkoutsProvider = FutureProvider<List<WorkoutInstanceSummary>>((
  ref,
) async {
  await ref.watch(workoutBootstrapCompletedProvider.future);
  final localDate = ref.watch(todayLocalDateProvider);
  final repository = ref.watch(workoutInstanceRepositoryProvider);
  return repository.workoutsForLocalDate(localDate);
}, retry: (retryCount, error) => null);

/// Explicitní retry Today read flow z UI. Invaliduje i bootstrap, aby se
/// po jeho selhání seed skutečně zopakoval (jinak by zůstal cached error).
void refreshToday(WidgetRef ref) {
  ref.invalidate(workoutBootstrapCompletedProvider);
  ref.invalidate(todayWorkoutsProvider);
}
