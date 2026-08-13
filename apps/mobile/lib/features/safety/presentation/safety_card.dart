import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/safety_providers.dart';
import '../domain/safety_assessment.dart';

/// Karta dnešního safety vyhodnocení (R5-02, C34). Opatrné formulace bez
/// medicínských tvrzení (SFR-008); doporučující read model — nic nemění
/// a rozhodnutí zůstává uživateli (SFR-009).
class SafetyCard extends ConsumerWidget {
  const SafetyCard({super.key});

  static const Key cardKey = Key('safety_card');

  static Key stateKey(String code) => Key('safety_state_$code');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final assessment = ref.watch(todaySafetyAssessmentProvider);

    return assessment.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (result) => Card(
        key: cardKey,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.safetyHeader,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.safetyStateLabel(result.state.code),
                key: stateKey(result.state.code),
              ),
              for (final flag in result.flags)
                Text('• ${_flagText(l10n, flag)}'),
              const SizedBox(height: 4),
              Text(
                l10n.safetyNotMedical,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _flagText(AppLocalizations l10n, SafetyFlag flag) {
    final label = l10n.safetyFlagLabel(flag.code);
    if (flag.painAreaCode != null) {
      return '$label: ${l10n.checkinPainAreaLabel(flag.painAreaCode!)} '
          '(${flag.painLevel}/5)';
    }
    if (flag.constraintTitle != null) {
      return '$label: ${flag.constraintTitle}';
    }
    return label;
  }
}
