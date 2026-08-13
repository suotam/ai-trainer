import 'package:flutter/foundation.dart';

/// Sportovní profil uživatele — P0 podmnožina dle C17.
///
/// `UserSport` je vztah uživatele ke sportu (role, priorita, zkušenost,
/// participation pattern), ne pouhý název sportu (C17 §3.1). Immutable
/// doménový model — persistence detaily nesmí pronikat výš (PDR-008).
@immutable
class UserSport {
  const UserSport({
    required this.id,
    required this.sportCode,
    required this.customName,
    required this.customCategory,
    required this.role,
    required this.priority,
    required this.experienceLevel,
    required this.status,
    this.lastRegularActivityDate,
    this.returnAfterPause = false,
    this.note,
    this.frequencyPerWeek,
    this.typicalDurationMinutes,
    this.typicalIntensity,
    this.environment,
    this.fixedDays = const [],
  });

  final String id;

  /// Katalogový kód (C17 §5.1), nebo `null` u custom sportu.
  final String? sportCode;

  /// Uživatelský název custom sportu (C17 §5.2), nebo `null` u katalogového.
  final String? customName;
  final String? customCategory;

  final String role;
  final String priority;
  final String experienceLevel;
  final String status;

  final String? lastRegularActivityDate;
  final bool returnAfterPause;
  final String? note;

  // Participation pattern (C17 §4.2) — popis zvyku, ne kalendář (ASP-006).
  final int? frequencyPerWeek;
  final int? typicalDurationMinutes;
  final String? typicalIntensity;
  final String? environment;
  final List<String> fixedDays;

  bool get isCustom => sportCode == null;
}

/// Vstup pro vytvoření/úpravu UserSport (bez ID a metadat).
@immutable
class UserSportInput {
  const UserSportInput({
    this.sportCode,
    this.customName,
    this.customCategory,
    required this.role,
    required this.priority,
    this.experienceLevel = 'UNKNOWN',
    this.lastRegularActivityDate,
    this.returnAfterPause = false,
    this.note,
    this.frequencyPerWeek,
    this.typicalDurationMinutes,
    this.typicalIntensity,
    this.environment,
    this.fixedDays = const [],
  });

  final String? sportCode;
  final String? customName;
  final String? customCategory;
  final String role;
  final String priority;
  final String experienceLevel;
  final String? lastRegularActivityDate;
  final bool returnAfterPause;
  final String? note;
  final int? frequencyPerWeek;
  final int? typicalDurationMinutes;
  final String? typicalIntensity;
  final String? environment;
  final List<String> fixedDays;
}

/// Typovaný výsledek zápisu UserSport — nikdy raw persistence výjimka.
sealed class SaveUserSportResult {
  const SaveUserSportResult();
}

final class UserSportSaved extends SaveUserSportResult {
  const UserSportSaved(this.id);
  final String id;
}

/// Duplicitní ne-ENDED vztah k témuž katalogovému sportu (ASP-004).
final class UserSportDuplicate extends SaveUserSportResult {
  const UserSportDuplicate();
}

/// Vlastník už má jiný ACTIVE PRIMARY sport (ASP-003).
final class UserSportPrimaryConflict extends SaveUserSportResult {
  const UserSportPrimaryConflict();
}

/// Nevalidní vstup (chybí sport reference, neplatný kód, …).
final class UserSportValidationFailed extends SaveUserSportResult {
  const UserSportValidationFailed();
}

final class UserSportNotFound extends SaveUserSportResult {
  const UserSportNotFound();
}
