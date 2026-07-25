import '../domain/record_performance_result.dart';
import '../domain/workout_performance_repository.dart';

/// Use case zápisu skutečných hodnot setu (R1-04, fyzický model §15.2).
///
/// Bez Flutter/backend závislosti. Validuje vstup (nezáporné hodnoty) před
/// zápisem; ostatní kontroly (aktivní session, existence setu) provádí
/// repository v transakci. Vrací typovaný výsledek, nikdy raw výjimku.
class RecordSetPerformance {
  const RecordSetPerformance({required this.repository, required this.clock});

  final WorkoutPerformanceRepository repository;
  final DateTime Function() clock;

  Future<RecordPerformanceResult> call({
    required String setPerformanceId,
    required int? actualRepetitions,
    required double? actualWeightKg,
  }) async {
    if (actualRepetitions != null && actualRepetitions < 0) {
      return const PerformanceValidationFailure(
        PerformanceValidationReason.negativeReps,
      );
    }
    if (actualWeightKg != null && actualWeightKg < 0) {
      return const PerformanceValidationFailure(
        PerformanceValidationReason.negativeWeight,
      );
    }
    return repository.recordSetActuals(
      setPerformanceId: setPerformanceId,
      actualRepetitions: actualRepetitions,
      actualWeightKg: actualWeightKg,
      now: clock(),
    );
  }
}
