import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/device/data/drift_installation_identity_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

class _FixedIdGenerator implements IdGenerator {
  _FixedIdGenerator(this._ids);

  final List<String> _ids;
  int _next = 0;

  @override
  String newId() => _ids[_next++ % _ids.length];
}

void main() {
  group('identita instalace (DRC-001/002)', () {
    test('installation ID vznikne jednou a je stabilni pres opakovana cteni '
        'i novou instanci repository nad touz DB', () async {
      final database = createTestDatabase();
      final first = DriftInstallationIdentityRepository(
        database,
        _FixedIdGenerator(['installation-a', 'installation-b']),
        () => DateTime.utc(2026, 8, 12),
      );

      final created = await first.ensureInstallationId();
      final reread = await first.ensureInstallationId();
      // â€žRestartâ€ś: novĂˇ instance nad stejnou lokĂˇlnĂ­ DB.
      final second = DriftInstallationIdentityRepository(
        database,
        _FixedIdGenerator(['installation-b']),
        () => DateTime.utc(2026, 8, 12),
      );
      final afterRestart = await second.ensureInstallationId();

      expect(created, equals('installation-a'));
      expect(reread, equals('installation-a'));
      expect(afterRestart, equals('installation-a'));
    });

    test('nova (prazdna) DB znamena novou instalaci a nove ID', () async {
      final reinstall = DriftInstallationIdentityRepository(
        createTestDatabase(),
        _FixedIdGenerator(['installation-new']),
        () => DateTime.utc(2026, 8, 12),
      );
      expect(
        await reinstall.ensureInstallationId(),
        equals('installation-new'),
      );
    });
  });

  group('registrace zarizeni po prihlaseni (C9 Â§5)', () {
    test(
      'prihlaseny stav registruje zarizeni s minimalizovanymi metadaty',
      () async {
        final storage = InMemorySecureSessionStorage();
        final authApi = FakeAuthApiClient();
        final deviceApi = FakeDeviceApiClient();
        final installation = FakeInstallationIdentity('installation-42');
        final container = createR2AuthContainer(
          storage: storage,
          authApi: authApi,
          installationIdentity: installation,
          deviceApi: deviceApi,
        );
        await container.read(authSessionManagerProvider.future);
        await container
            .read(authSessionManagerProvider.notifier)
            .registerAccount(
              email: 'device@example.com',
              password: 'password-123',
            );

        final result = await container
            .read(deviceRegistrarProvider)
            .registerThisDevice();

        expect(result, isA<DeviceRegistered>());
        final registration = deviceApi.registrations.single;
        expect(registration.installationId, equals('installation-42'));
        expect(registration.platform, equals('ANDROID'));
        expect(registration.localSchemaVersion, equals('4'));
        expect(registration.accessToken, equals(storage.stored!.accessToken));
      },
    );

    test('anonymni stav registraci preskoci (DRC-004)', () async {
      final deviceApi = FakeDeviceApiClient();
      final container = createR2AuthContainer(
        storage: InMemorySecureSessionStorage(),
        authApi: FakeAuthApiClient(),
        deviceApi: deviceApi,
      );

      final result = await container
          .read(deviceRegistrarProvider)
          .registerThisDevice();

      expect(result, isA<DeviceRegistrationSkipped>());
      expect(deviceApi.registrations, isEmpty);
    });

    test('vypadek site je typovane selhani bez padu a bez retry loopu '
        '(DRC-015)', () async {
      final storage = InMemorySecureSessionStorage();
      final authApi = FakeAuthApiClient();
      final deviceApi = FakeDeviceApiClient();
      final container = createR2AuthContainer(
        storage: storage,
        authApi: authApi,
        deviceApi: deviceApi,
      );
      await container.read(authSessionManagerProvider.future);
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'off@example.com', password: 'password-123');
      deviceApi.offline = true;

      final result = await container
          .read(deviceRegistrarProvider)
          .registerThisDevice();

      expect(result, isA<DeviceRegistrationFailed>());
      expect(deviceApi.registrations, isEmpty);
    });

    test('opakovana registrace pouziva stale stejne installation ID '
        '(DRC-006 na klientu)', () async {
      final storage = InMemorySecureSessionStorage();
      final authApi = FakeAuthApiClient();
      final deviceApi = FakeDeviceApiClient();
      final installation = FakeInstallationIdentity('installation-stable');
      final container = createR2AuthContainer(
        storage: storage,
        authApi: authApi,
        installationIdentity: installation,
        deviceApi: deviceApi,
      );
      await container.read(authSessionManagerProvider.future);
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'rep@example.com', password: 'password-123');

      await container.read(deviceRegistrarProvider).registerThisDevice();
      await container.read(deviceRegistrarProvider).registerThisDevice();

      expect(
        deviceApi.registrations.map((r) => r.installationId).toSet(),
        equals({'installation-stable'}),
      );
    });
  });

  group('deviceMetadataProvider', () {
    test('verze lokalniho schematu odpovida skutecne Drift verzi', () {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(createTestDatabase()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 8, 12)),
        ],
      );
      addTearDown(container.dispose);

      final metadata = container.read(deviceMetadataProvider);

      expect(metadata.localSchemaVersion, equals('9'));
      expect(metadata.appVersion, isNotEmpty);
    });
  });
}
