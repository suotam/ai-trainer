import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/workout_completion_providers.dart';
import '../domain/workout_history.dart';
import 'session_time_format.dart';

/// Lokální historie dokončených workoutů (R1-06, read-only). Bez sítě a
/// backendu — čte jen history read model.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static const Key screenKey = Key('history_screen');
  static const Key loadingKey = Key('history_loading');
  static const Key emptyKey = Key('history_empty');
  static const Key errorKey = Key('history_error');
  static const Key listKey = Key('history_list');

  static Key entryKey(String sessionId) => Key('history_entry_$sessionId');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(completedWorkoutsProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: history.when(
        loading: () => Center(
          child: Column(
            key: loadingKey,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.historyLoading),
            ],
          ),
        ),
        error: (_, _) => Center(
          child: Padding(
            key: errorKey,
            padding: const EdgeInsets.all(24),
            child: Text(l10n.historyError, textAlign: TextAlign.center),
          ),
        ),
        data: (entries) => entries.isEmpty
            ? Center(
                child: Padding(
                  key: emptyKey,
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.historyEmpty, textAlign: TextAlign.center),
                ),
              )
            : _HistoryList(entries: entries),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.entries});

  final List<WorkoutHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView.builder(
      key: HistoryScreen.listKey,
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          key: HistoryScreen.entryKey(entry.workoutSessionId),
          child: ListTile(
            title: Text(entry.title),
            subtitle: Text(
              '${l10n.historyCompletedAt(formatStartedAt(entry.completedAt))}'
              ' · '
              '${l10n.historyStepSummary(entry.completedStepCount, entry.totalStepCount)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(
              AppRoutes.completedWorkoutLocation(entry.workoutSessionId),
            ),
          ),
        );
      },
    );
  }
}
