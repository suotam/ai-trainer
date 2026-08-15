import '../../availability/domain/availability_profile.dart';
import '../../availability/domain/availability_profile_repository.dart';
import '../../goals/domain/goal.dart';
import '../../goals/domain/goal_repository.dart';
import '../../sports/domain/user_sport.dart';
import '../../sports/domain/user_sport_repository.dart';

/// Typovaný výsledek provedení akce (CHA-007).
sealed class ChatActionResult {
  const ChatActionResult();
}

final class ChatActionApplied extends ChatActionResult {
  const ChatActionApplied();
}

final class ChatActionRejectedByDomain extends ChatActionResult {
  const ChatActionRejectedByDomain(this.reason);
  final String reason;
}

/// Provedení potvrzené akce (C48 §3/§4, CHA-001): výhradně existující
/// repository operace C17/C18/C19 — z pohledu domény nerozlišitelné od
/// ručního zápisu. Žádná přímá DB cesta.
class ChatActionExecutor {
  ChatActionExecutor(this._sports, this._goals, this._availability);

  final UserSportRepository _sports;
  final GoalRepository _goals;
  final AvailabilityProfileRepository _availability;

  Future<ChatActionResult> apply(
    Map<String, Object?> canonical, {
    required String Function() newId,
    required DateTime now,
  }) async {
    return switch (canonical['action']) {
      'UPSERT_SPORT' => _upsertSport(canonical, newId: newId, now: now),
      'ADD_GOAL' => _addGoal(canonical, newId: newId, now: now),
      'SET_AVAILABILITY' => _setAvailability(canonical, newId: newId, now: now),
      'ADD_CONSTRAINT' => _addConstraint(canonical, newId: newId, now: now),
      _ => const ChatActionRejectedByDomain('unknownAction'),
    };
  }

  Future<ChatActionResult> _upsertSport(
    Map<String, Object?> canonical, {
    required String Function() newId,
    required DateTime now,
  }) async {
    final sportCode = canonical['sportCode'] as String?;
    final customName = canonical['customName'] as String?;
    // Deterministická resolvace existujícího sportu (CHA-009): shoda
    // katalogového kódu, nebo case-insensitive shoda custom názvu.
    final existing = (await _sports.sportsForCurrentOwner())
        .where(
          (s) => sportCode != null
              ? s.sportCode == sportCode
              : (s.customName?.toLowerCase() == customName!.toLowerCase()),
        )
        .firstOrNull;
    final result = await _sports.saveSport(
      UserSportInput(
        sportCode: sportCode,
        customName: customName,
        role: canonical['role']! as String,
        priority: canonical['priority']! as String,
        experienceLevel:
            (canonical['experienceLevel'] as String?) ??
            existing?.experienceLevel ??
            'UNKNOWN',
        frequencyPerWeek:
            (canonical['frequencyPerWeek'] as int?) ??
            existing?.frequencyPerWeek,
        typicalDurationMinutes:
            (canonical['typicalDurationMinutes'] as int?) ??
            existing?.typicalDurationMinutes,
        environment:
            (canonical['environment'] as String?) ?? existing?.environment,
        // Nepokryté atributy existujícího sportu se zachovávají (CHA-011).
        customCategory: existing?.customCategory,
        typicalIntensity: existing?.typicalIntensity,
        fixedDays: existing?.fixedDays ?? const [],
        note: existing?.note,
      ),
      existingId: existing?.id,
      newId: newId(),
      now: now,
    );
    return switch (result) {
      UserSportSaved() => const ChatActionApplied(),
      _ => ChatActionRejectedByDomain(result.runtimeType.toString()),
    };
  }

  Future<ChatActionResult> _addGoal(
    Map<String, Object?> canonical, {
    required String Function() newId,
    required DateTime now,
  }) async {
    final result = await _goals.saveGoal(
      GoalInput(
        title: canonical['title']! as String,
        goalType: canonical['goalType']! as String,
        priority: canonical['priority']! as String,
        horizon: (canonical['horizon'] as String?) ?? 'OPEN_ENDED',
        targetLocalDate: canonical['targetLocalDate'] as String?,
      ),
      newId: newId(),
      now: now,
    );
    return switch (result) {
      GoalSaved() => const ChatActionApplied(),
      _ => ChatActionRejectedByDomain(result.runtimeType.toString()),
    };
  }

  Future<ChatActionResult> _setAvailability(
    Map<String, Object?> canonical, {
    required String Function() newId,
    required DateTime now,
  }) async {
    final result = await _availability.upsertDay(
      dayOfWeek: canonical['dayOfWeek']! as String,
      level: canonical['level']! as String,
      budgetMinutes: canonical['budgetMinutes'] as int?,
      preferredPartOfDay: canonical['preferredPartOfDay'] as String?,
      newId: newId(),
      now: now,
    );
    return switch (result) {
      AvailabilityWriteSaved() => const ChatActionApplied(),
      _ => ChatActionRejectedByDomain(result.runtimeType.toString()),
    };
  }

  Future<ChatActionResult> _addConstraint(
    Map<String, Object?> canonical, {
    required String Function() newId,
    required DateTime now,
  }) async {
    final result = await _availability.addConstraint(
      title: canonical['title']! as String,
      newId: newId(),
      now: now,
    );
    return switch (result) {
      AvailabilityWriteSaved() => const ChatActionApplied(),
      _ => ChatActionRejectedByDomain(result.runtimeType.toString()),
    };
  }
}
