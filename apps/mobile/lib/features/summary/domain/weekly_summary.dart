import 'package:flutter/foundation.dart';

import '../../activity/domain/manual_activity.dart';
import '../../checkin/domain/daily_check_in.dart';

/// Typované vysvětlení progresu (C39 §2.3, WKS-003/010) — jen fakta
/// dokončených workoutů dvou oken; žádné predikce ani skóre.
enum ProgressExplanation {
  noData('NO_DATA'),
  improving('IMPROVING'),
  steady('STEADY'),
  slowing('SLOWING');

  const ProgressExplanation(this.code);

  final String code;
}

/// Check-in agregáty týdne (C39 §2.2) — bez volných textů (WKS-009).
@immutable
class CheckInWeekAggregates {
  const CheckInWeekAggregates({
    required this.checkInCount,
    this.averageEnergy,
    this.averageFatigue,
    required this.painDays,
  });

  final int checkInCount;
  final double? averageEnergy;
  final double? averageFatigue;
  final int painDays;
}

/// Deterministický týdenní souhrn (C39): fakta aktuálních 7 dní +
/// trend vůči předchozím 7 dnům. Nic nemění (WKS-008).
@immutable
class WeeklySummary {
  const WeeklySummary({
    required this.fromLocalDate,
    required this.toLocalDate,
    required this.current,
    required this.previous,
    required this.checkIns,
    required this.explanation,
  });

  final String fromLocalDate;
  final String toLocalDate;
  final ProgressStatistics current;
  final ProgressStatistics previous;
  final CheckInWeekAggregates checkIns;
  final ProgressExplanation explanation;
}

/// Čisté složení souhrnu (WKS-001/002): čísla výhradně z C23 oken,
/// vysvětlení deterministickým mapováním (§2.3).
WeeklySummary buildWeeklySummary({
  required String fromLocalDate,
  required String toLocalDate,
  required ProgressStatistics current,
  required ProgressStatistics previous,
  required List<DailyCheckIn> weekCheckIns,
}) {
  final explanation =
      current.completedCount == 0 && previous.completedCount == 0
      ? ProgressExplanation.noData
      : current.completedCount > previous.completedCount
      ? ProgressExplanation.improving
      : current.completedCount == previous.completedCount
      ? ProgressExplanation.steady
      : ProgressExplanation.slowing;

  double? average(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) {
      return null;
    }
    // Deterministické zaokrouhlení na 1 desetinu (WKS-013).
    return (list.reduce((a, b) => a + b) / list.length * 10).round() / 10;
  }

  return WeeklySummary(
    fromLocalDate: fromLocalDate,
    toLocalDate: toLocalDate,
    current: current,
    previous: previous,
    checkIns: CheckInWeekAggregates(
      checkInCount: weekCheckIns.length,
      averageEnergy: average(weekCheckIns.map((c) => c.energyLevel)),
      averageFatigue: average(weekCheckIns.map((c) => c.fatigueLevel)),
      painDays: weekCheckIns.where((c) => c.hasPain).length,
    ),
    explanation: explanation,
  );
}
