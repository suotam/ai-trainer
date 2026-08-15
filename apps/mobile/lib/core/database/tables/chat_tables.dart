/// Drift tabulky R7 chatu (C47 §2).
///
/// Konverzace a zprávy jsou device-local artefakt (CHC-001) — žádný
/// owner/sync sloupec, žádná synchronizace. Zprávy append-only (CHC-011).
library;

import 'package:drift/drift.dart';

/// Role zpráv (CHC-003).
const String chatRoleUser = 'USER';
const String chatRoleAssistant = 'ASSISTANT';

/// Stavy zpráv (CHC-003): uživatelská vždy SENT; asistentská
/// PENDING → COMPLETED / FAILED.
const String chatStatusSent = 'SENT';
const String chatStatusPending = 'PENDING';
const String chatStatusCompleted = 'COMPLETED';
const String chatStatusFailed = 'FAILED';

@DataClassName('LocalChatConversationRow')
class LocalChatConversations extends Table {
  @override
  String get tableName => 'local_chat_conversations';

  TextColumn get id => text()();
  IntColumn get startedAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LocalChatMessageRow')
class LocalChatMessages extends Table {
  @override
  String get tableName => 'local_chat_messages';

  TextColumn get id => text()();
  TextColumn get conversationId =>
      text().references(LocalChatConversations, #id)();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get status => text()();

  /// Typovaný důvod selhání asistentské zprávy (CHC-003/010).
  TextColumn get errorKind => text().nullable()();

  IntColumn get position => integer()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (role IN ('USER','ASSISTANT'))",
    "CHECK (status IN ('SENT','PENDING','COMPLETED','FAILED'))",
    'CHECK (position >= 0)',
  ];
}
