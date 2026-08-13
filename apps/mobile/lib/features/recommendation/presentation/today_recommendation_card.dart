import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../safety/presentation/safety_card.dart';
import '../application/recommendation_providers.dart';
import '../domain/today_recommendation.dart';

/// Doporučení dne na Today (R5-03, C35): jedna poctivá věta s důvody
/// (C34 flags se zdrojem, TDR-006), opatrná formulace (TDR-007). Nic
/// nemění (TDR-005); nedostupný podklad kartu skryje — Today nikdy
/// neshodí (TDR-009/011).
class TodayRecommendationCard extends ConsumerWidget {
  const TodayRecommendationCard({super.key});

  static const Key cardKey = Key('today_recommendation');
  static const Key checkInCtaKey = Key('today_recommendation_checkin_cta');

  static Key stateKey(String code) => Key('today_recommendation_$code');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recommendation = ref.watch(todayRecommendationProvider);

    return recommendation.when(
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
                l10n.todayRecoLabel(result.state.code),
                key: stateKey(result.state.code),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final reason in result.reasons)
                Text('• ${safetyFlagText(l10n, reason)}'),
              if (result.state == TodayRecommendationState.checkInMissing)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: checkInCtaKey,
                    onPressed: () => context.push(AppRoutes.checkInPath),
                    child: Text(l10n.todayRecoCheckinCta),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
