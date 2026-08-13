import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../availability/application/availability_providers.dart';
import '../../checkin/application/checkin_providers.dart';
import '../domain/safety_assessment.dart';

/// Dnešní safety vyhodnocení (R5-02, C34): čistá pravidla nad dnešním
/// check-inem a aktivními omezeními — žádná persistence (SFR-010),
/// žádná AI (SFR-003).
final todaySafetyAssessmentProvider = FutureProvider<SafetyAssessment>((
  ref,
) async {
  final checkIn = await ref.watch(todayCheckInProvider.future);
  final constraints = await ref.watch(constraintsProvider.future);
  return evaluateSafety(
    todayCheckIn: checkIn,
    activeConstraints: [
      for (final constraint in constraints)
        if (constraint.status == 'ACTIVE') constraint,
    ],
  );
}, retry: (retryCount, error) => null);
