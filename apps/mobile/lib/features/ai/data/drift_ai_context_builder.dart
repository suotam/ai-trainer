import '../../../core/time/clock.dart';
import '../../activity/domain/activity_repository.dart';
import '../../availability/domain/availability_profile.dart';
import '../../availability/domain/availability_profile_repository.dart';
import '../../checkin/domain/daily_check_in.dart';
import '../../checkin/domain/daily_check_in_repository.dart';
import '../../goals/domain/goal_repository.dart';
import '../../safety/domain/safety_assessment.dart';
import '../../sports/domain/user_sport.dart';
import '../../sports/domain/user_sport_repository.dart';
import '../../workouts/domain/workout_instance_repository.dart';
import '../domain/ai_context.dart';

/// Builder AIContextu (C27 §3 + C36 §3) nad existujícími repository
/// (deterministické řazení přebírá z jejich read modelů, ACX-008).
/// Minimalizace: žádná ID, žádné poznámky, žádný owner, jen aktivní data;
/// historie výhradně jako agregáty (ACX-003..007, ADX-001/006/007).
class DriftAiContextBuilder implements AiContextBuilder {
  DriftAiContextBuilder(
    this._sports,
    this._goals,
    this._availability,
    this._activities,
    this._checkIns,
    this._workoutInstances,
  );

  final UserSportRepository _sports;
  final GoalRepository _goals;
  final AvailabilityProfileRepository _availability;
  final ActivityRepository _activities;
  final DailyCheckInRepository _checkIns;
  final WorkoutInstanceRepository _workoutInstances;

  static const _sectionLimit = 50;
  static const _statisticsPeriodDays = 30;
  static const _checkInPeriodDays = 7;
  static const _weekPlanDays = 7;

  @override
  Future<AiContext> buildPlanProposalContext({required DateTime now}) async {
    return AiContext(
      requestType: AiRequestType.planProposal,
      payload: await _basePayload(AiRequestType.planProposal, now),
    );
  }

  @override
  Future<AiContext> buildAdjustmentContext({required DateTime now}) async {
    final base = await _basePayload(AiRequestType.adjustmentProposal, now);
    final today = formatLocalDate(now);

    // 1. Týden plánu by-value (C36 §3.1): dayOffset místo dat (ADX-003),
    // žádná instance ID (ADX-004).
    final weekEnd = formatLocalDate(
      now.add(const Duration(days: _weekPlanDays - 1)),
    );
    final weekWorkouts = await _workoutInstances.workoutsForLocalDateRange(
      today,
      weekEnd,
    );
    final weekPlan = _limited([
      for (final workout in weekWorkouts)
        {
          'dayOffset': _dayOffset(today, workout.scheduledLocalDate),
          'title': workout.title,
          'workoutType': workout.workoutType,
          'status': workout.status.code,
          if (workout.plannedDurationSeconds != null)
            'plannedDurationMinutes': workout.plannedDurationSeconds! ~/ 60,
        },
    ]);

    // 2. Check-iny (C36 §3.2): dnešní by-value bez note (ADX-006) +
    // 7denní agregáty místo historie (ADX-007).
    final todayCheckIn = await _checkIns.checkInForDate(today);
    final history = await _checkIns.historyForCurrentOwner();
    final from = formatLocalDate(
      now.subtract(const Duration(days: _checkInPeriodDays - 1)),
    );
    final window = [
      for (final checkIn in history)
        if (checkIn.localDate.compareTo(from) >= 0 &&
            checkIn.localDate.compareTo(today) <= 0)
          checkIn,
    ];

    // 3. Safety (C36 §3.3): C34 výstup jako fakt (ADX-005); tituly
    // omezení nejsou duplikované — jsou už v sekci constraints.
    final activeConstraints = [
      for (final constraint in await _availability.constraintsForCurrentOwner())
        if (constraint.status == 'ACTIVE') constraint,
    ];
    final safety = evaluateSafety(
      todayCheckIn: todayCheckIn,
      activeConstraints: activeConstraints,
    );

    return AiContext(
      requestType: AiRequestType.adjustmentProposal,
      payload: {
        ...base,
        'weekPlan': weekPlan,
        'checkIns': {
          if (todayCheckIn != null) 'today': _checkInEntry(todayCheckIn),
          'aggregates': {
            'periodDays': _checkInPeriodDays,
            'checkInCount': window.length,
            if (window.isNotEmpty) ...{
              'averageEnergy': _average(window.map((c) => c.energyLevel)),
              'averageFatigue': _average(window.map((c) => c.fatigueLevel)),
              'painDays': window.where((c) => c.hasPain).length,
            },
          },
        },
        'safety': {
          'state': safety.state.code,
          'flags': [
            for (final flag in safety.flags)
              {
                'code': flag.code,
                if (flag.painAreaCode != null)
                  'painAreaCode': flag.painAreaCode,
                if (flag.painLevel != null) 'painLevel': flag.painLevel,
              },
          ],
        },
      },
    );
  }

  Map<String, Object?> _checkInEntry(DailyCheckIn checkIn) => {
    'energyLevel': checkIn.energyLevel,
    'fatigueLevel': checkIn.fatigueLevel,
    if (checkIn.sleepQuality != null) 'sleepQuality': checkIn.sleepQuality,
    if (checkIn.painLevel != null) 'painLevel': checkIn.painLevel,
    if (checkIn.painAreaCode != null) 'painAreaCode': checkIn.painAreaCode,
  };

  int _dayOffset(String today, String date) =>
      DateTime.parse(date).difference(DateTime.parse(today)).inDays;

  /// Deterministický průměr zaokrouhlený na 1 desetinu (ADX-002).
  double _average(Iterable<int> values) {
    final list = values.toList();
    return (list.reduce((a, b) => a + b) / list.length * 10).round() / 10;
  }

  Future<Map<String, Object?>> _basePayload(
    AiRequestType type,
    DateTime now,
  ) async {
    final allSports = await _sports.sportsForCurrentOwner();
    // Jen ACTIVE/PAUSED (ACX-006; PAUSED je pro plánování relevantní).
    final sports = allSports
        .where((s) => s.status == 'ACTIVE' || s.status == 'PAUSED')
        .toList();
    final sportNameById = {
      for (final sport in allSports) sport.id: _sportName(sport),
    };

    final goals = (await _goals.goalsForCurrentOwner())
        .where((g) => g.status == 'ACTIVE')
        .toList();
    final week = await _availability.weekForCurrentOwner();
    final equipment = (await _availability.equipmentForCurrentOwner())
        .where((e) => e.status == 'ACTIVE')
        .toList();
    final constraints = (await _availability.constraintsForCurrentOwner())
        .where((c) => c.status == 'ACTIVE')
        .toList();
    final to = formatLocalDate(now);
    final from = formatLocalDate(
      now.subtract(const Duration(days: _statisticsPeriodDays - 1)),
    );
    final statistics = await _activities.statisticsForPeriod(
      fromLocalDate: from,
      toLocalDate: to,
    );

    return {
      'requestType': type.code,
      'sports': _limited(sports.map(_sportEntry).toList()),
      'goals': _limited([
        for (final goal in goals)
          {
            'title': goal.title,
            'goalType': goal.goalType,
            'priority': goal.priority,
            'horizon': goal.horizon,
            if (goal.targetLocalDate != null)
              'targetLocalDate': goal.targetLocalDate,
            // Sport resolvovaný na kód/název — nikdy ID (ACX-003).
            if (goal.userSportId != null)
              'sport': sportNameById[goal.userSportId],
          },
      ]),
      'typicalWeek': _limited([
        for (final rule in week)
          {
            'dayOfWeek': rule.dayOfWeek,
            'level': rule.level,
            if (rule.budgetMinutes != null) 'budgetMinutes': rule.budgetMinutes,
            if (rule.preferredPartOfDay != null)
              'preferredPartOfDay': rule.preferredPartOfDay,
          },
      ]),
      'equipment': _limited([
        for (final item in equipment) {'item': _equipmentName(item)},
      ]),
      'constraints': _limited([
        for (final constraint in constraints) {'title': constraint.title},
      ]),
      'statistics': {
        'periodDays': _statisticsPeriodDays,
        'plannedCount': statistics.plannedCount,
        'completedCount': statistics.completedCount,
        'manualActivityCount': statistics.manualActivityCount,
        'manualMinutes': statistics.manualMinutes,
      },
    };
  }

  Map<String, Object?> _sportEntry(UserSport sport) => {
    'sport': _sportName(sport),
    'role': sport.role,
    'priority': sport.priority,
    'experienceLevel': sport.experienceLevel,
    'status': sport.status,
    if (sport.frequencyPerWeek != null)
      'frequencyPerWeek': sport.frequencyPerWeek,
    if (sport.typicalDurationMinutes != null)
      'typicalDurationMinutes': sport.typicalDurationMinutes,
    if (sport.typicalIntensity != null)
      'typicalIntensity': sport.typicalIntensity,
    if (sport.environment != null) 'environment': sport.environment,
    if (sport.fixedDays.isNotEmpty) 'fixedDays': sport.fixedDays,
  };

  String _sportName(UserSport sport) =>
      sport.sportCode ?? sport.customName ?? 'UNKNOWN';

  String _equipmentName(EquipmentItem item) =>
      item.equipmentCode ?? item.customName ?? 'UNKNOWN';

  /// Deterministický, přiznaný ořez sekce (C27 §5, ACX-010).
  List<Object?> _limited(List<Object?> entries) {
    if (entries.length <= _sectionLimit) {
      return entries;
    }
    return [
      ...entries.take(_sectionLimit),
      {'truncated': entries.length - _sectionLimit},
    ];
  }
}
