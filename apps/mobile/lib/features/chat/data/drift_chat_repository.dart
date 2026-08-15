import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/chat_tables.dart';
import '../domain/chat_models.dart';

/// Drift persistence konverzací (C47 §2/§3): device-local (CHC-001),
/// append-only zprávy (CHC-011), jediná aktivní konverzace (CHC-012),
/// osiřelé PENDING → FAILED při otevření (CHC-004).
class DriftChatRepository implements ChatRepository {
  DriftChatRepository(this._db);

  final AppDatabase _db;

  @override
  Future<String> openActiveConversation({
    required String Function() newId,
    required DateTime now,
  }) async {
    // Osiřelé PENDING z předchozího běhu = poctivé FAILED (CHC-004).
    await _db.customStatement(
      "UPDATE local_chat_messages SET status = 'FAILED', "
      "error_kind = 'interrupted' WHERE status = 'PENDING'",
    );
    final latest =
        await (_db.select(_db.localChatConversations)
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (latest != null) {
      return latest.id;
    }
    return startNewConversation(newId: newId, now: now);
  }

  @override
  Future<String> startNewConversation({
    required String Function() newId,
    required DateTime now,
  }) async {
    final id = newId();
    await _db
        .into(_db.localChatConversations)
        .insert(
          LocalChatConversationsCompanion.insert(
            id: id,
            startedAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
    return id;
  }

  @override
  Future<List<ChatMessage>> messages(String conversationId) async {
    final rows =
        await (_db.select(_db.localChatMessages)
              ..where((t) => t.conversationId.equals(conversationId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    return [for (final row in rows) _toModel(row)];
  }

  @override
  Future<String> appendExchange(
    String conversationId, {
    required String userText,
    required String Function() newId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final position = await _nextPosition(conversationId);
      final assistantId = newId();
      await _db
          .into(_db.localChatMessages)
          .insert(
            LocalChatMessagesCompanion.insert(
              id: newId(),
              conversationId: conversationId,
              role: chatRoleUser,
              content: userText,
              status: chatStatusSent,
              position: position,
              createdAt: now.millisecondsSinceEpoch,
            ),
          );
      await _db
          .into(_db.localChatMessages)
          .insert(
            LocalChatMessagesCompanion.insert(
              id: assistantId,
              conversationId: conversationId,
              role: chatRoleAssistant,
              content: '',
              status: chatStatusPending,
              position: position + 1,
              createdAt: now.millisecondsSinceEpoch,
            ),
          );
      await _touchConversation(conversationId, now);
      return assistantId;
    });
  }

  @override
  Future<void> completeAssistant(
    String messageId, {
    required String content,
    required DateTime now,
  }) async {
    await (_db.update(
      _db.localChatMessages,
    )..where((t) => t.id.equals(messageId))).write(
      LocalChatMessagesCompanion(
        content: Value(content),
        status: const Value(chatStatusCompleted),
        errorKind: const Value(null),
      ),
    );
  }

  @override
  Future<void> failAssistant(
    String messageId, {
    required String errorKind,
    required DateTime now,
  }) async {
    await (_db.update(
      _db.localChatMessages,
    )..where((t) => t.id.equals(messageId))).write(
      LocalChatMessagesCompanion(
        status: const Value(chatStatusFailed),
        errorKind: Value(errorKind),
      ),
    );
  }

  @override
  Future<void> markPendingForRetry(
    String messageId, {
    required DateTime now,
  }) async {
    // Explicitní retry nad týmž řádkem (CHC-005) — žádná duplicita.
    await (_db.update(_db.localChatMessages)..where(
          (t) => t.id.equals(messageId) & t.status.equals(chatStatusFailed),
        ))
        .write(
          const LocalChatMessagesCompanion(
            status: Value(chatStatusPending),
            errorKind: Value(null),
          ),
        );
  }

  @override
  Future<List<ChatMessage>> windowBefore(
    String assistantMessageId, {
    int limit = 20,
  }) async {
    final anchor = await (_db.select(
      _db.localChatMessages,
    )..where((t) => t.id.equals(assistantMessageId))).getSingle();
    // Posledních [limit] SENT/COMPLETED zpráv před kotvou (CHC-006);
    // FAILED a PENDING se do modelu neposílají.
    final rows =
        await (_db.select(_db.localChatMessages)
              ..where(
                (t) =>
                    t.conversationId.equals(anchor.conversationId) &
                    t.position.isSmallerThanValue(anchor.position) &
                    t.status.isIn(const [chatStatusSent, chatStatusCompleted]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.position)])
              ..limit(limit))
            .get();
    return [for (final row in rows.reversed) _toModel(row)];
  }

  Future<int> _nextPosition(String conversationId) async {
    final row = await _db
        .customSelect(
          'SELECT COALESCE(MAX(position), -1) + 1 AS next FROM '
          'local_chat_messages WHERE conversation_id = ?',
          variables: [Variable.withString(conversationId)],
        )
        .getSingle();
    return row.data['next']! as int;
  }

  Future<void> _touchConversation(String conversationId, DateTime now) async {
    await (_db.update(
      _db.localChatConversations,
    )..where((t) => t.id.equals(conversationId))).write(
      LocalChatConversationsCompanion(
        updatedAt: Value(now.millisecondsSinceEpoch),
      ),
    );
  }

  ChatMessage _toModel(LocalChatMessageRow row) => ChatMessage(
    id: row.id,
    conversationId: row.conversationId,
    role: row.role,
    content: row.content,
    status: row.status,
    position: row.position,
    errorKind: row.errorKind,
  );
}
