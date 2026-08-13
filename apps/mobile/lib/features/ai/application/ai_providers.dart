import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../activity/application/activity_providers.dart';
import '../../availability/application/availability_providers.dart';
import '../../goals/application/goals_providers.dart';
import '../../sports/application/sports_profile_providers.dart';
import '../data/drift_ai_context_builder.dart';
import '../domain/ai_context.dart';

/// Composition AI vrstvy (R4-02, C27). Builder je čistě lokální (ACX-014).
final aiContextBuilderProvider = Provider<AiContextBuilder>(
  (ref) => DriftAiContextBuilder(
    ref.watch(userSportRepositoryProvider),
    ref.watch(goalRepositoryProvider),
    ref.watch(availabilityProfileRepositoryProvider),
    ref.watch(activityRepositoryProvider),
  ),
);
