import 'package:ai_trainer_mobile/features/auth/presentation/account_screen.dart';
import 'package:ai_trainer_mobile/features/profile/presentation/profile_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';

void main() {
  Widget accountApp({
    required InMemorySecureSessionStorage storage,
    required FakeAuthApiClient api,
    FakeInstallationIdentity? installationIdentity,
    FakeDeviceApiClient? deviceApi,
    FakeProfileApiClient? profileApi,
  }) => r2AccountApp(
    storage: storage,
    api: api,
    installationIdentity: installationIdentity,
    deviceApi: deviceApi,
    profileApi: profileApi,
  );

  Future<void> submitCredentials(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.byKey(AccountScreen.emailFieldKey), email);
    await tester.enterText(
      find.byKey(AccountScreen.passwordFieldKey),
      password,
    );
    await tester.tap(find.byKey(AccountScreen.submitButtonKey));
    await tester.pumpAndSettle();
  }

  testWidgets('anonymní stav zobrazí přihlašovací formulář', (tester) async {
    await tester.pumpWidget(
      accountApp(
        storage: InMemorySecureSessionStorage(),
        api: FakeAuthApiClient(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(AccountScreen.emailFieldKey), findsOneWidget);
    expect(find.byKey(AccountScreen.passwordFieldKey), findsOneWidget);
    expect(find.byKey(AccountScreen.signedInKey), findsNothing);
  });

  testWidgets('registrace → přihlášený stav s technickým ID účtu', (
    tester,
  ) async {
    final storage = InMemorySecureSessionStorage();
    final api = FakeAuthApiClient();
    await tester.pumpWidget(accountApp(storage: storage, api: api));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(AccountScreen.switchModeKey));
    await tester.pumpAndSettle();
    await submitCredentials(
      tester,
      email: 'widget@example.com',
      password: 'password-123',
    );

    expect(find.byKey(AccountScreen.signedInKey), findsOneWidget);
    expect(find.textContaining('account-1'), findsOneWidget);
    expect(storage.stored, isNotNull);
  });

  testWidgets('špatné credentials zobrazí bezpečnou generickou chybu', (
    tester,
  ) async {
    final api = FakeAuthApiClient();
    await tester.pumpWidget(
      accountApp(storage: InMemorySecureSessionStorage(), api: api),
    );
    await tester.pumpAndSettle();

    await submitCredentials(
      tester,
      email: 'nobody@example.com',
      password: 'wrong-password',
    );

    expect(find.byKey(AccountScreen.errorKey), findsOneWidget);
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(find.byKey(AccountScreen.signedInKey), findsNothing);
  });

  testWidgets('výpadek sítě zobrazí offline zprávu a nechá formulář', (
    tester,
  ) async {
    final api = FakeAuthApiClient()..offline = true;
    await tester.pumpWidget(
      accountApp(storage: InMemorySecureSessionStorage(), api: api),
    );
    await tester.pumpAndSettle();

    await submitCredentials(
      tester,
      email: 'user@example.com',
      password: 'password-123',
    );

    expect(find.byKey(AccountScreen.errorKey), findsOneWidget);
    expect(
      find.text('Server is not reachable. Your workouts keep working offline.'),
      findsOneWidget,
    );
  });

  testWidgets('restart se zachovanou session zobrazí přímo přihlášený stav '
      'bez sítě', (tester) async {
    final storage = InMemorySecureSessionStorage();
    final api = FakeAuthApiClient();
    await tester.pumpWidget(accountApp(storage: storage, api: api));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AccountScreen.switchModeKey));
    await tester.pumpAndSettle();
    await submitCredentials(
      tester,
      email: 'restart@example.com',
      password: 'password-123',
    );
    expect(find.byKey(AccountScreen.signedInKey), findsOneWidget);

    // „Restart": nový widget tree + nový ProviderScope nad týmž úložištěm;
    // server je offline — obnova čte jen secure storage (C7 §6).
    await tester.pumpWidget(const SizedBox());
    api.offline = true;
    await tester.pumpWidget(accountApp(storage: storage, api: api));
    await tester.pumpAndSettle();

    expect(find.byKey(AccountScreen.signedInKey), findsOneWidget);
    expect(find.byKey(AccountScreen.emailFieldKey), findsNothing);
  });

  testWidgets('odhlášení vrátí formulář a odstraní session materiál', (
    tester,
  ) async {
    final storage = InMemorySecureSessionStorage();
    final api = FakeAuthApiClient();
    await tester.pumpWidget(accountApp(storage: storage, api: api));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AccountScreen.switchModeKey));
    await tester.pumpAndSettle();
    await submitCredentials(
      tester,
      email: 'logout@example.com',
      password: 'password-123',
    );
    expect(find.byKey(AccountScreen.signedInKey), findsOneWidget);

    await tester.tap(find.byKey(AccountScreen.signOutButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(AccountScreen.emailFieldKey), findsOneWidget);
    expect(find.byKey(AccountScreen.signedInKey), findsNothing);
    expect(storage.stored, isNull);
  });

  testWidgets('po přihlášení se zařízení registruje s uloženým access '
      'tokenem (R2-04, C9 §5)', (tester) async {
    final storage = InMemorySecureSessionStorage();
    final api = FakeAuthApiClient();
    final deviceApi = FakeDeviceApiClient();
    final installation = FakeInstallationIdentity('installation-ui-1');
    await tester.pumpWidget(
      accountApp(
        storage: storage,
        api: api,
        deviceApi: deviceApi,
        installationIdentity: installation,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AccountScreen.switchModeKey));
    await tester.pumpAndSettle();

    await submitCredentials(
      tester,
      email: 'device-ui@example.com',
      password: 'password-123',
    );

    expect(find.byKey(AccountScreen.signedInKey), findsOneWidget);
    final registration = deviceApi.registrations.single;
    expect(registration.installationId, equals('installation-ui-1'));
    expect(registration.accessToken, equals(storage.stored!.accessToken));
  });

  testWidgets('profil sekce umožní vytvořit profil a zobrazí ho', (
    tester,
  ) async {
    final storage = InMemorySecureSessionStorage();
    final api = FakeAuthApiClient();
    final profileApi = FakeProfileApiClient();
    await tester.pumpWidget(
      accountApp(storage: storage, api: api, profileApi: profileApi),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AccountScreen.switchModeKey));
    await tester.pumpAndSettle();
    await submitCredentials(
      tester,
      email: 'profile-ui@example.com',
      password: 'password-123',
    );

    // Bez profilu → formulář vytvoření.
    expect(find.byKey(ProfileSection.nameFieldKey), findsOneWidget);
    await tester.enterText(
      find.byKey(ProfileSection.nameFieldKey),
      'Runner Jane',
    );
    await tester.tap(find.byKey(ProfileSection.createButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(ProfileSection.profileLabelKey), findsOneWidget);
    expect(find.textContaining('Runner Jane'), findsOneWidget);
    expect(profileApi.createProfileIds, hasLength(1));
  });

  testWidgets('existující profil se zobrazí bez formuláře', (tester) async {
    final storage = InMemorySecureSessionStorage();
    final api = FakeAuthApiClient();
    final profileApi = FakeProfileApiClient();
    await tester.pumpWidget(
      accountApp(storage: storage, api: api, profileApi: profileApi),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AccountScreen.switchModeKey));
    await tester.pumpAndSettle();
    await submitCredentials(
      tester,
      email: 'existing-profile@example.com',
      password: 'password-123',
    );
    await tester.runAsync(
      () => profileApi.createProfile(
        accessToken: storage.stored!.accessToken,
        profileId: 'profile-preexisting',
        displayName: 'Existing Athlete',
      ),
    );
    // Načíst profil znovu po jeho vzniku mimo UI.
    await tester.pumpAndSettle();
    // Formulář byl zobrazen dřív — vytvoření mimo UI vyžaduje reload sekce.
    // Simulace: nový pump celé obrazovky (návrat na Account).
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      accountApp(storage: storage, api: api, profileApi: profileApi),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(ProfileSection.profileLabelKey), findsOneWidget);
    expect(find.textContaining('Existing Athlete'), findsOneWidget);
    expect(find.byKey(ProfileSection.nameFieldKey), findsNothing);
  });

  testWidgets('ověření revokované session bezpečně odhlásí', (tester) async {
    final storage = InMemorySecureSessionStorage();
    final api = FakeAuthApiClient();
    await tester.pumpWidget(accountApp(storage: storage, api: api));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AccountScreen.switchModeKey));
    await tester.pumpAndSettle();
    await submitCredentials(
      tester,
      email: 'revoked@example.com',
      password: 'password-123',
    );
    api.revokeSession(storage.stored!.sessionId);

    await tester.tap(find.byKey(AccountScreen.verifyButtonKey));
    await tester.pumpAndSettle();

    // Revokace → bezpečné odhlášení; materiál pryč, formulář zpět.
    expect(find.byKey(AccountScreen.emailFieldKey), findsOneWidget);
    expect(storage.stored, isNull);
  });
}
