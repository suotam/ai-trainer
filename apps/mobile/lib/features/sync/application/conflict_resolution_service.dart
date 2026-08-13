import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_session_state.dart';
import '../domain/sync_push_models.dart';
import '../domain/sync_snapshot_repository.dart';
import 'local_sync_providers.dart';

/// Řešení konfliktů a odmítnutí (R2-06, C12 §5): výhradně explicitní
/// uživatelské rozhodnutí (CRC-002) — `USE_LOCAL` (potvrzený re-push jako
/// nová operace s novým klíčem přes resolution-salt, CRC-004/005) nebo
/// `CANCEL_LOCAL_CHANGE` (ruší jen odeslání, nikdy lokální data —
/// CRC-006/007). Rozhodnutí jsou append-only a restart-safe (CRC-013).
class ConflictResolutionService {
  ConflictResolutionService(this._snapshot, this._now);

  final SyncSnapshotRepository _snapshot;
  final DateTime Function() _now;

  /// USE_LOCAL: uzavře položku a označí root `DIRTY` — příští explicitní
  /// sync ji znovu odešle s aktuální serverovou verzí z konfliktu (uloženou
  /// engine při VERSION_CONFLICT) a novým idempotency klíčem.
  Future<void> useLocal(UnresolvedSyncItem item) async {
    await _snapshot.recordResolution(item.outboxId, 'USE_LOCAL', now: _now());
    await _snapshot.markRootSyncState(
      item.stateEntityType,
      item.stateEntityId,
      'DIRTY',
    );
  }

  /// CANCEL_LOCAL_CHANGE: uzavře položku; entita opouští konfliktní stav
  /// jako `LOCAL_ONLY` — rozdíl vůči serveru zůstává přiznaný (CRC-007),
  /// lokální data nedotčená.
  Future<void> cancel(UnresolvedSyncItem item) async {
    await _snapshot.recordResolution(
      item.outboxId,
      'CANCEL_LOCAL_CHANGE',
      now: _now(),
    );
    await _snapshot.markRootSyncState(
      item.stateEntityType,
      item.stateEntityId,
      'LOCAL_ONLY',
    );
  }
}

final conflictResolutionServiceProvider = Provider<ConflictResolutionService>(
  (ref) => ConflictResolutionService(
    ref.watch(syncSnapshotRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

/// Nevyřešené konfliktní/odmítnuté položky přihlášeného účtu (C12 §6).
/// Anonymní stav nemá co řešit. Bez automatického retry.
final unresolvedSyncItemsProvider = FutureProvider<List<UnresolvedSyncItem>>((
  ref,
) async {
  final authState = await ref.watch(authSessionManagerProvider.future);
  if (authState is! AuthenticatedAuthState) {
    return const [];
  }
  return ref
      .watch(syncSnapshotRepositoryProvider)
      .unresolvedItems(authState.accountId);
}, retry: (retryCount, error) => null);
