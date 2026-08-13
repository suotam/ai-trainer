import 'daily_check_in.dart';

/// Port denního check-inu (R5-01, C33).
///
/// Offline-first, data aktuálního lokálního vlastníka. Denní klíč
/// (DCI-002) vynucuje implementace v transakci: zápis pro den, kde už
/// vlastník záznam má, je editace téhož záznamu — nikdy druhý záznam.
abstract interface class DailyCheckInRepository {
  /// Uloží nebo edituje check-in daného dne (DCI-002).
  Future<CheckInWriteResult> saveForDate(
    String localDate,
    DailyCheckInInput input, {
    required String newId,
    required DateTime now,
  });

  /// Check-in dne, nebo null — chybějící check-in je validní stav
  /// (DCI-001).
  Future<DailyCheckIn?> checkInForDate(String localDate);

  /// Historie vlastníka: localDate sestupně, pak id (DCI-007).
  Future<List<DailyCheckIn>> historyForCurrentOwner();
}
