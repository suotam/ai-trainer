import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_results.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_session_state.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';

class _SequentialIdGenerator implements IdGenerator {
  int _next = 0;

  @override
  String newId() => 'idempotency-key-${++_next}';
}

ProviderContainer createAuthContainer({
  required InMemorySecureSessionStorage storage,
  required FakeAuthApiClient api,
  FakeLocalOwnerBinding? ownerBinding,
}) {
  final container = ProviderContainer(
    overrides: [
      secureSessionStorageProvider.overrideWithValue(storage),
      authApiClientProvider.overrideWithValue(api),
      authIdempotencyKeyGeneratorProvider.overrideWithValue(
        _SequentialIdGenerator(),
      ),
      localOwnerBindingProvider.overrideWithValue(
        ownerBinding ?? FakeLocalOwnerBinding(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('restore po startu (C7 §6)', () {
    test(
      'bez uloženého materiálu je stav anonymní — validní výsledek',
      () async {
        final storage = InMemorySecureSessionStorage();
        final api = FakeAuthApiClient();
        final container = createAuthContainer(storage: storage, api: api);

        final state = await container.read(authSessionManagerProvider.future);

        expect(state, isA<AnonymousAuthState>());
      },
    );

    test('uložená session se obnoví bez sítě (offline restart)', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient();
      final first = createAuthContainer(storage: storage, api: api);
      await first.read(authSessionManagerProvider.future);
      await first
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'user@example.com', password: 'password-123');

      // „Restart": nový container nad týmž zařízením, server offline.
      api.offline = true;
      final second = createAuthContainer(storage: storage, api: api);
      final state = await second.read(authSessionManagerProvider.future);

      expect(state, isA<AuthenticatedAuthState>());
      expect((state as AuthenticatedAuthState).accountId, equals('account-1'));
    });

    test(
      'poškozené secure storage vede na bezpečný anonymní fallback (TSS-008)',
      () async {
        final storage = InMemorySecureSessionStorage()..failReads = true;
        final api = FakeAuthApiClient();
        final container = createAuthContainer(storage: storage, api: api);

        final state = await container.read(authSessionManagerProvider.future);

        expect(state, isA<AnonymousAuthState>());
        expect(storage.clearCount, greaterThan(0));
      },
    );
  });

  group('sign-in a registrace', () {
    test('úspěšné přihlášení uloží materiál a přepne stav', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient();
      final container = createAuthContainer(storage: storage, api: api);
      await container.read(authSessionManagerProvider.future);
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'user@example.com', password: 'password-123');
      await container.read(authSessionManagerProvider.notifier).signOut();

      final result = await container
          .read(authSessionManagerProvider.notifier)
          .signIn(email: 'user@example.com', password: 'password-123');

      expect(result, isA<AuthFlowSuccess>());
      expect(storage.stored, isNotNull);
      expect(
        container.read(authSessionManagerProvider).value,
        isA<AuthenticatedAuthState>(),
      );
    });

    test(
      'špatné heslo je typované generické selhání; stav zůstává anonymní',
      () async {
        final storage = InMemorySecureSessionStorage();
        final api = FakeAuthApiClient();
        final container = createAuthContainer(storage: storage, api: api);
        await container.read(authSessionManagerProvider.future);
        await container
            .read(authSessionManagerProvider.notifier)
            .registerAccount(
              email: 'user@example.com',
              password: 'password-123',
            );
        await container.read(authSessionManagerProvider.notifier).signOut();

        final result = await container
            .read(authSessionManagerProvider.notifier)
            .signIn(email: 'user@example.com', password: 'wrong-password');

        expect(result, isA<AuthFlowFailure>());
        expect(
          (result as AuthFlowFailure).reason,
          AuthFlowFailureReason.invalidCredentials,
        );
        expect(storage.stored, isNull);
        expect(
          container.read(authSessionManagerProvider).value,
          isA<AnonymousAuthState>(),
        );
      },
    );

    test('retry registrace po výpadku sítě opakuje stejný idempotency key '
        '(AAC-005) a nevytvoří druhý účet', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient()..offline = true;
      final container = createAuthContainer(storage: storage, api: api);
      await container.read(authSessionManagerProvider.future);
      final manager = container.read(authSessionManagerProvider.notifier);

      final offlineResult = await manager.registerAccount(
        email: 'user@example.com',
        password: 'password-123',
      );
      expect(
        (offlineResult as AuthFlowFailure).reason,
        AuthFlowFailureReason.network,
      );

      api.offline = false;
      final retryResult = await manager.registerAccount(
        email: 'user@example.com',
        password: 'password-123',
      );

      expect(retryResult, isA<AuthFlowSuccess>());
      expect(api.accountCount, equals(1));
      expect(api.usedIdempotencyKeys, equals(['idempotency-key-1']));
    });

    test('duplicitní registrace je typované selhání', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient();
      final container = createAuthContainer(storage: storage, api: api);
      await container.read(authSessionManagerProvider.future);
      final manager = container.read(authSessionManagerProvider.notifier);
      await manager.registerAccount(
        email: 'user@example.com',
        password: 'password-123',
      );
      await manager.signOut();

      final result = await manager.registerAccount(
        email: 'user@example.com',
        password: 'other-password-9',
      );

      expect(
        (result as AuthFlowFailure).reason,
        AuthFlowFailureReason.duplicateIdentity,
      );
    });

    test('neplatný vstup se odmítne bez volání sítě', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient()..offline = true;
      final container = createAuthContainer(storage: storage, api: api);
      await container.read(authSessionManagerProvider.future);
      final manager = container.read(authSessionManagerProvider.notifier);

      final badEmail = await manager.signIn(
        email: 'not-an-email',
        password: 'password-123',
      );
      final shortPassword = await manager.registerAccount(
        email: 'user@example.com',
        password: 'short',
      );

      expect(
        (badEmail as AuthFlowFailure).reason,
        AuthFlowFailureReason.invalidInput,
      );
      expect(
        (shortPassword as AuthFlowFailure).reason,
        AuthFlowFailureReason.invalidInput,
      );
    });
  });

  group('sign-out (TSS-009, security-negative)', () {
    test('logout odstraní materiál a revokuje serverovou session', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient();
      final container = createAuthContainer(storage: storage, api: api);
      await container.read(authSessionManagerProvider.future);
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'user@example.com', password: 'password-123');
      final sessionId = storage.stored!.sessionId;

      await container.read(authSessionManagerProvider.notifier).signOut();

      expect(storage.stored, isNull);
      expect(
        container.read(authSessionManagerProvider).value,
        isA<AnonymousAuthState>(),
      );
      expect(api.sessionRevoked(sessionId), isTrue);
    });

    test('přihlášení váže lokálního vlastníka na účet a odhlášení zpět na '
        'anonymní (R2-05, C2 §4)', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient();
      final ownerBinding = FakeLocalOwnerBinding();
      final container = createAuthContainer(
        storage: storage,
        api: api,
        ownerBinding: ownerBinding,
      );
      await container.read(authSessionManagerProvider.future);

      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(
            email: 'owner@example.com',
            password: 'password-123',
          );
      expect(ownerBinding.currentOwner, equals('account-1'));

      await container.read(authSessionManagerProvider.notifier).signOut();
      expect(ownerBinding.currentOwner, equals('local-anonymous'));
    });

    test('logout zneplatní lokální session i offline — bez závislosti na '
        'serveru', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient();
      final container = createAuthContainer(storage: storage, api: api);
      await container.read(authSessionManagerProvider.future);
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'user@example.com', password: 'password-123');

      api.offline = true;
      await container.read(authSessionManagerProvider.notifier).signOut();

      expect(storage.stored, isNull);
      expect(
        container.read(authSessionManagerProvider).value,
        isA<AnonymousAuthState>(),
      );
    });
  });

  group('verifySession (C7 §8)', () {
    test('aktivní session je serverem potvrzena', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient();
      final container = createAuthContainer(storage: storage, api: api);
      await container.read(authSessionManagerProvider.future);
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'user@example.com', password: 'password-123');

      final verification = await container
          .read(authSessionManagerProvider.notifier)
          .verifySession();

      expect(verification, SessionVerification.verifiedActive);
    });

    test('expirovaná access session se obnoví refresh rotací', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient();
      final container = createAuthContainer(storage: storage, api: api);
      await container.read(authSessionManagerProvider.future);
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'user@example.com', password: 'password-123');
      final before = storage.stored!;
      api.expireAccess(before.sessionId);

      final verification = await container
          .read(authSessionManagerProvider.notifier)
          .verifySession();

      expect(verification, SessionVerification.refreshed);
      expect(storage.stored!.accessToken, isNot(equals(before.accessToken)));
      expect(storage.stored!.refreshToken, isNot(equals(before.refreshToken)));
    });

    test('revokovaná session vede na signed-out bez dotyku lokálních dat '
        '(TSS-010)', () async {
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient();
      final container = createAuthContainer(storage: storage, api: api);
      await container.read(authSessionManagerProvider.future);
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'user@example.com', password: 'password-123');
      api.revokeSession(storage.stored!.sessionId);

      final verification = await container
          .read(authSessionManagerProvider.notifier)
          .verifySession();

      expect(verification, SessionVerification.signedOutRevoked);
      expect(storage.stored, isNull);
      expect(
        container.read(authSessionManagerProvider).value,
        isA<AnonymousAuthState>(),
      );
    });

    test(
      'nedostupný server zachová lokální stav (offline session §7.3)',
      () async {
        final storage = InMemorySecureSessionStorage();
        final api = FakeAuthApiClient();
        final container = createAuthContainer(storage: storage, api: api);
        await container.read(authSessionManagerProvider.future);
        await container
            .read(authSessionManagerProvider.notifier)
            .registerAccount(
              email: 'user@example.com',
              password: 'password-123',
            );

        api.offline = true;
        final verification = await container
            .read(authSessionManagerProvider.notifier)
            .verifySession();

        expect(verification, SessionVerification.offlineUnverified);
        expect(storage.stored, isNotNull);
        expect(
          container.read(authSessionManagerProvider).value,
          isA<AuthenticatedAuthState>(),
        );
      },
    );
  });
}
