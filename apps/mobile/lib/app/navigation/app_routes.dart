/// Centralizované route names a paths (ADR-003).
///
/// Features nesmí používat literální path řetězce mimo tento soubor.
abstract final class AppRoutes {
  /// Startup recovery gate (R1-05) — kanonická initial route. Rozhodne mezi
  /// Today, obnovenou aktivní session a bezpečným fallbackem po restartu.
  static const String startupGateName = 'startupGate';
  static const String startupGatePath = '/';

  /// Produktový domov aplikace (R1-02).
  static const String todayName = 'today';
  static const String todayPath = '/today';

  /// Detail workoutu podle stabilního ID.
  static const String workoutDetailName = 'workoutDetail';
  static const String workoutDetailPath = '/workouts/:workoutId';
  static const String workoutIdParam = 'workoutId';

  /// Aktivní workout session podle stabilního ID (R1-03).
  static const String activeSessionName = 'activeSession';
  static const String activeSessionPath = '/sessions/:sessionId';
  static const String sessionIdParam = 'sessionId';

  /// Lokální historie dokončených workoutů (R1-06).
  static const String historyName = 'history';
  static const String historyPath = '/history';

  /// Read-only detail dokončeného workoutu podle ID dokončené session (R1-06).
  static const String completedWorkoutName = 'completedWorkout';
  static const String completedWorkoutPath = '/history/:sessionId';

  /// Account — přihlášení/odhlášení (R2-03). Volitelný vstup; R1 offline
  /// tok na něm nezávisí (R2P-004).
  static const String accountName = 'account';
  static const String accountPath = '/account';

  /// Sportovní profil (R3-01, C17) — offline-first, bez závislosti na účtu.
  static const String sportsProfileName = 'sportsProfile';
  static const String sportsProfilePath = '/sports';

  /// Cíle (R3-02, C18) — offline-first, bez závislosti na účtu.
  static const String goalsName = 'goals';
  static const String goalsPath = '/goals';

  /// Dostupnost a tréninkový kontext (R3-03, C19) — offline-first.
  static const String availabilityName = 'availability';
  static const String availabilityPath = '/availability';

  /// Ruční tréninkový plán (R3-04, C20) — offline-first.
  static const String planName = 'plan';
  static const String planPath = '/plan';

  /// Aktivita a progres (R3-06, C22/C23) — offline-first.
  static const String activityName = 'activity';
  static const String activityPath = '/activity';

  /// Technická R0 úvodní obrazovka (backend smoke flow); už není domov.
  static const String startupName = 'startup';
  static const String startupPath = '/startup';

  /// Sestaví cestu detailu pro daný workout ID.
  static String workoutDetailLocation(String workoutId) =>
      '/workouts/${Uri.encodeComponent(workoutId)}';

  /// Sestaví cestu aktivní session pro dané session ID.
  static String activeSessionLocation(String sessionId) =>
      '/sessions/${Uri.encodeComponent(sessionId)}';

  /// Sestaví cestu detailu dokončeného workoutu pro dané session ID.
  static String completedWorkoutLocation(String sessionId) =>
      '/history/${Uri.encodeComponent(sessionId)}';
}
