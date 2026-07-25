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

  /// Technická R0 úvodní obrazovka (backend smoke flow); už není domov.
  static const String startupName = 'startup';
  static const String startupPath = '/startup';

  /// Sestaví cestu detailu pro daný workout ID.
  static String workoutDetailLocation(String workoutId) =>
      '/workouts/${Uri.encodeComponent(workoutId)}';

  /// Sestaví cestu aktivní session pro dané session ID.
  static String activeSessionLocation(String sessionId) =>
      '/sessions/${Uri.encodeComponent(sessionId)}';
}
