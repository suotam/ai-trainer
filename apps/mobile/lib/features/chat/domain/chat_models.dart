import 'package:flutter/foundation.dart';

/// Akce navržená chatem (C48 §4) — device-local evidence s rozhodnutím.
@immutable
class ChatAction {
  const ChatAction({
    required this.id,
    required this.messageId,
    required this.position,
    required this.kind,
    required this.payload,
    required this.status,
    this.error,
  });

  final String id;
  final String messageId;
  final int position;

  /// `UPSERT_SPORT` / `ADD_GOAL` / `SET_AVAILABILITY` / `ADD_CONSTRAINT`.
  final String kind;

  /// Kanonický validovaný payload (CHA-003).
  final Map<String, Object?> payload;

  /// `PROPOSED` / `APPLIED` / `REJECTED` / `FAILED` (C48 §4).
  final String status;
  final String? error;

  bool get isProposed => status == 'PROPOSED';
  bool get isFailed => status == 'FAILED';
}

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
    this.actions = const [],
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

  /// Akce navržené touto zprávou (C48) — jen u asistentských COMPLETED.
  final List<ChatAction> actions;

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
  /// před danou asistentskou zprávou, v pořadí konverzace, včetně akcí
  /// a jejich rozhodnutí (model musí vidět, co už je APPLIED).
  Future<List<ChatMessage>> windowBefore(
    String assistantMessageId, {
    int limit = 20,
  });

  /// Uloží kanonické akce k asistentské zprávě jako PROPOSED (CHA-006/008);
  /// vrací id vytvořených akcí v pořadí.
  Future<List<String>> addActions(
    String messageId,
    List<Map<String, Object?>> canonicalActions, {
    required String Function() newId,
    required DateTime now,
  });

  Future<ChatAction?> actionById(String actionId);

  /// Rozhodnutí/výsledek akce (C48 §4): APPLIED / REJECTED / FAILED(+error).
  /// [payload] volitelně nahrazuje kanonický payload (C49 §3 — REQUEST
  /// akce si po úspěchu ukládá `proposalId`).
  Future<void> setActionStatus(
    String actionId, {
    required String status,
    String? error,
    Map<String, Object?>? payload,
    required DateTime now,
  });
}
