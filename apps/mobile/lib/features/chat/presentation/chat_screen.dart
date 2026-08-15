import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/chat_providers.dart';
import '../domain/chat_models.dart';

/// Chat obrazovka (R7-02, C47): konverzace s typovanými stavy (CHC-003),
/// explicitní retry (CHC-005), poctivý prázdný stav i chybějící klíč
/// (CHC-009). Chat v tomto slice nemění žádná data (CHC-002).
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  static const Key screenKey = Key('chat_screen');
  static const Key emptyKey = Key('chat_empty');
  static const Key inputKey = Key('chat_input');
  static const Key sendButtonKey = Key('chat_send');
  static const Key newConversationKey = Key('chat_new_conversation');
  static const Key noKeyBannerKey = Key('chat_no_key_banner');

  static Key bubbleKey(String messageId) => Key('chat_bubble_$messageId');
  static Key retryKey(String messageId) => Key('chat_retry_$messageId');

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    _controller.clear();
    await ref.read(chatControllerProvider.notifier).send(text);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messages = ref.watch(chatMessagesProvider);
    final sending = ref.watch(chatControllerProvider);
    final hasKey = ref.watch(byokKeyPresentProvider).value ?? true;

    return Scaffold(
      key: ChatScreen.screenKey,
      appBar: AppBar(
        title: Text(l10n.chatTitle),
        actions: [
          IconButton(
            key: ChatScreen.newConversationKey,
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: l10n.chatNewConversation,
            onPressed: sending
                ? null
                : () => ref
                      .read(chatControllerProvider.notifier)
                      .startNewConversation(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!hasKey)
            MaterialBanner(
              key: ChatScreen.noKeyBannerKey,
              content: Text(l10n.chatNoKey),
              actions: [
                TextButton(
                  onPressed: () => context.push(AppRoutes.aiKeyPath),
                  child: Text(l10n.byokTitle),
                ),
              ],
            ),
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.aiErrorUnavailable)),
              data: (items) => items.isEmpty
                  ? Center(
                      child: Padding(
                        key: ChatScreen.emptyKey,
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.chatEmpty,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      children: [
                        for (final message in items)
                          _MessageBubble(message: message),
                      ],
                    ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: ChatScreen.inputKey,
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sending ? null : _send(),
                      decoration: InputDecoration(
                        hintText: l10n.chatInputHint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    key: ChatScreen.sendButtonKey,
                    icon: sending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: sending ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isUser = message.isUser;

    final Widget content;
    if (message.isPending) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(l10n.chatThinking),
        ],
      );
    } else if (message.isFailed) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_failureText(l10n, message.errorKind)),
          TextButton(
            key: ChatScreen.retryKey(message.id),
            onPressed: () =>
                ref.read(chatControllerProvider.notifier).retry(message.id),
            child: Text(l10n.chatRetry),
          ),
        ],
      );
    } else {
      content = Text(message.content);
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        key: ChatScreen.bubbleKey(message.id),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: content,
      ),
    );
  }

  /// Typovaná selhání (CHC-010) mapovaná na poctivé hlášky C46 vzoru.
  String _failureText(AppLocalizations l10n, String? errorKind) =>
      switch (errorKind) {
        'keyMissing' => l10n.aiErrorKeyMissing,
        'invalidKey' => l10n.aiErrorKeyInvalid,
        'noCredit' => l10n.aiErrorNoCredit,
        'invalidOutput' => l10n.aiErrorInvalidOutput,
        _ => l10n.chatFailed,
      };
}
