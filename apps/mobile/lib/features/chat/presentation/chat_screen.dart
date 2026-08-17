import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../ai/application/ai_providers.dart';
import '../../ai/domain/ai_proposal.dart';
import '../../ai/presentation/proposed_workout_structure.dart';
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
          // Denní smyčka (R7-05, C50 §5): kalendář a Today na jeden tap.
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: l10n.calendarOpenTooltip,
            onPressed: () => context.push(AppRoutes.calendarPath),
          ),
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: l10n.todayOpenTooltip,
            onPressed: () => context.push(AppRoutes.todayPath),
          ),
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
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message.content),
          // Navržené akce (C48): potvrditelné karty — efekt vzniká až
          // potvrzením (CHA-005/006); rozhodnutí je trvale viditelné.
          for (final action in message.actions) _ActionCard(action: action),
        ],
      );
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

/// Karta navržené akce (C48 §4): druh + shrnutí polí + rozhodnutí per
/// akce výhradně explicitním tapem (CHA-005).
class _ActionCard extends ConsumerWidget {
  const _ActionCard({required this.action});

  final ChatAction action;

  static Key confirmKey(String actionId) =>
      Key('chat_action_confirm_$actionId');
  static Key rejectKey(String actionId) => Key('chat_action_reject_$actionId');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(chatControllerProvider.notifier);
    final busy = ref.watch(chatControllerProvider);
    final isRequest =
        action.kind == 'REQUEST_PLAN' || action.kind == 'REQUEST_ADJUSTMENT';

    // REQUEST akce (C49 §3): úspěch = karta návrhu z C29 úložiště
    // (CHP-001/009); selhání níže standardní FAILED větví s retry.
    if (isRequest && action.status == 'APPLIED') {
      final proposalId = action.payload['proposalId'];
      return proposalId is String
          ? _ProposalCard(proposalId: proposalId)
          : const SizedBox.shrink();
    }
    if (isRequest && action.status == 'PROPOSED') {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(l10n.chatPreparingProposal),
          ],
        ),
      );
    }

    return Card(
      key: Key('chat_action_${action.id}'),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_kindLabel(l10n), style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(_summary(), style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            switch (action.status) {
              'PROPOSED' => Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton(
                    key: confirmKey(action.id),
                    onPressed: busy
                        ? null
                        : () => controller.confirmAction(action.id),
                    child: Text(l10n.chatActionConfirm),
                  ),
                  OutlinedButton(
                    key: rejectKey(action.id),
                    onPressed: busy
                        ? null
                        : () => controller.rejectAction(action.id),
                    child: Text(l10n.chatActionReject),
                  ),
                ],
              ),
              'APPLIED' => Text(
                l10n.chatActionApplied,
                style: TextStyle(color: theme.colorScheme.primary),
              ),
              'REJECTED' => Text(l10n.chatActionRejected),
              // FAILED: poctivý stav + explicitní nový pokus (CHA-007).
              _ => Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.chatActionFailed,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  TextButton(
                    key: confirmKey(action.id),
                    onPressed: busy
                        ? null
                        : () => controller.confirmAction(action.id),
                    child: Text(l10n.chatRetry),
                  ),
                ],
              ),
            },
          ],
        ),
      ),
    );
  }

  String _kindLabel(AppLocalizations l10n) => switch (action.kind) {
    'UPSERT_SPORT' => l10n.chatActionSport,
    'ADD_GOAL' => l10n.chatActionGoal,
    'SET_AVAILABILITY' => l10n.chatActionAvailability,
    'REQUEST_PLAN' => l10n.chatActionPlan,
    'REQUEST_ADJUSTMENT' => l10n.chatActionAdjustment,
    _ => l10n.chatActionConstraint,
  };

  /// Shrnutí polí akce — přesné hodnoty, žádná interpretace.
  String _summary() {
    final p = action.payload;
    final parts = [
      for (final entry in p.entries)
        if (entry.key != 'action') '${entry.value}',
    ];
    return parts.join(' · ');
  }
}

/// Karta návrhu plánu/úpravy v konverzaci (C49 §3): čte výhradně C29
/// úložiště (CHP-001/009); rozhodnutí = táž C29 operace jako na AI
/// obrazovce (CHP-007) — potvrzení provádí C30/C38 se safety vetem.
class _ProposalCard extends ConsumerWidget {
  const _ProposalCard({required this.proposalId});

  final String proposalId;

  static Key confirmKey(String id) => Key('chat_proposal_confirm_$id');
  static Key rejectKey(String id) => Key('chat_proposal_reject_$id');
  static Key retryKey(String id) => Key('chat_proposal_retry_$id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final busy = ref.watch(chatControllerProvider);
    final proposal = ref
        .watch(aiProposalsProvider)
        .value
        ?.where((p) => p.id == proposalId)
        .firstOrNull;
    if (proposal == null) {
      return const SizedBox.shrink();
    }
    final workouts =
        (proposal.payload['workouts'] as List?)?.cast<Map>() ?? const [];
    final operations =
        (proposal.payload['operations'] as List?)?.cast<Map>() ?? const [];
    final decide = ref.read(aiScreenControllerProvider.notifier);

    return Card(
      key: Key('chat_proposal_$proposalId'),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (proposal.payload['planTitle'] as String?) ??
                  (proposal.isAdjustment
                      ? l10n.chatActionAdjustment
                      : l10n.chatActionPlan),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.aiProposalStatusLabel(proposal.status),
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(proposal.summary, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            for (final workout in workouts) ...[
              Text(
                '${l10n.aiDayLabel((workout['dayOffset'] as int?) ?? 0)} · '
                '${workout['title']} — ${workout['reason']}',
                style: theme.textTheme.bodySmall,
              ),
              // Struktura v2 (C52 §6): sekce → kroky čitelně.
              ProposedWorkoutStructure(workout: workout),
            ],
            for (final operation in operations) ...[
              Text(
                '${l10n.aiOperationLabel('${operation['operation']}')} — '
                '${operation['reason']}',
                style: theme.textTheme.bodySmall,
              ),
              if (operation['workout'] is Map)
                ProposedWorkoutStructure(workout: operation['workout'] as Map),
            ],
            const SizedBox(height: 8),
            if (proposal.isPending)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton(
                    key: confirmKey(proposalId),
                    onPressed: busy
                        ? null
                        : () => decide.decide(
                            proposalId,
                            ProposalDecision.confirm,
                          ),
                    child: Text(l10n.aiConfirm),
                  ),
                  OutlinedButton(
                    key: rejectKey(proposalId),
                    onPressed: busy
                        ? null
                        : () => decide.decide(
                            proposalId,
                            ProposalDecision.reject,
                          ),
                    child: Text(l10n.aiReject),
                  ),
                ],
              ),
            // Po selhání provedení jen explicitní nový pokus (CSE-007).
            if (proposal.canRetryExecution)
              TextButton(
                key: retryKey(proposalId),
                onPressed: busy
                    ? null
                    : () => decide.executeProposal(proposalId),
                child: Text(l10n.aiRetry),
              ),
          ],
        ),
      ),
    );
  }
}
