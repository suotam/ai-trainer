import 'package:flutter/foundation.dart';

import '../../availability/domain/availability_profile.dart';
import '../../checkin/domain/daily_check_in.dart';

/// P0 stavy safety vyhodnocení (C34 §2, podmnožina modelu §32.2).
/// `SAFE_WITH_CURRENT_INFORMATION` není medicínská záruka (§32.3).
enum SafetyState {
  insufficientInformation('INSUFFICIENT_INFORMATION'),
  safeWithCurrentInformation('SAFE_WITH_CURRENT_INFORMATION'),
  caution('CAUTION'),
  doNotRecommendActivity('DO_NOT_RECOMMEND_ACTIVITY');

  const SafetyState(this.code);

  final String code;
}

/// Stabilní P0 flag kódy (C34 §2, SFR-011).
abstract final class SafetyFlagCodes {
  static const String severePain = 'SEVERE_PAIN';
  static const String painReported = 'PAIN_REPORTED';
  static const String veryHighFatigue = 'VERY_HIGH_FATIGUE';
  static const String highFatigue = 'HIGH_FATIGUE';
  static const String lowEnergy = 'LOW_ENERGY';
  static const String poorSleep = 'POOR_SLEEP';
  static const String activeConstraint = 'ACTIVE_CONSTRAINT';
}

/// Bezpečnostní příznak se zdrojem (SFR-005/006).
@immutable
class SafetyFlag {
  const SafetyFlag(
    this.code, {
    this.painAreaCode,
    this.painLevel,
    this.constraintTitle,
  });

  final String code;
  final String? painAreaCode;
  final int? painLevel;
  final String? constraintTitle;
}

/// Deterministický výsledek safety pravidel (C34 §2) — doporučující read
/// model; nic nemění a rozhodnutí zůstává uživateli (SFR-009).
@immutable
class SafetyAssessment {
  const SafetyAssessment({required this.state, required this.flags});

  final SafetyState state;
  final List<SafetyFlag> flags;
}

/// Čistá deterministická P0 pravidla (C34 §3, SFR-001): dnešní check-in +
/// aktivní omezení → assessment. Konzervativní směr (SFR-002); klinické
/// stavy modelu §31 jsou vědomě mimo P0 (SFR-007). AI výsledek nikdy
/// nepřepisuje (SFR-003).
SafetyAssessment evaluateSafety({
  required DailyCheckIn? todayCheckIn,
  required List<BasicConstraint> activeConstraints,
}) {
  final flags = <SafetyFlag>[];
  var stop = false;
  var caution = false;

  if (todayCheckIn != null) {
    final pain = todayCheckIn.painLevel;
    if (pain != null && pain >= 4) {
      flags.add(
        SafetyFlag(
          SafetyFlagCodes.severePain,
          painAreaCode: todayCheckIn.painAreaCode,
          painLevel: pain,
        ),
      );
      stop = true;
    }
    if (todayCheckIn.fatigueLevel == 5) {
      flags.add(const SafetyFlag(SafetyFlagCodes.veryHighFatigue));
      stop = true;
    }
    if (pain != null && pain >= 1 && pain <= 3) {
      flags.add(
        SafetyFlag(
          SafetyFlagCodes.painReported,
          painAreaCode: todayCheckIn.painAreaCode,
          painLevel: pain,
        ),
      );
      caution = true;
    }
    if (todayCheckIn.fatigueLevel == 4) {
      flags.add(const SafetyFlag(SafetyFlagCodes.highFatigue));
      caution = true;
    }
    if (todayCheckIn.energyLevel <= 2) {
      flags.add(const SafetyFlag(SafetyFlagCodes.lowEnergy));
      caution = true;
    }
    final sleep = todayCheckIn.sleepQuality;
    if (sleep != null && sleep <= 2) {
      flags.add(const SafetyFlag(SafetyFlagCodes.poorSleep));
      caution = true;
    }
  }

  // Aktivní omezení se reportují vždy (SFR-006) — i bez check-inu.
  for (final constraint in activeConstraints) {
    flags.add(
      SafetyFlag(
        SafetyFlagCodes.activeConstraint,
        constraintTitle: constraint.title,
      ),
    );
    caution = true;
  }

  // Bez check-inu je stav vždy poctivé „nevíme" (SFR-004) — nikdy SAFE.
  final state = todayCheckIn == null
      ? SafetyState.insufficientInformation
      : stop
      ? SafetyState.doNotRecommendActivity
      : caution
      ? SafetyState.caution
      : SafetyState.safeWithCurrentInformation;
  return SafetyAssessment(state: state, flags: List.unmodifiable(flags));
}
