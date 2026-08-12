import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../app/configuration/app_environment.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_api_client.dart';
import '../../auth/domain/secure_session_storage.dart';
import '../data/drift_installation_identity_repository.dart';
import '../data/http_device_api_client.dart';
import '../domain/device_api_client.dart';
import '../domain/installation_identity_repository.dart';

/// Minimalizovaná metadata instalace (C9 §8, DRC-011): platforma, verze
/// aplikace a verze lokálního schématu — nic víc (žádný fingerprinting).
final class DeviceMetadata {
  const DeviceMetadata({
    required this.platform,
    required this.appVersion,
    required this.localSchemaVersion,
  });

  final String platform;
  final String appVersion;
  final String localSchemaVersion;
}

sealed class DeviceRegistrationResult {
  const DeviceRegistrationResult();
}

final class DeviceRegistered extends DeviceRegistrationResult {
  const DeviceRegistered(this.installationId);

  final String installationId;
}

/// Bez přihlášení se zařízení neregistruje (DRC-004) — anonymní/R1 tok
/// registraci nevyžaduje.
final class DeviceRegistrationSkipped extends DeviceRegistrationResult {
  const DeviceRegistrationSkipped();
}

/// Selhání je bezpečné a bez retry loopu (DRC-015); další pokus proběhne
/// při příštím přihlášení.
final class DeviceRegistrationFailed extends DeviceRegistrationResult {
  const DeviceRegistrationFailed(this.kind);

  final AuthApiFailureKind kind;
}

/// Registrace tohoto zařízení vůči účtu (R2-04, C9 §5): volá se po
/// úspěšném přihlášení/registraci účtu — žádný background loop (DRC-015).
/// Installation ID je stabilní client-generated reference (DRC-001);
/// upsert na serveru je idempotentní (DRC-006).
class DeviceRegistrar {
  DeviceRegistrar(
    this._storage,
    this._installationIdentity,
    this._apiClient,
    this._metadata,
  );

  final SecureSessionStorage _storage;
  final InstallationIdentityRepository _installationIdentity;
  final DeviceApiClient _apiClient;
  final DeviceMetadata _metadata;

  Future<DeviceRegistrationResult> registerThisDevice() async {
    final String? accessToken;
    try {
      accessToken = (await _storage.read())?.accessToken;
    } on SecureSessionStorageException {
      return const DeviceRegistrationSkipped();
    }
    if (accessToken == null) {
      return const DeviceRegistrationSkipped();
    }
    final installationId = await _installationIdentity.ensureInstallationId();
    try {
      final registered = await _apiClient.registerDevice(
        accessToken: accessToken,
        installationId: installationId,
        platform: _metadata.platform,
        appVersion: _metadata.appVersion,
        localSchemaVersion: _metadata.localSchemaVersion,
      );
      return DeviceRegistered(registered.installationId);
    } on AuthApiFailure catch (failure) {
      return DeviceRegistrationFailed(failure.kind);
    }
  }
}

/// Identita instalace nad lokální DB (ne-secret, C7 §4).
final installationIdentityProvider = Provider<InstallationIdentityRepository>(
  (ref) => DriftInstallationIdentityRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  ),
);

final deviceApiClientProvider = Provider<DeviceApiClient>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return HttpDeviceApiClient(
    baseUrl: environment.backendBaseUrl,
    httpClient: http.Client(),
  );
});

/// Metadata instalace: platforma z runtime, verze aplikace odpovídá
/// pubspec verzi, verze schématu je skutečná verze lokální Drift DB.
final deviceMetadataProvider = Provider<DeviceMetadata>((ref) {
  final platform = switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'IOS',
    _ => Platform.isIOS ? 'IOS' : 'ANDROID',
  };
  return DeviceMetadata(
    platform: platform,
    appVersion: '1.0.0+1',
    localSchemaVersion: ref.watch(appDatabaseProvider).schemaVersion.toString(),
  );
});

final deviceRegistrarProvider = Provider<DeviceRegistrar>(
  (ref) => DeviceRegistrar(
    ref.watch(secureSessionStorageProvider),
    ref.watch(installationIdentityProvider),
    ref.watch(deviceApiClientProvider),
    ref.watch(deviceMetadataProvider),
  ),
);
