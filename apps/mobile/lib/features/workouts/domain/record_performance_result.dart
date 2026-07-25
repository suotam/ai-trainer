/// Explicitní výsledek zápisu set performance (R1-04).
///
/// Aplikační vrstva nikdy nevrací raw persistence výjimku — pouze tyto
/// typované výsledky.
library;

sealed class RecordPerformanceResult {
  const RecordPerformanceResult();
}

/// Hodnota byla uložena.
class PerformanceSaved extends RecordPerformanceResult {
  const PerformanceSaved();
}

/// Vstup neprošel validací (nezáporné hodnoty, rozsahy).
class PerformanceValidationFailure extends RecordPerformanceResult {
  const PerformanceValidationFailure(this.reason);
  final PerformanceValidationReason reason;
}

/// Session vlastnící set není aktivní — zápis se neprovede.
class PerformanceSessionNotActive extends RecordPerformanceResult {
  const PerformanceSessionNotActive();
}

/// Set performance řádek neexistuje.
class PerformanceSetNotFound extends RecordPerformanceResult {
  const PerformanceSetNotFound();
}

enum PerformanceValidationReason { negativeReps, negativeWeight }
