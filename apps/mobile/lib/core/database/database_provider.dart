import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Composition lokální databáze (ADR-002, ADR-004). Testy přepisují tento
/// provider instancí nad in-memory SQLite.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase(driftDatabase(name: 'ai_trainer'));
  ref.onDispose(database.close);
  return database;
});
