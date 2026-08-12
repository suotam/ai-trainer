import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_api_client.dart';
import 'package:ai_trainer_mobile/features/auth/presentation/account_screen.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/device/domain/device_api_client.dart';
import 'package:ai_trainer_mobile/features/device/domain/installation_identity_repository.dart';
import 'package:ai_trainer_mobile/features/profile/application/profile_providers.dart';
import 'package:ai_trainer_mobile/features/profile/domain/profile_api_client.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_boundaries.dart';

/// Fake push sync API se sémantikou R2-05 backendu: CREATE úspěch s verzí 1,
/// UPDATE inkrement; scriptovatelné odmítnutí per entita.
class FakeSyncApiClient implements SyncApiClient {
  bool offline = false;

  /// entityId → výsledek (`VERSION_CONFLICT`, `PERMISSION_DENIED`, …).
  final Map<String, String> scriptedResults = {};
  final Map<String, int> serverVersions = {};
  final List<List<SyncPushOperation>> pushedBatches = [];

  @override
  Future<List<SyncItemOutcome>> push({
    required String accessToken,
    required String installationId,
    required List<SyncPushOperation> operations,
  }) async {
    if (offline) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
    pushedBatches.add(operations);
    return [
      for (final op in operations)
        () {
          final scripted = scriptedResults[op.entityId];
          if (scripted != null) {
            return SyncItemOutcome(
              operationId: op.operationId,
              result: scripted,
              serverVersion: scripted == 'VERSION_CONFLICT'
                  ? serverVersions[op.entityId]
                  : null,
            );
          }
          final next = (serverVersions[op.entityId] ?? 0) + 1;
          serverVersions[op.entityId] = next;
          return SyncItemOutcome(
            operationId: op.operationId,
            result: next == 1 ? 'SUCCESS' : 'SUCCESS',
            serverVersion: next,
          );
        }(),
    ];
  }
}

/// Deterministická identita instalace pro testy (bez lokální DB).
class FakeInstallationIdentity implements InstallationIdentityRepository {
  FakeInstallationIdentity([this.installationId = 'fake-installation-1']);

  final String installationId;
  int calls = 0;

  @override
  Future<String> ensureInstallationId() async {
    calls += 1;
    return installationId;
  }
}

/// Záznam jedné registrace zařízení přijaté fake serverem.
typedef DeviceRegistration = ({
  String accessToken,
  String installationId,
  String platform,
  String appVersion,
  String localSchemaVersion,
});

class FakeDeviceApiClient implements DeviceApiClient {
  bool offline = false;
  final List<DeviceRegistration> registrations = [];

  @override
  Future<RegisteredDevice> registerDevice({
    required String accessToken,
    required String installationId,
    required String platform,
    required String appVersion,
    required String localSchemaVersion,
  }) async {
    if (offline) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
    registrations.add((
      accessToken: accessToken,
      installationId: installationId,
      platform: platform,
      appVersion: appVersion,
      localSchemaVersion: localSchemaVersion,
    ));
    return RegisteredDevice(installationId: installationId, status: 'ACTIVE');
  }
}

/// Fake profile API se sémantikou R2-04 backendu: idempotentní create podle
/// profileId; jeden testovací účet.
class FakeProfileApiClient implements ProfileApiClient {
  bool offline = false;
  AthleteProfileView? current;
  final List<String> createProfileIds = [];

  @override
  Future<AthleteProfileView> createProfile({
    required String accessToken,
    required String profileId,
    required String displayName,
    String? primarySport,
  }) async {
    if (offline) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
    createProfileIds.add(profileId);
    final existing = current;
    if (existing != null && existing.profileId == profileId) {
      return existing;
    }
    final profile = AthleteProfileView(
      profileId: profileId,
      displayName: displayName,
      primarySport: primarySport,
    );
    current = profile;
    return profile;
  }

  @override
  Future<AthleteProfileView?> currentProfile(String accessToken) async {
    if (offline) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
    return current;
  }
}

/// `ProviderContainer` s kompletními auth + device + profile fake hranicemi
/// (R2-03/R2-04) — žádná síť, žádná reálná DB. Úklid je registrován.
ProviderContainer createR2AuthContainer({
  required InMemorySecureSessionStorage storage,
  required FakeAuthApiClient authApi,
  FakeInstallationIdentity? installationIdentity,
  FakeDeviceApiClient? deviceApi,
  FakeProfileApiClient? profileApi,
  FakeSyncApiClient? syncApi,
  FakeLocalOwnerBinding? ownerBinding,
  IdGenerator? idGenerator,
  IdGenerator? authIdempotencyKeys,
}) {
  final container = ProviderContainer(
    overrides: [
      secureSessionStorageProvider.overrideWithValue(storage),
      authApiClientProvider.overrideWithValue(authApi),
      installationIdentityProvider.overrideWithValue(
        installationIdentity ?? FakeInstallationIdentity(),
      ),
      deviceApiClientProvider.overrideWithValue(
        deviceApi ?? FakeDeviceApiClient(),
      ),
      deviceMetadataProvider.overrideWithValue(
        const DeviceMetadata(
          platform: 'ANDROID',
          appVersion: '1.0.0+1',
          localSchemaVersion: '3',
        ),
      ),
      profileApiClientProvider.overrideWithValue(
        profileApi ?? FakeProfileApiClient(),
      ),
      syncApiClientProvider.overrideWithValue(syncApi ?? FakeSyncApiClient()),
      localOwnerBindingProvider.overrideWithValue(
        ownerBinding ?? FakeLocalOwnerBinding(),
      ),
      if (idGenerator != null)
        idGeneratorProvider.overrideWithValue(idGenerator),
      if (authIdempotencyKeys != null)
        authIdempotencyKeyGeneratorProvider.overrideWithValue(
          authIdempotencyKeys,
        ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Account obrazovka s kompletními fake hranicemi pro widget testy.
Widget r2AccountApp({
  required InMemorySecureSessionStorage storage,
  required FakeAuthApiClient api,
  FakeInstallationIdentity? installationIdentity,
  FakeDeviceApiClient? deviceApi,
  FakeProfileApiClient? profileApi,
  FakeSyncApiClient? syncApi,
}) => ProviderScope(
  overrides: [
    secureSessionStorageProvider.overrideWithValue(storage),
    authApiClientProvider.overrideWithValue(api),
    installationIdentityProvider.overrideWithValue(
      installationIdentity ?? FakeInstallationIdentity(),
    ),
    deviceApiClientProvider.overrideWithValue(
      deviceApi ?? FakeDeviceApiClient(),
    ),
    deviceMetadataProvider.overrideWithValue(
      const DeviceMetadata(
        platform: 'ANDROID',
        appVersion: '1.0.0+1',
        localSchemaVersion: '3',
      ),
    ),
    profileApiClientProvider.overrideWithValue(
      profileApi ?? FakeProfileApiClient(),
    ),
    syncApiClientProvider.overrideWithValue(syncApi ?? FakeSyncApiClient()),
    localOwnerBindingProvider.overrideWithValue(FakeLocalOwnerBinding()),
  ],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AccountScreen(),
  ),
);
