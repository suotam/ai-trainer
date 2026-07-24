import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/drift_r1_seed_repository.dart';
import '../data/drift_workout_instance_repository.dart';
import '../domain/r1_seed_repository.dart';
import '../domain/workout_instance_repository.dart';

/// Composition workout read modelu (fyzický model §16). Presentation vrstva
/// R1-02 bude číst výhradně tyto providery — nikdy Drift typy (PDR-008).
final workoutInstanceRepositoryProvider = Provider<WorkoutInstanceRepository>(
  (ref) => DriftWorkoutInstanceRepository(ref.watch(appDatabaseProvider)),
);

final r1SeedRepositoryProvider = Provider<R1SeedRepository>(
  (ref) => DriftR1SeedRepository(ref.watch(appDatabaseProvider)),
);
