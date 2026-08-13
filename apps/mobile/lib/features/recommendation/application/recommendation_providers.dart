import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../safety/application/safety_providers.dart';
import '../../workouts/application/today_providers.dart';
import '../domain/today_recommendation.dart';

/// Doporučení dne (R5-03, C35): deterministické mapování C34 safety +
/// dnešního plánu (R1 read model). Žádná persistence ani AI (TDR-001);
/// plně offline (TDR-008).
final todayRecommendationProvider = FutureProvider<TodayRecommendation>((
  ref,
) async {
  final safety = await ref.watch(todaySafetyAssessmentProvider.future);
  final todayWorkouts = await ref.watch(todayWorkoutsProvider.future);
  return evaluateTodayRecommendation(
    safety: safety,
    plannedWorkoutCount: todayWorkouts.length,
  );
}, retry: (retryCount, error) => null);
