import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/ai_providers.dart';
import '../domain/ai_proposal.dart';

/// AI návrhy plánu (R4-04, C29): žádost o návrh, seznam návrhů a review
/// s důvody a dopady; potvrzení/odmítnutí výhradně explicitní akcí
/// (APL-005), odmítnutí je viditelný stav (APL-006/RSR-012). Selhání AI
/// je bezpečný typovaný stav — manuální cesty nedegradované (R4P-010).
class AiProposalsScreen extends ConsumerWidget {
  const AiProposalsScreen({super.key});

  static const Key screenKey = Key('ai_proposals_screen');
  static const Key emptyKey = Key('ai_proposals_empty');
  static const Key requestButtonKey = Key('ai_request_button');
  static const Key errorBannerKey = Key('ai_error');

  static Key tileKey(String id) => Key('ai_proposal_tile_$id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final proposals = ref.watch(aiProposalsProvider);
    final state = ref.watch(aiScreenControllerProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.aiTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: requestButtonKey,
        onPressed: state is AiWorking
            ? null
            : () => ref
                  .read(aiScreenControllerProvider.notifier)
                  .requestProposal(),
        icon: state is AiWorking
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(l10n.aiRequest),
      ),
      body: Column(
        children: [
          if (_failureText(l10n, state) != null)
            MaterialBanner(
              key: errorBannerKey,
              content: Text(_failureText(l10n, state)!),
              actions: [const SizedBox.shrink()],
            ),
          Expanded(
            child: proposals.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.aiErrorUnavailable)),
              data: (items) => items.isEmpty
                  ? Center(
                      child: Padding(
                        key: emptyKey,
                        padding: const EdgeInsets.all(24),
                        child: Text(l10n.aiEmpty, textAlign: TextAlign.center),
                      ),
                    )
                  : ListView(
                      children: [
                        for (final proposal in items)
                          ListTile(
                            key: tileKey(proposal.id),
                            title: Text(
                              (proposal.payload['planTitle'] as String?) ??
                                  proposal.summary,
                            ),
                            subtitle: Text(
                              '${l10n.aiProposalStatusLabel(proposal.status)}'
                              ' · ${proposal.summary}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) =>
                                  _ProposalReviewSheet(proposalId: proposal.id),
                            ),
                          ),
                        const SizedBox(height: 88),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String? _failureText(AppLocalizations l10n, AiScreenState state) =>
      switch (state) {
        AiRequestFailure(result: ProposalSignInRequired()) =>
          l10n.aiErrorSignIn,
        AiRequestFailure(result: ProposalInvalidOutput()) =>
          l10n.aiErrorInvalidOutput,
        AiRequestFailure() => l10n.aiErrorUnavailable,
        AiDecisionFailure(result: DecisionExpired()) => l10n.aiErrorExpired,
        AiDecisionFailure() => l10n.aiErrorDecision,
        _ => null,
      };
}

/// Review návrhu: summary, workouty s důvody a dopady (den, typ, cviky) a
/// explicitní rozhodnutí — jen ve stavu PROPOSED.
class _ProposalReviewSheet extends ConsumerWidget {
  const _ProposalReviewSheet({required this.proposalId});

  final String proposalId;

  static const Key confirmKey = Key('ai_review_confirm');
  static const Key rejectKey = Key('ai_review_reject');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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

    Future<void> decide(ProposalDecision decision) async {
      await ref
          .read(aiScreenControllerProvider.notifier)
          .decide(proposalId, decision);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            (proposal.payload['planTitle'] as String?) ?? l10n.aiTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(l10n.aiProposalStatusLabel(proposal.status)),
          const SizedBox(height: 8),
          Text(proposal.summary),
          const SizedBox(height: 12),
          Text(
            l10n.aiWorkoutsHeader,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final workout in workouts)
            ListTile(
              dense: true,
              title: Text(
                '${l10n.aiDayLabel((workout['dayOffset'] as int?) ?? 0)} · '
                '${workout['title']}',
              ),
              subtitle: Text(
                [
                  workout['workoutType'],
                  workout['reason'],
                  if (workout['exercises'] is List)
                    '${(workout['exercises'] as List).length}×',
                ].join(' · '),
              ),
            ),
          const SizedBox(height: 16),
          if (proposal.isPending) ...[
            FilledButton(
              key: confirmKey,
              onPressed: () => decide(ProposalDecision.confirm),
              child: Text(l10n.aiConfirm),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: rejectKey,
              onPressed: () => decide(ProposalDecision.reject),
              child: Text(l10n.aiReject),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
