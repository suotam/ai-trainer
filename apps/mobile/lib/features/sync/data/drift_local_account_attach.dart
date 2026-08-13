import '../../../core/database/app_database.dart';
import '../../../core/database/tables/availability_tables.dart';
import '../../../core/database/tables/plan_tables.dart';
import '../../../core/database/tables/sports_tables.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../domain/local_account_attach.dart';

/// Drift implementace attach (C15 §5): jedna transakce, přepis `owner_id`
/// z `local-anonymous` na účet u attach-eligible entit (§4):
///
/// - sessions a summaries jsou vždy uživatelská data,
/// - instance jsou uživatelsky dotčené, pokud na nich existuje session
///   nebo mají `started_session_id` — čistý seed (bez session) zůstává
///   anonymní (LAM-006),
/// - hierarchická konzistence (LAM-008): instance se sessions se připojují
///   vždy, aby account-owned session neměla anonymního parenta,
/// - anonymní outbox položky následují vlastníka entit,
/// - children (performance/feedback) jsou vlastněny tranzitivně přes
///   session (LAM-014).
///
/// Kromě `owner_id` se nemění nic (LAM-004): ID, row_version, sync_state,
/// časy i doménové hodnoty zůstávají byte-po-bytu stejné.
class DriftLocalAccountAttach implements LocalAccountAttach {
  DriftLocalAccountAttach(this._db);

  final AppDatabase _db;

  @override
  Future<void> attachAnonymousData(String accountId) {
    return _db.transaction(() async {
      // 1. Instance: uživatelsky dotčené anonymní instance (LAM-006/008) —
      // kanonické kritérium je existence session / started_session_id;
      // ručně vytvořené USER_PLAN instance jsou uživatelská data od
      // vzniku (C15 §4, MPC-009). Čistý seed (DEMO bez session) zůstává
      // anonymní.
      await _db.customStatement(
        'UPDATE local_workout_instances SET owner_id = ? '
        "WHERE owner_id = '$localAnonymousOwnerId' AND ("
        '  id IN (SELECT workout_instance_id FROM local_workout_sessions) '
        '  OR started_session_id IS NOT NULL '
        "  OR source_type = '$userPlanSourceType'"
        ')',
        [accountId],
      );
      // 2. Sessions — vždy uživatelská data.
      await _db.customStatement(
        'UPDATE local_workout_sessions SET owner_id = ? '
        "WHERE owner_id = '$localAnonymousOwnerId'",
        [accountId],
      );
      // 3. Summaries — vždy uživatelská data.
      await _db.customStatement(
        'UPDATE local_activity_summaries SET owner_id = ? '
        "WHERE owner_id = '$localAnonymousOwnerId'",
        [accountId],
      );
      // 4. Outbox následuje vlastníka entit (C15 §5 bod 4).
      await _db.customStatement(
        'UPDATE local_outbox SET owner_id = ? '
        "WHERE owner_id = '$localAnonymousOwnerId'",
        [accountId],
      );
      // 5. Sportovní profil (R3-01, C16 R3M-006, C17 §8): anonymní
      // UserSport se připojí, pokud tím neporuší invarianty účtu —
      // kolizní záznam (duplicitní ne-ENDED katalogový sport nebo druhý
      // ACTIVE PRIMARY) zůstává anonymní, nikdy se nemaže ani nemutuje.
      await _db.customStatement(
        'UPDATE local_user_sports SET owner_id = ?1 '
        "WHERE owner_id = '$localAnonymousOwnerId' AND NOT ("
        "  (sport_code IS NOT NULL AND status != '$userSportStatusEnded' "
        '   AND EXISTS (SELECT 1 FROM local_user_sports a '
        '     WHERE a.owner_id = ?1 AND a.sport_code = local_user_sports.sport_code '
        "     AND a.status != '$userSportStatusEnded')) "
        "  OR (role = 'PRIMARY' AND status = '$userSportStatusActive' "
        '   AND EXISTS (SELECT 1 FROM local_user_sports a '
        "     WHERE a.owner_id = ?1 AND a.role = 'PRIMARY' "
        "     AND a.status = '$userSportStatusActive'))"
        ')',
        [accountId],
      );
      // 6. Cíle (R3-02, C18 §8): bezpodmínečný attach (GLC-010) — cíle
      // nemají cross-owner unikátní invarianty.
      await _db.customStatement(
        'UPDATE local_goals SET owner_id = ? '
        "WHERE owner_id = '$localAnonymousOwnerId'",
        [accountId],
      );
      // 7. Typický týden (R3-03, C19 §8): kolizní den (účet už má
      // deklaraci téhož dne) zůstává anonymní (AVC-003/010).
      await _db.customStatement(
        'UPDATE local_availability_rules SET owner_id = ?1 '
        "WHERE owner_id = '$localAnonymousOwnerId' AND NOT EXISTS ("
        '  SELECT 1 FROM local_availability_rules a WHERE a.owner_id = ?1 '
        '  AND a.day_of_week = local_availability_rules.day_of_week'
        ')',
        [accountId],
      );
      // 8. Vybavení (R3-03, C19 §8): kolizní ne-ARCHIVED katalogový kód
      // zůstává anonymní (AVC-006/010).
      await _db.customStatement(
        'UPDATE local_equipment_items SET owner_id = ?1 '
        "WHERE owner_id = '$localAnonymousOwnerId' AND NOT ("
        "  equipment_code IS NOT NULL AND status != '$equipmentStatusArchived' "
        '  AND EXISTS (SELECT 1 FROM local_equipment_items a '
        '    WHERE a.owner_id = ?1 '
        '    AND a.equipment_code = local_equipment_items.equipment_code '
        "    AND a.status != '$equipmentStatusArchived')"
        ')',
        [accountId],
      );
      // 9. Omezení (R3-03, C19 §8): bezpodmínečný attach.
      await _db.customStatement(
        'UPDATE local_constraints SET owner_id = ? '
        "WHERE owner_id = '$localAnonymousOwnerId'",
        [accountId],
      );
      // 10. Tréninkový plán (R3-04, C20 §7, MPC-010): kolizní anonymní
      // ACTIVE plán (účet už ACTIVE plán má) zůstává anonymní; jeho
      // instance se připojují nezávisle (device-local reference).
      await _db.customStatement(
        'UPDATE local_training_plans SET owner_id = ?1 '
        "WHERE owner_id = '$localAnonymousOwnerId' AND NOT ("
        "  status = '$planStatusActive' "
        '  AND EXISTS (SELECT 1 FROM local_training_plans a '
        "    WHERE a.owner_id = ?1 AND a.status = '$planStatusActive')"
        ')',
        [accountId],
      );
    });
  }
}
