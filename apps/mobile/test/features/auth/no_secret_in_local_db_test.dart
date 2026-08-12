import 'dart:io';

import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_bootstrap.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';

/// No-secret-in-DB evidence (C7 §11 bod 1, TSS-002/003): po přihlášení
/// neobsahuje soubor lokální Drift/SQLite databáze heslo ani access/refresh
/// credential — session materiál žije výhradně v secure storage boundary.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'lokální SQLite soubor neobsahuje heslo ani tokeny po auth flow',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'aitrainer_no_secret_test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final databaseFile = File('${directory.path}/app.sqlite');

      final database = AppDatabase(NativeDatabase(databaseFile));
      final storage = InMemorySecureSessionStorage();
      final api = FakeAuthApiClient();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureSessionStorageProvider.overrideWithValue(storage),
          authApiClientProvider.overrideWithValue(api),
        ],
      );
      addTearDown(container.dispose);

      // Reálný lokální stav: idempotentní R1 seed nad skutečnou SQLite.
      await container.read(workoutBootstrapCompletedProvider.future);

      // Auth flow: registrace + přihlášení + ověření session.
      await container.read(authSessionManagerProvider.future);
      final manager = container.read(authSessionManagerProvider.notifier);
      const password = 'super-secret-password-42';
      await manager.registerAccount(
        email: 'nosecret@example.com',
        password: password,
      );
      await manager.verifySession();

      final stored = storage.stored;
      expect(stored, isNotNull, reason: 'sanity: session materiál existuje');

      // WAL checkpoint, aby byl celý obsah v hlavním souboru, a zavření DB.
      await database.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
      await database.close();

      final bytes = await databaseFile.readAsBytes();
      final content = String.fromCharCodes(bytes);

      final secrets = <String, String>{
        'password': password,
        'access token': stored!.accessToken,
        'refresh token': stored.refreshToken,
      };
      secrets.forEach((label, secret) {
        expect(
          content.contains(secret),
          isFalse,
          reason: 'SQLite soubor nesmí obsahovat $label (TSS-002/003)',
        );
      });

      // Sanity: soubor není prázdný a obsahuje R1 seed data — kontrola výše
      // tedy skenuje skutečný obsah, ne prázdný soubor.
      expect(bytes.length, greaterThan(0));
      expect(content.contains('demo-'), isTrue);
    },
  );
}
