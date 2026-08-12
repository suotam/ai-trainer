import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/profile/application/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';

class _SequentialIdGenerator implements IdGenerator {
  int _next = 0;

  @override
  String newId() => 'profile-id-${++_next}';
}

void main() {
  ProviderContainer createContainer({
    required InMemorySecureSessionStorage storage,
    required FakeAuthApiClient authApi,
    required FakeProfileApiClient profileApi,
  }) => createR2AuthContainer(
    storage: storage,
    authApi: authApi,
    profileApi: profileApi,
    idGenerator: _SequentialIdGenerator(),
  );

  Future<void> signIn(ProviderContainer container) async {
    await container.read(authSessionManagerProvider.future);
    await container
        .read(authSessionManagerProvider.notifier)
        .registerAccount(
          email: 'profile@example.com',
          password: 'password-123',
        );
  }

  test('anonymni stav nema profil a nevola sit', () async {
    final profileApi = FakeProfileApiClient()..offline = true;
    final container = createContainer(
      storage: InMemorySecureSessionStorage(),
      authApi: FakeAuthApiClient(),
      profileApi: profileApi,
    );

    final profile = await container.read(currentProfileProvider.future);

    expect(profile, isNull);
  });

  test('vytvoreni profilu je uspesne a nacte se pres currentProfile', () async {
    final profileApi = FakeProfileApiClient();
    final container = createContainer(
      storage: InMemorySecureSessionStorage(),
      authApi: FakeAuthApiClient(),
      profileApi: profileApi,
    );
    await signIn(container);

    final result = await container
        .read(createProfileControllerProvider)
        .create(displayName: 'Runner Jane');

    expect(result, isA<ProfileCreateSuccess>());
    final current = await container.read(currentProfileProvider.future);
    expect(current!.displayName, equals('Runner Jane'));
  });

  test('retry po vypadku site opakuje stejne client-generated profile ID — '
      'zadny duplikat (SDM-005 idempotence)', () async {
    final profileApi = FakeProfileApiClient()..offline = true;
    final container = createContainer(
      storage: InMemorySecureSessionStorage(),
      authApi: FakeAuthApiClient(),
      profileApi: profileApi,
    );
    await signIn(container);
    final controller = container.read(createProfileControllerProvider);

    final offlineResult = await controller.create(displayName: 'Runner Jane');
    expect(
      (offlineResult as ProfileCreateFailure).reason,
      ProfileCreateFailureReason.network,
    );

    profileApi.offline = false;
    final retryResult = await controller.create(displayName: 'Runner Jane');

    expect(retryResult, isA<ProfileCreateSuccess>());
    expect(profileApi.createProfileIds.toSet().length, equals(1));
  });

  test('prazdne jmeno je invalidInput bez volani site', () async {
    final profileApi = FakeProfileApiClient()..offline = true;
    final container = createContainer(
      storage: InMemorySecureSessionStorage(),
      authApi: FakeAuthApiClient(),
      profileApi: profileApi,
    );
    await signIn(container);

    final result = await container
        .read(createProfileControllerProvider)
        .create(displayName: '   ');

    expect(
      (result as ProfileCreateFailure).reason,
      ProfileCreateFailureReason.invalidInput,
    );
    expect(profileApi.createProfileIds, isEmpty);
  });

  test('bez prihlaseni je vytvoreni profilu notSignedIn', () async {
    final profileApi = FakeProfileApiClient();
    final container = createContainer(
      storage: InMemorySecureSessionStorage(),
      authApi: FakeAuthApiClient(),
      profileApi: profileApi,
    );

    final result = await container
        .read(createProfileControllerProvider)
        .create(displayName: 'Nobody');

    expect(
      (result as ProfileCreateFailure).reason,
      ProfileCreateFailureReason.notSignedIn,
    );
  });
}
