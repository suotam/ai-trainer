import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../data/drift_local_sync_metadata_repository.dart';
import '../domain/local_sync_metadata_repository.dart';

/// Composition sync-metadata vrstvy (R2-01). Presentation ani ostatní
/// features nesahají na Drift — čtou jen tento provider (PDR-008).
final localSyncMetadataRepositoryProvider =
    Provider<LocalSyncMetadataRepository>(
      (ref) => DriftLocalSyncMetadataRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(idGeneratorProvider),
      ),
    );
