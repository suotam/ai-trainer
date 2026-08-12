import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../app/configuration/app_environment.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../auth/application/auth_providers.dart';
import '../../device/application/device_registrar.dart';
import '../data/drift_local_sync_metadata_repository.dart';
import '../data/drift_sync_snapshot_repository.dart';
import '../data/http_sync_api_client.dart';
import '../domain/local_owner_binding.dart';
import '../domain/local_sync_metadata_repository.dart';
import '../domain/sync_push_models.dart';
import '../domain/sync_snapshot_repository.dart';
import 'sync_engine.dart';

/// Composition sync-metadata vrstvy (R2-01). Presentation ani ostatní
/// features nesahají na Drift — čtou jen tento provider (PDR-008).
final localSyncMetadataRepositoryProvider =
    Provider<LocalSyncMetadataRepository>(
      (ref) => DriftLocalSyncMetadataRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(idGeneratorProvider),
      ),
    );

/// Vazba aktuálního lokálního vlastníka (R2-05, C2 §4 ↔ C3 §7).
final localOwnerBindingProvider = Provider<LocalOwnerBinding>(
  (ref) => DriftLocalOwnerBinding(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);

/// Snapshot lokálních dat k push a aplikace potvrzených výsledků (R2-05).
final syncSnapshotRepositoryProvider = Provider<SyncSnapshotRepository>(
  (ref) => DriftSyncSnapshotRepository(ref.watch(appDatabaseProvider)),
);

/// Klient push sync API podle C10.
final syncApiClientProvider = Provider<SyncApiClient>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return HttpSyncApiClient(
    baseUrl: environment.backendBaseUrl,
    httpClient: http.Client(),
  );
});

/// Push sync engine (R2-05) — spouští se explicitně z UI, žádný background
/// loop (SPC-015).
final syncEngineProvider = Provider<SyncEngine>(
  (ref) => SyncEngine(
    ref.watch(secureSessionStorageProvider),
    ref.watch(installationIdentityProvider),
    ref.watch(localSyncMetadataRepositoryProvider),
    ref.watch(syncSnapshotRepositoryProvider),
    ref.watch(syncApiClientProvider),
    ref.watch(clockProvider),
  ),
);
