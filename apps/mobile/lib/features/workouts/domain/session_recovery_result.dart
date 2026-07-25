import 'workout_session.dart';

/// Typovaný výsledek recovery aktivní session po restartu aplikace
/// (VSP §16, fyzický model §19, PDR-012).
///
/// Zdrojem pravdy o aktivní session je tabulka session (status
/// `ACTIVE`/`PAUSED`), nikoli technický active-session pointer v
/// `local_app_state`. Recovery pointer pouze rekonstruuje z jediné validní
/// aktivní session; nikdy neodhaduje business hodnoty, nemaže výkon a
/// neřeší více konfliktních aktivních sessions bez explicitního flow.
///
/// Neobsahuje Drift ani SQLite typy (PDR-008) — raw persistence výjimka se
/// mapuje na [UnrecoverableRecovery], nikdy neuniká do UI.
sealed class SessionRecoveryResult {
  const SessionRecoveryResult();
}

/// Žádná aktivní ani pozastavená session neexistuje — pokračuje se na Today.
class NoActiveSessionRecovery extends SessionRecoveryResult {
  const NoActiveSessionRecovery();
}

/// Právě jedna validní aktivní session, technický pointer na ni už ukazuje.
/// Aplikace obnoví session a tracker se stejnými uloženými hodnotami.
class ActiveSessionRecovered extends SessionRecoveryResult {
  const ActiveSessionRecovered(this.session);

  final WorkoutSessionSnapshot session;
}

/// Právě jedna validní aktivní session, ale technický pointer chyběl nebo
/// ukazoval jinam. Pointer byl bezpečně rekonstruován z této jediné aktivní
/// session (fyzický model §19) — transakčně a idempotentně. Session se
/// obnoví se stejnými uloženými hodnotami.
class ActiveSessionRecoveredAfterRepair extends SessionRecoveryResult {
  const ActiveSessionRecoveredAfterRepair(this.session);

  final WorkoutSessionSnapshot session;
}

/// Více než jedna aktivní/pozastavená session. Kanonickou session nelze
/// bezpečně určit; fyzický model §19 zakazuje automatické přepsání více
/// konfliktních sessions. Bezpečný fallback s Retry, žádná destrukce.
class MultipleActiveSessionsRecovery extends SessionRecoveryResult {
  const MultipleActiveSessionsRecovery(this.count);

  final int count;
}

/// Nekonzistentní nebo osiřelý stav, který nelze bezpečně automaticky
/// opravit bez rizika ztráty nebo odhadu dat. Bezpečný fallback s Retry;
/// žádná data se nemažou.
class InconsistentActiveSessionRecovery extends SessionRecoveryResult {
  const InconsistentActiveSessionRecovery(this.reason, {this.sessionId});

  final RecoveryInconsistencyReason reason;

  /// ID dotčené session nebo pointeru, pokud je známé (jen pro evidence/log).
  final String? sessionId;
}

/// Neočekávaná persistence chyba zachycená během recovery. Bezpečný
/// fallback s Retry; raw výjimka se do UI nepropaguje.
class UnrecoverableRecovery extends SessionRecoveryResult {
  const UnrecoverableRecovery();
}

/// Důvod bezpečně neopravitelné nekonzistence (fyzický model §19).
enum RecoveryInconsistencyReason {
  /// Aktivní session odkazuje na neexistující workout instanci (snapshot).
  missingInstance,

  /// Technický pointer ukazuje na session, kterou nelze bezpečně obnovit
  /// (neexistuje nebo není v aktivním stavu) a žádnou jinou aktivní session
  /// nelze odvodit.
  orphanPointer,
}
