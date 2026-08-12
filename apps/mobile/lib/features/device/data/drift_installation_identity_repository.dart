import '../../../core/database/app_database.dart';
import '../../../core/ids/id_generator.dart';
import '../domain/installation_identity_repository.dart';

/// Klíč v `local_app_state` nesoucí installation ID (C7 §4 — ne-secret
/// technická reference patří do běžného lokálního stavu).
const String installationIdStateKey = 'device_installation_id';

/// Drift implementace identity instalace: ID vzniká atomicky při prvním
/// čtení a je stabilní po celou životnost instalace (DRC-001). Kompletní
/// reinstalace smaže lokální DB, takže přirozeně vznikne nové ID (DRC-002).
class DriftInstallationIdentityRepository
    implements InstallationIdentityRepository {
  DriftInstallationIdentityRepository(this._db, this._idGenerator, this._now);

  final AppDatabase _db;
  final IdGenerator _idGenerator;

  /// Testovatelná hranice času (ADR-010).
  final DateTime Function() _now;

  @override
  Future<String> ensureInstallationId() {
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.localAppState,
      )..where((t) => t.key.equals(installationIdStateKey))).getSingleOrNull();
      if (existing != null) {
        return existing.value;
      }
      final id = _idGenerator.newId();
      await _db
          .into(_db.localAppState)
          .insert(
            LocalAppStateCompanion.insert(
              key: installationIdStateKey,
              value: id,
              updatedAt: _now().toUtc().millisecondsSinceEpoch,
            ),
          );
      return id;
    });
  }
}
