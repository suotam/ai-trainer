import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../activity/application/activity_providers.dart';
import '../../summary/application/summary_providers.dart';
import '../../workouts/application/quick_complete_workout.dart';
import '../../workouts/application/session_providers.dart';
import '../../workouts/application/today_providers.dart';
import '../../workouts/application/workout_completion_providers.dart';
import '../../workouts/application/workout_providers.dart';
import '../../workouts/domain/workout_read_model.dart';

/// Fokusovaný měsíc `YYYY-MM` (C50 §2) — init z lokálního času.
final calendarMonthProvider = NotifierProvider<CalendarMonth, String>(
  CalendarMonth.new,
);

class CalendarMonth extends Notifier<String> {
  @override
  String build() {
    final now = ref.watch(clockProvider)();
    return formatLocalDate(now).substring(0, 7);
  }

  void shift(int months) {
    final parts = state.split('-');
    final shifted = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]) + months,
      1,
    );
    state =
        '${shifted.year.toString().padLeft(4, '0')}-'
        '${shifted.month.toString().padLeft(2, '0')}';
  }
}

/// Vybraný den `YYYY-MM-DD` (default dnešek).
final calendarSelectedDateProvider =
    NotifierProvider<CalendarSelectedDate, String>(CalendarSelectedDate.new);

class CalendarSelectedDate extends Notifier<String> {
  @override
  String build() => formatLocalDate(ref.watch(clockProvider)());

  void select(String localDate) => state = localDate;
}

/// Workouty fokusovaného měsíce seskupené podle lokálního data (CQC-001/002):
/// čistý read model nad C16, deterministické hranice měsíce.
final calendarMonthWorkoutsProvider =
    FutureProvider<Map<String, List<WorkoutInstanceSummary>>>((ref) async {
      final month = ref.watch(calendarMonthProvider);
      final parts = month.split('-');
      final year = int.parse(parts[0]);
      final monthNumber = int.parse(parts[1]);
      final lastDay = DateTime(year, monthNumber + 1, 0).day;
      final from = '$month-01';
      final to = '$month-${lastDay.toString().padLeft(2, '0')}';
      final workouts = await ref
          .watch(workoutInstanceRepositoryProvider)
          .workoutsForLocalDateRange(from, to);
      final byDate = <String, List<WorkoutInstanceSummary>>{};
      for (final workout in workouts) {
        byDate.putIfAbsent(workout.scheduledLocalDate, () => []).add(workout);
      }
      return byDate;
    });

/// Guard + typovaný výsledek rychlého dokončení pro UI (C50 §3).
final quickCompleteControllerProvider =
    NotifierProvider<QuickCompleteController, QuickCompleteResult?>(
      QuickCompleteController.new,
    );

class QuickCompleteController extends Notifier<QuickCompleteResult?> {
  bool _inFlight = false;

  @override
  QuickCompleteResult? build() => null;

  Future<void> quickComplete(String workoutInstanceId) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    try {
      final result =
          await QuickCompleteWorkout(
            ref.read(workoutSessionRepositoryProvider),
            ref.read(workoutCompletionRepositoryProvider),
          )(
            workoutInstanceId,
            newSessionId: ref.read(idGeneratorProvider).newId(),
            now: ref.read(clockProvider)(),
          );
      state = result;
      if (result is QuickCompleted || result is QuickAlreadyCompleted) {
        // Dokončení se ihned propisuje (CQC-010).
        ref
          ..invalidate(calendarMonthWorkoutsProvider)
          ..invalidate(todayWorkoutsProvider)
          ..invalidate(weeklySummaryProvider)
          ..invalidate(manualActivitiesProvider);
      }
    } finally {
      _inFlight = false;
    }
  }
}
