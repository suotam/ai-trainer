import 'package:flutter/foundation.dart';

/// Cíl uživatele — P0 podmnožina dle C18.
///
/// Cíl je strukturovaná deklarace (typ, priorita, horizont, volitelný
/// termín a vazba na sport), ne povinná metrika (C18 §3.1). Immutable
/// doménový model — persistence detaily nesmí pronikat výš (PDR-008).
@immutable
class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.goalType,
    required this.priority,
    required this.horizon,
    required this.status,
    this.userSportId,
    this.targetLocalDate,
    this.note,
  });

  final String id;
  final String title;
  final String goalType;
  final String priority;
  final String horizon;
  final String status;

  /// Volitelná device-local vazba na UserSport ID (GLC-008).
  final String? userSportId;
  final String? targetLocalDate;
  final String? note;

  bool get isTerminal => status == 'COMPLETED' || status == 'ABANDONED';
}

/// Vstup pro vytvoření/úpravu cíle (bez ID a metadat).
@immutable
class GoalInput {
  const GoalInput({
    required this.title,
    required this.goalType,
    required this.priority,
    this.horizon = 'OPEN_ENDED',
    this.userSportId,
    this.targetLocalDate,
    this.note,
  });

  final String title;
  final String goalType;
  final String priority;
  final String horizon;
  final String? userSportId;
  final String? targetLocalDate;
  final String? note;
}

/// Typovaný výsledek zápisu cíle — nikdy raw persistence výjimka.
sealed class SaveGoalResult {
  const SaveGoalResult();
}

final class GoalSaved extends SaveGoalResult {
  const GoalSaved(this.id);
  final String id;
}

/// Nevalidní vstup (prázdný title, neznámý kód, nevalidní datum,
/// neexistující sport reference).
final class GoalValidationFailed extends SaveGoalResult {
  const GoalValidationFailed();
}

final class GoalNotFound extends SaveGoalResult {
  const GoalNotFound();
}

/// Nevalidní lifecycle operace (GLC-004/006): editace terminálního cíle
/// nebo nepovolený stavový přechod.
final class GoalInvalidTransition extends SaveGoalResult {
  const GoalInvalidTransition();
}

/// Stabilní kódy typů cíle (C18 §5.1).
const List<String> goalTypes = [
  'PERFORMANCE',
  'STRENGTH',
  'ENDURANCE',
  'HABIT',
  'EVENT_PREPARATION',
  'RETURN_TO_ACTIVITY',
  'MAINTENANCE',
  'QUALITATIVE',
];

/// Stabilní kódy priorit cíle (C18 §5.2).
const List<String> goalPriorities = ['PRIMARY', 'MAINTENANCE', 'DEFERRED'];

/// Stabilní kódy horizontů cíle (C18 §5.3).
const List<String> goalHorizons = [
  'IMMEDIATE',
  'SHORT_TERM',
  'MEDIUM_TERM',
  'LONG_TERM',
  'OPEN_ENDED',
];

/// Stabilní kódy stavů cíle (C18 §5.4).
const List<String> goalStatuses = [
  'ACTIVE',
  'PAUSED',
  'COMPLETED',
  'ABANDONED',
];
