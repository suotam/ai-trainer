import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_results.dart';
import 'package:ai_trainer_mobile/features/availability/application/availability_providers.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R3-03 attach testy (C16 R3M-006, C19 §8): kolizní den a kolizní
/// equipment zůstávají anonymní; omezení se připojují bezpodmínečně.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 13, 23);

  test('attach: kolizní den a equipment zůstávají anonymní, nekolizní a '
      'omezení se připojí', () async {
    final database = createTestDatabase();
    final storage = InMemorySecureSessionStorage();
    final authApi = FakeAuthApiClient();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => fixedNow),
        secureSessionStorageProvider.overrideWithValue(storage),
        authApiClientProvider.overrideWithValue(authApi),
        installationIdentityProvider.overrideWithValue(
          FakeInstallationIdentity('installation-availability'),
        ),
        syncApiClientProvider.overrideWithValue(FakeSyncApiClient()),
      ],
    );
    addTearDown(container.dispose);
    final repo = container.read(availabilityProfileRepositoryProvider);
    final manager = container.read(authSessionManagerProvider.notifier);
    await container.read(authSessionManagerProvider.future);

    // Účet: deklarace MON + DUMBBELLS.
    await manager.registerAccount(
      email: 'avail@example.com',
      password: 'password-123',
    );
    await repo.upsertDay(
      dayOfWeek: 'MON',
      level: 'AVAILABLE',
      newId: 'av-acc-mon',
      now: fixedNow,
    );
    await repo.addEquipment(
      equipmentCode: 'DUMBBELLS',
      newId: 'eq-acc-dumbbells',
      now: fixedNow,
    );
    await manager.signOut();

    // Anonymně: kolizní MON + nekolizní TUE; kolizní DUMBBELLS +
    // nekolizní BARBELL; omezení.
    await repo.upsertDay(
      dayOfWeek: 'MON',
      level: 'UNAVAILABLE',
      newId: 'av-anon-mon',
      now: fixedNow,
    );
    await repo.upsertDay(
      dayOfWeek: 'TUE',
      level: 'LIMITED',
      newId: 'av-anon-tue',
      now: fixedNow,
    );
    await repo.addEquipment(
      equipmentCode: 'DUMBBELLS',
      newId: 'eq-anon-dumbbells',
      now: fixedNow,
    );
    await repo.addEquipment(
      equipmentCode: 'BARBELL',
      newId: 'eq-anon-barbell',
      now: fixedNow,
    );
    await repo.addConstraint(
      title: 'Bolavé rameno',
      newId: 'c-anon-1',
      now: fixedNow,
    );

    final signIn = await manager.signIn(
      email: 'avail@example.com',
      password: 'password-123',
    );
    expect(signIn, isA<AuthFlowSuccess>());

    Future<String?> ownerOf(String table, String id) async =>
        (await database
                    .customSelect(
                      'SELECT owner_id FROM $table WHERE id = ?',
                      variables: [Variable.withString(id)],
                    )
                    .getSingle())
                .data['owner_id']
            as String?;

    // Kolizní záznamy zůstaly anonymní (AVC-010).
    expect(
      await ownerOf('local_availability_rules', 'av-anon-mon'),
      'local-anonymous',
    );
    expect(
      await ownerOf('local_equipment_items', 'eq-anon-dumbbells'),
      'local-anonymous',
    );
    // Nekolizní a omezení se připojily.
    expect(
      await ownerOf('local_availability_rules', 'av-anon-tue'),
      'account-1',
    );
    expect(
      await ownerOf('local_equipment_items', 'eq-anon-barbell'),
      'account-1',
    );
    expect(await ownerOf('local_constraints', 'c-anon-1'), 'account-1');

    // Invarianty účtu drží: jeden MON, jeden ne-ARCHIVED DUMBBELLS.
    final week = await repo.weekForCurrentOwner();
    expect(week.where((r) => r.dayOfWeek == 'MON'), hasLength(1));
    final equipment = await repo.equipmentForCurrentOwner();
    expect(
      equipment.where(
        (e) => e.equipmentCode == 'DUMBBELLS' && e.status == 'ACTIVE',
      ),
      hasLength(1),
    );
  });
}
