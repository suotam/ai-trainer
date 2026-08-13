import 'user_sport.dart';

/// Port sportovního profilu (R3-01, C17).
///
/// Všechny operace jsou offline-first (ASP-012) a pracují s daty aktuálního
/// lokálního vlastníka (anonymní parita, ASP-009). Invarianty ASP-003/004
/// vynucuje implementace v transakci s typovanými výsledky.
abstract interface class UserSportRepository {
  /// Sporty aktuálního vlastníka v deterministickém pořadí (ASP-014):
  /// status (ACTIVE, PAUSED, ENDED), role, priorita, název.
  Future<List<UserSport>> sportsForCurrentOwner();

  /// Vytvoří nový UserSport (`existingId == null`), nebo upraví existující
  /// current-state (ASP-007: zvýší lokální verzi, `SYNCED` → `DIRTY`).
  Future<SaveUserSportResult> saveSport(
    UserSportInput input, {
    String? existingId,
    required String newId,
    required DateTime now,
  });

  /// Stavový přechod ACTIVE/PAUSED/ENDED (C17 §7.1). Konec je stav, ne
  /// mazání (ASP-008); resume na PRIMARY kontroluje ASP-003.
  Future<SaveUserSportResult> changeStatus(
    String id,
    String newStatus, {
    required DateTime now,
  });
}
