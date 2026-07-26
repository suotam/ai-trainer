import '../domain/session_recovery_result.dart';
import '../domain/workout_performance_repository.dart';
import '../domain/workout_session_repository.dart';

/// Recovery aktivní session po restartu aplikace (VSP §16, fyzický model
/// §19, PDR-012).
///
/// Zdrojem pravdy je tabulka session (status `ACTIVE`/`PAUSED`), nikoli
/// technický pointer v `local_app_state`. Use case:
/// - odvodí kanonický nebo konfliktní stav z počtu aktivních sessions,
/// - ověří snapshot vazbu (existenci instance),
/// - idempotentně doplní chybějící performance řádky (bezpečné: validní
///   aktivní session + validní snapshot; existující actual data zůstávají),
/// - bezpečně rekonstruuje pointer z jediné aktivní session,
/// - detekuje osiřelý pointer a více konfliktních sessions bez destrukce.
///
/// Nikdy nedokončuje ani neruší session, negeneruje nové session ID,
/// nemění start time, nevytváří druhou aktivní session a nevyžaduje
/// backend. Raw persistence výjimka se mapuje na [UnrecoverableRecovery].
class RecoverActiveSession {
  const RecoverActiveSession({
    required this.sessionRepository,
    required this.performanceRepository,
    required this.clock,
  });

  final WorkoutSessionRepository sessionRepository;
  final WorkoutPerformanceRepository performanceRepository;
  final DateTime Function() clock;

  Future<SessionRecoveryResult> call() async {
    try {
      final active = await sessionRepository.findActiveSessions();

      if (active.length > 1) {
        // §19: více konfliktních aktivních sessions nesmí být automaticky
        // přepsáno bez explicitního recovery flow.
        return MultipleActiveSessionsRecovery(active.length);
      }

      if (active.length == 1) {
        final session = active.first;

        // Snapshot vazba musí být validní.
        final instanceOk = await sessionRepository.workoutInstanceExists(
          session.workoutInstanceId,
        );
        if (!instanceOk) {
          return InconsistentActiveSessionRecovery(
            RecoveryInconsistencyReason.missingInstance,
            sessionId: session.id,
          );
        }

        // Idempotentní doplnění chybějících performance řádků — bezpečné,
        // protože session je validní a aktivní; existující actual data se
        // nepřepíší (PDR-012).
        await performanceRepository.initializePerformances(
          sessionId: session.id,
          now: clock(),
        );

        final pointer = await sessionRepository.readActiveSessionPointer();
        if (pointer == session.id) {
          return ActiveSessionRecovered(session);
        }

        // Pointer chyběl nebo ukazoval jinam — bezpečně rekonstruuj z jediné
        // aktivní session (§19). Idempotentní a transakční; uvnitř transakce
        // se invariant re-ověřuje, takže oprava může být odmítnuta.
        final repaired = await sessionRepository.reconcileActiveSessionPointer(
          sessionId: session.id,
          now: clock(),
        );
        if (!repaired) {
          // Revalidace neprošla — oprava neproběhla. Nesmíme tvrdit, že je
          // recovery opravené, ani navigovat do trackeru; bezpečný fallback.
          return InconsistentActiveSessionRecovery(
            RecoveryInconsistencyReason.pointerRepairRejected,
            sessionId: session.id,
          );
        }
        return ActiveSessionRecoveredAfterRepair(session);
      }

      // Žádná aktivní session.
      final pointer = await sessionRepository.readActiveSessionPointer();
      if (pointer == null) {
        return const NoActiveSessionRecovery();
      }

      // Pointer ukazuje na session, kterou nelze bezpečně obnovit, a žádnou
      // jinou aktivní session nelze odvodit. Nemažeme (žádný destruktivní
      // self-healing) — explicitní bezpečný fallback.
      return InconsistentActiveSessionRecovery(
        RecoveryInconsistencyReason.orphanPointer,
        sessionId: pointer,
      );
    } catch (_) {
      // Raw persistence výjimka se nepropaguje do UI.
      return const UnrecoverableRecovery();
    }
  }
}
