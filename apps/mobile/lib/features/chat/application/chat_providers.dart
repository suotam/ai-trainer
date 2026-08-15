import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../ai/application/ai_providers.dart';
import '../../ai/data/anthropic_direct_client.dart';
import '../../ai/data/http_ai_api_client.dart';
import '../../auth/domain/auth_api_client.dart';
import '../../availability/application/availability_providers.dart';
import '../../goals/application/goals_providers.dart';
import '../../sports/application/sports_profile_providers.dart';
import '../data/chat_reply_validator.dart';
import '../data/drift_chat_repository.dart';
import '../domain/chat_ai_client.dart';
import '../domain/chat_models.dart';
import 'chat_action_executor.dart';

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

/// Provedení potvrzených akcí výhradně existujícími repos (CHA-001).
final chatActionExecutorProvider = Provider<ChatActionExecutor>(
  (ref) => ChatActionExecutor(
    ref.watch(userSportRepositoryProvider),
    ref.watch(goalRepositoryProvider),
    ref.watch(availabilityProfileRepositoryProvider),
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
      final raw = await ref
          .read(chatAiClientProvider)
          .chat(
            turns: [
              for (final message in window)
                (role: message.role, content: message.content),
            ],
            profileContext: context.payload,
          );
      // Striktní validace tvaru s akcemi (C48 §2, CHA-003) — nevalidní
      // celek = typované selhání s retry, nikdy částečné přijetí.
      final reply = validateChatReply(raw);
      if (reply == null) {
        await repo.failAssistant(
          assistantId,
          errorKind: 'invalidOutput',
          now: now,
        );
        return;
      }
      await repo.completeAssistant(assistantId, content: reply.text, now: now);
      if (reply.actions.isNotEmpty) {
        await repo.addActions(
          assistantId,
          reply.actions,
          newId: ref.read(idGeneratorProvider).newId,
          now: now,
        );
      }
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

  /// Potvrzení akce = provedení existujícími repos v témže kroku
  /// (C48 §4, CHA-005/006); výsledek je trvale viditelný stav.
  Future<void> confirmAction(String actionId) async {
    if (_inFlight) {
      return;
    }
    await _run(() async {
      final repo = ref.read(chatRepositoryProvider);
      final action = await repo.actionById(actionId);
      if (action == null || !(action.isProposed || action.isFailed)) {
        return;
      }
      final now = ref.read(clockProvider)();
      final result = await ref
          .read(chatActionExecutorProvider)
          .apply(
            action.payload,
            newId: ref.read(idGeneratorProvider).newId,
            now: now,
          );
      switch (result) {
        case ChatActionApplied():
          await repo.setActionStatus(actionId, status: 'APPLIED', now: now);
          // Profil je okamžitě vidět v obrazovkách (CHA-012).
          ref
            ..invalidate(userSportsProvider)
            ..invalidate(goalsProvider)
            ..invalidate(availabilityWeekProvider)
            ..invalidate(constraintsProvider);
        case ChatActionRejectedByDomain(:final reason):
          await repo.setActionStatus(
            actionId,
            status: 'FAILED',
            error: reason,
            now: now,
          );
      }
    });
  }

  /// Odmítnutí akce — viditelný trvalý stav (CHA-005/008).
  Future<void> rejectAction(String actionId) async {
    if (_inFlight) {
      return;
    }
    await _run(() async {
      final repo = ref.read(chatRepositoryProvider);
      final action = await repo.actionById(actionId);
      if (action == null || !action.isProposed) {
        return;
      }
      await repo.setActionStatus(
        actionId,
        status: 'REJECTED',
        now: ref.read(clockProvider)(),
      );
    });
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
