import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/conflict_resolution_service.dart';
import '../domain/sync_push_models.dart';

/// Conflict/rejection sekce (R2-06, C12 §6): lidský popis entity, žádné
/// technické diffy (CRC-011); jen explicitní akce — USE_LOCAL u konfliktu,
/// CANCEL u obojího (CRC-002/003/008). Prázdný stav se nezobrazuje.
class SyncIssuesSection extends ConsumerWidget {
  const SyncIssuesSection({super.key});

  static const Key sectionKey = Key('sync_issues_section');

  static Key useLocalKey(String outboxId) =>
      Key('sync_issue_use_local_$outboxId');

  static Key cancelKey(String outboxId) => Key('sync_issue_cancel_$outboxId');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(unresolvedSyncItemsProvider);

    return items.when(
      loading: () => const SizedBox.shrink(),
      // Bezpečná chyba: sekce se nezobrazí; stav zůstává v DB (CRC-013).
      error: (_, _) => const SizedBox.shrink(),
      data: (unresolved) => unresolved.isEmpty
          ? const SizedBox.shrink()
          : Column(
              key: sectionKey,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.syncIssuesTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final item in unresolved) _IssueCard(item: item),
              ],
            ),
    );
  }
}

class _IssueCard extends ConsumerWidget {
  const _IssueCard({required this.item});

  final UnresolvedSyncItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    Future<void> resolve(
      Future<void> Function(UnresolvedSyncItem) action,
    ) async {
      await action(item);
      ref.invalidate(unresolvedSyncItemsProvider);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(
              item.isConflict
                  ? l10n.syncIssueConflictLabel
                  : l10n.syncIssueRejectedLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (item.isConflict)
                  OutlinedButton(
                    key: SyncIssuesSection.useLocalKey(item.outboxId),
                    onPressed: () => resolve(
                      ref.read(conflictResolutionServiceProvider).useLocal,
                    ),
                    child: Text(l10n.syncIssueUseLocal),
                  ),
                TextButton(
                  key: SyncIssuesSection.cancelKey(item.outboxId),
                  onPressed: () => resolve(
                    ref.read(conflictResolutionServiceProvider).cancel,
                  ),
                  child: Text(l10n.syncIssueDiscard),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
