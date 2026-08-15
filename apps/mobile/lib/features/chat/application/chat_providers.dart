import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../ai/application/ai_providers.dart';
import '../../ai/data/anthropic_direct_client.dart';
import '../../ai/data/http_ai_api_client.dart';
import '../../auth/domain/auth_api_client.dart';
import '../data/drift_chat_repository.dart';
import '../domain/chat_ai_client.dart';
import '../domain/chat_models.dart';

/// Composition chat vrstvy (R7-02, C47). Jediná cesta k modelu = BYOK
/// adapter (BYK-004); konverzace jsou device-local (CHC-001).
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => DriftChatRepository(ref.watch(appDatabaseProvider)),
);

final chatAiClientProvider = Provider<ChatAiClient>(
  (ref) => AnthropicDirectClient(
    keyStore: ref.watch(byokKeyStoreProvider),
    httpClient: http.Client(),
  ),
);

/// Přítomnost klíče pro poctivý hint (CHC-009) — negatí chat, jen UI stav.
final byokKeyPresentProvider = FutureProvider<bool>((ref) async {
  try {
    return await ref.watch(byokKeyStoreProvider).read() != null;
  } catch (_) {
    return false;
  }
});

/// Aktivní konverzace (CHC-012); otevření překlápí osiřelé PENDING na
/// FAILED (CHC-004).
final activeChatConversationProvider = FutureProvider<String>(
  (ref) => ref
      .watch(chatRepositoryProvider)
      .openActiveConversation(
        newId: ref.watch(idGeneratorProvider).newId,
        now: ref.watch(clockProvider)(),
      ),
);

final chatMessagesProvider = FutureProvider<List<ChatMessage>>((ref) async {
  final conversationId = await ref.watch(activeChatConversationProvider.future);
  return ref.watch(chatRepositoryProvider).messages(conversationId);
});

/// Stav odesílání — jediná operace v letu (R7P-009: jedno zadání = jedno
/// volání modelu, žádný auto-retry).
class ChatController extends Notifier<bool> {
  bool _inFlight = false;

  @override
  bool build() => false;

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _inFlight) {
      return;
    }
    await _run(() async {
      final repo = ref.read(chatRepositoryProvider);
      final now = ref.read(clockProvider)();
      final conversationId = await ref.read(
        activeChatConversationProvider.future,
      );
      final assistantId = await repo.appendExchange(
        conversationId,
        userText: trimmed,
        newId: ref.read(idGeneratorProvider).newId,
        now: now,
      );
      ref.invalidate(chatMessagesProvider);
      await _resolve(assistantId);
    });
  }

  /// Explicitní retry selhané odpovědi (CHC-005).
  Future<void> retry(String assistantMessageId) async {
    if (_inFlight) {
      return;
    }
    await _run(() async {
      await ref
          .read(chatRepositoryProvider)
          .markPendingForRetry(
            assistantMessageId,
            now: ref.read(clockProvider)(),
          );
      ref.invalidate(chatMessagesProvider);
      await _resolve(assistantMessageId);
    });
  }

  /// Nová konverzace (CHC-012) — starší zůstává v DB.
  Future<void> startNewConversation() async {
    if (_inFlight) {
      return;
    }
    await ref
        .read(chatRepositoryProvider)
        .startNewConversation(
          newId: ref.read(idGeneratorProvider).newId,
          now: ref.read(clockProvider)(),
        );
    ref
      ..invalidate(activeChatConversationProvider)
      ..invalidate(chatMessagesProvider);
  }

  Future<void> _resolve(String assistantId) async {
    final repo = ref.read(chatRepositoryProvider);
    final now = ref.read(clockProvider)();
    final window = await repo.windowBefore(assistantId);
    // Minimalizovaný profilový kontext = C27 base payload (CHC-006).
    final context = await ref
        .read(aiContextBuilderProvider)
        .buildPlanProposalContext(now: now);
    try {
      final reply = await ref
          .read(chatAiClientProvider)
          .chat(
            turns: [
              for (final message in window)
                (role: message.role, content: message.content),
            ],
            profileContext: context.payload,
          );
      await repo.completeAssistant(assistantId, content: reply, now: now);
    } on AiApiFailure catch (failure) {
      await repo.failAssistant(
        assistantId,
        errorKind: failure.kind.name,
        now: now,
      );
    } on AuthApiFailure {
      await repo.failAssistant(assistantId, errorKind: 'network', now: now);
    } catch (_) {
      // Raw výjimka se nepropaguje do UI (CHC-010).
      await repo.failAssistant(assistantId, errorKind: 'network', now: now);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    _inFlight = true;
    state = true;
    try {
      await action();
    } finally {
      _inFlight = false;
      state = false;
      ref.invalidate(chatMessagesProvider);
    }
  }
}

final chatControllerProvider = NotifierProvider<ChatController, bool>(
  ChatController.new,
);
