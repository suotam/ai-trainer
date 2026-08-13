/// Připojení předpřihlašovacích anonymních dat k účtu (R2-07, C15).
///
/// Attach je čistě lokální přepis vlastníka (LAM-001) — bez sítě; přenos
/// zajistí standardní push (C10). Je idempotentní (LAM-002), běží v jedné
/// transakci (LAM-003), nemění ID/klíče/hodnoty (LAM-004) a přepisuje
/// výhradně `local-anonymous` data (LAM-005/007). Čistý seed se
/// nepřipojuje (LAM-006).
abstract interface class LocalAccountAttach {
  Future<void> attachAnonymousData(String accountId);
}
