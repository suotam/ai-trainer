import 'package:flutter/foundation.dart';

/// Zpráva konverzace (C47 §2) — read model pro UI i okno do modelu.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.status,
    required this.position,
    this.errorKind,
  });

  final String id;
  final String conversationId;

  /// `USER` / `ASSISTANT` (CHC-003).
  final String role;
  final String content;

  /// `SENT` / `PENDING` / `COMPLETED` / `FAILED` (CHC-003).
  final String status;
  final int position;

  /// Typovaný důvod selhání (CHC-010) — kód `AiApiFailureKind`/`network`.
  final String? errorKind;

  bool get isUser => role == 'USER';
  bool get isFailed => status == 'FAILED';
  bool get isPending => status == 'PENDING';
}

/// Persistence konverzací (C47 §2/§3): device-local, append-only zprávy,
/// jediná aktivní konverzace, osiřelé PENDING → FAILED při otevření
/// (CHC-004).
abstract interface class ChatRepository {
  /// Vrátí id aktivní (nejnovější) konverzace; bez existující ji založí.
  /// Zároveň překlopí osiřelé PENDING zprávy na FAILED (CHC-004).
  Future<String> openActiveConversation({
    required String Function() newId,
    required DateTime now,
  });

  /// Založí novou konverzaci (CHC-012) — starší zůstávají.
  Future<String> startNewConversation({
    required String Function() newId,
    required DateTime now,
  });

  Future<List<ChatMessage>> messages(String conversationId);

  /// Uloží uživatelskou zprávu (SENT) + asistentskou PENDING v jedné
  /// transakci; vrací id asistentské zprávy.
  Future<String> appendExchange(
    String conversationId, {
    required String userText,
    required String Function() newId,
    required DateTime now,
  });

  /// Dokončí PENDING asistentskou zprávu textem odpovědi (CHC-011/013).
  Future<void> completeAssistant(
    String messageId, {
    required String content,
    required DateTime now,
  });

  /// Typované selhání asistentské zprávy (CHC-003/010).
  Future<void> failAssistant(
    String messageId, {
    required String errorKind,
    required DateTime now,
  });

  /// Explicitní retry: FAILED asistentská zpráva zpět na PENDING
  /// (CHC-005) — žádný nový řádek.
  Future<void> markPendingForRetry(String messageId, {required DateTime now});

  /// Okno do modelu (CHC-006/007): posledních [limit] zpráv SENT/COMPLETED
  /// před danou asistentskou zprávou, v pořadí konverzace.
  Future<List<ChatMessage>> windowBefore(
    String assistantMessageId, {
    int limit = 20,
  });
}
