import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_results.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/sports/application/sports_profile_providers.dart';
import 'package:ai_trainer_mobile/features/sports/domain/user_sport.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R3-01 attach testy (C16 R3M-006, C17 §8) nad skutečnou SQLite s reálným
/// Drift attach: anonymní sportovní profil se připojí k účtu; kolizní
/// záznamy (duplicitní katalogový sport, druhý ACTIVE PRIMARY) zůstávají
/// anonymní — nikdy se nemažou ani nemutují.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 13, 17);

  ProviderContainer createContainer({
    required AppDatabase database,
    required InMemorySecureSessionStorage storage,
    required FakeAuthApiClient authApi,
  }) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => fixedNow),
        secureSessionStorageProvider.overrideWithValue(storage),
        authApiClientProvider.overrideWithValue(authApi),
        installationIdentityProvider.overrideWithValue(
          FakeInstallationIdentity('installation-sports'),
        ),
        syncApiClientProvider.overrideWithValue(FakeSyncApiClient()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<String?> ownerOf(AppDatabase db, String id) async =>
      (await db
                  .customSelect(
                    'SELECT owner_id FROM local_user_sports WHERE id = ?',
                    variables: [Variable.withString(id)],
                  )
                  .getSingle())
              .data['owner_id']
          as String?;

  test('anonymní sportovní profil se registrací připojí k účtu '
      '(R3M-006) a je vidět v owner-filtrovaném read modelu', () async {
    final database = createTestDatabase();
    final container = createContainer(
      database: database,
      storage: InMemorySecureSessionStorage(),
      authApi: FakeAuthApiClient(),
    );
    final saved = await container
        .read(userSportRepositoryProvider)
        .saveSport(
          const UserSportInput(
            sportCode: 'CLIMBING',
            role: 'PRIMARY',
            priority: 'HIGH',
            experienceLevel: 'INTERMEDIATE',
          ),
          newId: 'us-anon-1',
          now: fixedNow,
        );
    expect(saved, isA<UserSportSaved>());

    await container.read(authSessionManagerProvider.future);
    final result = await container
        .read(authSessionManagerProvider.notifier)
        .registerAccount(email: 'sport@example.com', password: 'password-123');
    expect(result, isA<AuthFlowSuccess>());

    expect(await ownerOf(database, 'us-anon-1'), 'account-1');
    // Owner-filtrovaný read model vidí připojený sport (žádné „zmizení").
    final sports = await container
        .read(userSportRepositoryProvider)
        .sportsForCurrentOwner();
    expect(sports.single.sportCode, 'CLIMBING');
  });

  test('kolizní záznamy zůstávají anonymní (C17 §8): duplicitní katalogový '
      'sport i druhý ACTIVE PRIMARY; nekolizní se připojí', () async {
    final database = createTestDatabase();
    final storage = InMemorySecureSessionStorage();
    final authApi = FakeAuthApiClient();
    final container = createContainer(
      database: database,
      storage: storage,
      authApi: authApi,
    );
    final repo = container.read(userSportRepositoryProvider);
    final manager = container.read(authSessionManagerProvider.notifier);
    await container.read(authSessionManagerProvider.future);

    // Účet má FOOTBALL jako ACTIVE PRIMARY.
    await manager.registerAccount(
      email: 'collision@example.com',
      password: 'password-123',
    );
    await repo.saveSport(
      const UserSportInput(
        sportCode: 'FOOTBALL',
        role: 'PRIMARY',
        priority: 'CRITICAL',
      ),
      newId: 'us-acc-football',
      now: fixedNow,
    );

    // Odhlášení → anonymní režim; anonymní vlastník tvoří vlastní profil.
    await manager.signOut();
    await repo.saveSport(
      const UserSportInput(
        sportCode: 'FOOTBALL',
        role: 'RECREATIONAL',
        priority: 'LOW',
      ),
      newId: 'us-anon-football',
      now: fixedNow,
    );
    await repo.saveSport(
      const UserSportInput(
        sportCode: 'YOGA',
        role: 'PRIMARY',
        priority: 'MEDIUM',
      ),
      newId: 'us-anon-yoga-primary',
      now: fixedNow,
    );
    await repo.saveSport(
      const UserSportInput(
        sportCode: 'SWIMMING',
        role: 'SECONDARY',
        priority: 'MEDIUM',
      ),
      newId: 'us-anon-swimming',
      now: fixedNow,
    );

    // Přihlášení zpět → attach s kolizními pravidly.
    final signIn = await manager.signIn(
      email: 'collision@example.com',
      password: 'password-123',
    );
    expect(signIn, isA<AuthFlowSuccess>());

    // Duplicitní FOOTBALL zůstal anonymní (ASP-004 účtu neporušen).
    expect(await ownerOf(database, 'us-anon-football'), 'local-anonymous');
    // Druhý ACTIVE PRIMARY (YOGA) zůstal anonymní (ASP-003 neporušen).
    expect(await ownerOf(database, 'us-anon-yoga-primary'), 'local-anonymous');
    // Nekolizní SWIMMING se připojil.
    expect(await ownerOf(database, 'us-anon-swimming'), 'account-1');

    // Read model účtu drží invarianty: právě jeden FOOTBALL a jeden PRIMARY.
    final sports = await repo.sportsForCurrentOwner();
    expect(sports.where((s) => s.sportCode == 'FOOTBALL'), hasLength(1));
    expect(
      sports.where((s) => s.role == 'PRIMARY' && s.status == 'ACTIVE'),
      hasLength(1),
    );
    // Kolizní data nejsou smazaná ani mutovaná — jen anonymní (ASP-009).
    final anonCount =
        (await database
                .customSelect(
                  "SELECT COUNT(*) AS c FROM local_user_sports "
                  "WHERE owner_id = 'local-anonymous'",
                )
                .getSingle())
            .data['c'];
    expect(anonCount, 2);
  });
}
