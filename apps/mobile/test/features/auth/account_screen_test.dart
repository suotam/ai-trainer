import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/presentation/account_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';

void main() {
  Widget accountApp({
    required InMemorySecureSessionStorage storage,
    required FakeAuthApiClient api,
  }) => ProviderScope(
    overrides: [
      secureSessionStorageProvider.overrideWithValue(storage),
      authApiClientProvider.overrideWithValue(api),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AccountScreen(),
    ),
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
