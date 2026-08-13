import 'package:flutter/foundation.dart';

import '../../safety/domain/safety_assessment.dart';

/// P0 stavy doporučení dne (C35 §2, TDR-010).
enum TodayRecommendationState {
  checkInMissing('CHECK_IN_MISSING'),
  considerRest('CONSIDER_REST'),
  considerLighterDay('CONSIDER_LIGHTER_DAY'),
  trainAsPlanned('TRAIN_AS_PLANNED'),
  nothingPlanned('NOTHING_PLANNED');

  const TodayRecommendationState(this.code);

  final String code;
}

/// Deterministické doporučení dne (C35): mapování C34 safety stavu +
/// kontext plánu. Nic nemění (TDR-005); důvody jsou C34 flags beze změny
/// (TDR-002/006).
@immutable
class TodayRecommendation {
  const TodayRecommendation({
    required this.state,
    required this.reasons,
    required this.plannedWorkoutCount,
  });

  final TodayRecommendationState state;
  final List<SafetyFlag> reasons;
  final int plannedWorkoutCount;
}

/// Čistá mapovací funkce (C35 §2, TDR-001): jediný zdroj signálů je C34
/// (TDR-002); safety má konzervativní přednost před plánem (TDR-003).
TodayRecommendation evaluateTodayRecommendation({
  required SafetyAssessment safety,
  required int plannedWorkoutCount,
}) {
  final state = switch (safety.state) {
    SafetyState.insufficientInformation =>
      TodayRecommendationState.checkInMissing,
    SafetyState.doNotRecommendActivity => TodayRecommendationState.considerRest,
    SafetyState.caution => TodayRecommendationState.considerLighterDay,
    SafetyState.safeWithCurrentInformation =>
      plannedWorkoutCount > 0
          ? TodayRecommendationState.trainAsPlanned
          : TodayRecommendationState.nothingPlanned,
  };
  return TodayRecommendation(
    state: state,
    reasons: safety.flags,
    plannedWorkoutCount: plannedWorkoutCount,
  );
}
