/// Jeden tah konverzace pro model (C47 §4).
typedef ChatTurn = ({String role, String content});

/// Port chat volání modelu (C47 §5): jediná cesta = BYOK adapter (C46).
/// Selhání jsou typovaná ([AiApiFailure]/[AuthApiFailure] vzory C46);
/// odpověď je volný text — akce vlastní C48 (CHC-002).
abstract interface class ChatAiClient {
  Future<String> chat({
    required List<ChatTurn> turns,
    required Map<String, Object?> profileContext,
  });
}
