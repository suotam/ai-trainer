import '../../../core/database/app_database.dart';
import '../../auth/domain/auth_api_client.dart';
import '../../auth/domain/secure_session_storage.dart';
import '../../device/domain/installation_identity_repository.dart';
import '../data/drift_pull_applier.dart';
import '../domain/sync_push_models.dart';

/// Typovaný výsledek pull běhu (C42 §4) — nikdy raw výjimka.
sealed class PullRunResult {
  const PullRunResult();
}

final class PullRunCompleted extends PullRunResult {
  const PullRunCompleted({
    required this.applied,
    required this.conflictSkipped,
    required this.skippedDependency,
  });

  final int applied;
  final int conflictSkipped;
  final int skippedDependency;
}

/// Bez přihlášení se nestahuje (SPC-001 vzor).
final class PullSkippedAnonymous extends PullRunResult {
  const PullSkippedAnonymous();
}

/// Síť/server nedostupné — typované, žádný auto-retry (PMS-012).
final class PullUnavailable extends PullRunResult {
  const PullUnavailable();
}

/// Pull engine (R6-02, C42): explicitní běh — kurzory per typ z lokálního
/// app state, batch aplikace v transakci, kurzor se posune až po úspěšné
/// aplikaci (PMS-010). Push chování se nemění (PMS-014).
class PullEngine {
  PullEngine(this._db, this._storage, this._installationIdentity, this._api);

  final AppDatabase _db;
  final SecureSessionStorage _storage;
  final InstallationIdentityRepository _installationIdentity;
  final SyncApiClient _api;

  static const _cursorKeyPrefix = 'pull_cursor_';

  /// Bezpečnostní strop smyčky — hasMore konverguje (PSP-007); strop jen
  /// chrání před vadným serverem.
  static const _maxIterations = 50;

  Future<PullRunResult> pullChanges({required DateTime now}) async {
    final String accessToken;
    final String accountId;
    try {
      final stored = await _storage.read();
      if (stored == null) {
        return const PullSkippedAnonymous();
      }
      accessToken = stored.accessToken;
      accountId = stored.accountId;
    } on SecureSessionStorageException {
      return const PullSkippedAnonymous();
    }
    final installationId = await _installationIdentity.ensureInstallationId();

    var applied = 0;
    var conflicts = 0;
    var dependencies = 0;
    var cursors = await _loadCursors();
    final applier = DriftPullApplier(_db);

    for (var iteration = 0; iteration < _maxIterations; iteration++) {
      final SyncPullResponse response;
      try {
        response = await _api.pull(
          accessToken: accessToken,
          installationId: installationId,
          cursors: cursors,
        );
      } on AuthApiFailure {
        return const PullUnavailable();
      }

      // Batch aplikace + posun kurzorů v jedné transakci (PMS-010):
      // přerušení znamená nanejvýš opakovanou idempotentní aplikaci.
      await _db.transaction(() async {
        for (final item in response.items) {
          switch (await applier.apply(accountId, item, now: now)) {
            case PullApplyOutcome.appliedNew:
            case PullApplyOutcome.appliedUpdate:
            case PullApplyOutcome.appliedDelete:
              applied++;
            case PullApplyOutcome.conflictSkipped:
              conflicts++;
            case PullApplyOutcome.skippedDependency:
              dependencies++;
            case PullApplyOutcome.noOp:
              break;
          }
        }
        await _storeCursors(response.cursors, now: now);
      });
      cursors = {...cursors, ...response.cursors};
      if (!response.hasMore) {
        return PullRunCompleted(
          applied: applied,
          conflictSkipped: conflicts,
          skippedDependency: dependencies,
        );
      }
    }
    // Strop překročen — vadný server; typovaná nedostupnost.
    return const PullUnavailable();
  }

  Future<Map<String, String?>> _loadCursors() async {
    final cursors = <String, String?>{};
    for (final type in pullSupportedTypes) {
      final row =
          await (_db.select(_db.localAppState)
                ..where((t) => t.key.equals('$_cursorKeyPrefix$type')))
              .getSingleOrNull();
      cursors[type] = row?.value;
    }
    return cursors;
  }

  Future<void> _storeCursors(
    Map<String, String?> cursors, {
    required DateTime now,
  }) async {
    for (final entry in cursors.entries) {
      final token = entry.value;
      if (token == null) {
        continue;
      }
      await _db
          .into(_db.localAppState)
          .insertOnConflictUpdate(
            LocalAppStateCompanion.insert(
              key: '$_cursorKeyPrefix${entry.key}',
              value: token,
              updatedAt: now.toUtc().millisecondsSinceEpoch,
            ),
          );
    }
  }
}
