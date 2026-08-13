import '../../../core/time/clock.dart';
import '../../activity/domain/activity_repository.dart';
import '../../availability/domain/availability_profile.dart';
import '../../availability/domain/availability_profile_repository.dart';
import '../../goals/domain/goal_repository.dart';
import '../../sports/domain/user_sport.dart';
import '../../sports/domain/user_sport_repository.dart';
import '../domain/ai_context.dart';

/// Builder AIContextu pro PLAN_PROPOSAL (C27 §3) nad existujícími R3
/// repository (deterministické řazení přebírá z jejich read modelů,
/// ACX-008). Minimalizace: žádná ID, žádné poznámky, žádný owner, jen
/// aktivní data; historie výhradně jako C23 agregáty (ACX-003..007).
class DriftAiContextBuilder implements AiContextBuilder {
  DriftAiContextBuilder(
    this._sports,
    this._goals,
    this._availability,
    this._activities,
  );

  final UserSportRepository _sports;
  final GoalRepository _goals;
  final AvailabilityProfileRepository _availability;
  final ActivityRepository _activities;

  static const _sectionLimit = 50;
  static const _statisticsPeriodDays = 30;

  @override
  Future<AiContext> buildPlanProposalContext({required DateTime now}) async {
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

    return AiContext(
      requestType: AiRequestType.planProposal,
      payload: {
        'requestType': AiRequestType.planProposal.code,
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
              if (rule.budgetMinutes != null)
                'budgetMinutes': rule.budgetMinutes,
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
      },
    );
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
