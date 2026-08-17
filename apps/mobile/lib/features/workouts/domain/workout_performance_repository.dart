import 'record_performance_result.dart';
import 'session_tracker.dart';

/// Boundary čtení a zápisu performance dat aktivní session (fyzický model
/// §10/§11/§15.2). Implementace patří do data vrstvy; všechny mutace jsou
/// atomické a nikdy nevrací raw persistence výjimku.
abstract interface class WorkoutPerformanceRepository {
  /// Idempotentně vytvoří výchozí StepPerformance/SetPerformance řádky pro
  /// aktivní session podle jejího stabilního snapshotu (fyzický model
  /// §15.1 krok 4, odloženo z R1-03). Nepřepíše existující zadané hodnoty.
  Future<void> initializePerformances({
    required String sessionId,
    required DateTime now,
  });

  /// Načte tracker read model, nebo `null` pokud session neexistuje.
  Future<SessionTracker?> loadTracker(String sessionId);

  /// Atomicky zapíše skutečné hodnoty setu. Ověří aktivní session a
  /// existenci setu; planned hodnoty nemění.
  Future<RecordPerformanceResult> recordSetActuals({
    required String setPerformanceId,
    required int? actualRepetitions,
    required double? actualWeightKg,
    required DateTime now,
    int? actualDurationSeconds,
  });

  /// Zahájení sady v průvodci (C53 §5): krok performance `IN_PROGRESS` +
  /// `started_at` (poprvé). Ověří aktivní session a existenci setu.
  Future<RecordPerformanceResult> startSet({
    required String setPerformanceId,
    required DateTime now,
  });

  /// Přeskočení kroku (C53 §5, GSP-008): step performance `SKIPPED`,
  /// jeho nedokončené sady `SKIPPED`. Poctivý stav — nikdy COMPLETED.
  Future<RecordPerformanceResult> skipStep({
    required String stepPerformanceId,
    required DateTime now,
  });

  /// Atomicky přepne dokončení setu (COMPLETED ↔ PLANNED). Ověří aktivní
  /// session a existenci setu.
  Future<RecordPerformanceResult> setSetCompletion({
    required String setPerformanceId,
    required bool completed,
    required DateTime now,
  });
}
