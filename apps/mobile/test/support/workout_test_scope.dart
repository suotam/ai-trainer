import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vytvoří in-memory [AppDatabase] a zaregistruje jeho úklid — skutečná
/// SQLite místo souborové databáze (QTR-004).
AppDatabase createTestDatabase() {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  return database;
}

/// `ProviderContainer` s in-memory databází a fixním časem pro provider
/// testy. Úklid je zaregistrován automaticky.
ProviderContainer createWorkoutContainer({
  required AppDatabase database,
  DateTime? now,
}) {
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      if (now != null) clockProvider.overrideWithValue(() => now),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// `ProviderScope` s in-memory databází a fixním časem pro widget testy.
ProviderScope workoutTestScope({
  required AppDatabase database,
  required Widget child,
  DateTime? now,
}) => ProviderScope(
  overrides: [
    appDatabaseProvider.overrideWithValue(database),
    if (now != null) clockProvider.overrideWithValue(() => now),
  ],
  child: child,
);
