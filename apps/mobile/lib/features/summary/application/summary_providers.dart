import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../activity/application/activity_providers.dart';
import '../../checkin/application/checkin_providers.dart';
import '../domain/weekly_summary.dart';

/// Týdenní souhrn (R5-07, C39): deterministický read model — okna 7+7 dní
/// končící dnes (WKS-007), čísla výhradně z C23 (WKS-002), bez uložených
/// odvozenin (WKS-001). Plně offline (WKS-006).
final weeklySummaryProvider = FutureProvider<WeeklySummary>((ref) async {
  final now = ref.watch(clockProvider)();
  final to = formatLocalDate(now);
  final from = formatLocalDate(now.subtract(const Duration(days: 6)));
  final previousTo = formatLocalDate(now.subtract(const Duration(days: 7)));
  final previousFrom = formatLocalDate(now.subtract(const Duration(days: 13)));

  final activities = ref.watch(activityRepositoryProvider);
  final current = await activities.statisticsForPeriod(
    fromLocalDate: from,
    toLocalDate: to,
  );
  final previous = await activities.statisticsForPeriod(
    fromLocalDate: previousFrom,
    toLocalDate: previousTo,
  );
  final history = await ref
      .watch(dailyCheckInRepositoryProvider)
      .historyForCurrentOwner();
  return buildWeeklySummary(
    fromLocalDate: from,
    toLocalDate: to,
    current: current,
    previous: previous,
    weekCheckIns: [
      for (final checkIn in history)
        if (checkIn.localDate.compareTo(from) >= 0 &&
            checkIn.localDate.compareTo(to) <= 0)
          checkIn,
    ],
  );
}, retry: (retryCount, error) => null);
