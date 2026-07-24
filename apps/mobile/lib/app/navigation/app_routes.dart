/// Centralizované route names a paths (ADR-003).
///
/// Features nesmí používat literální path řetězce mimo tento soubor.
abstract final class AppRoutes {
  /// Produktový domov aplikace (R1-02).
  static const String todayName = 'today';
  static const String todayPath = '/today';

  /// Detail workoutu podle stabilního ID.
  static const String workoutDetailName = 'workoutDetail';
  static const String workoutDetailPath = '/workouts/:workoutId';
  static const String workoutIdParam = 'workoutId';

  /// Technická R0 úvodní obrazovka (backend smoke flow); už není domov.
  static const String startupName = 'startup';
  static const String startupPath = '/startup';

  /// Sestaví cestu detailu pro daný workout ID.
  static String workoutDetailLocation(String workoutId) =>
      '/workouts/${Uri.encodeComponent(workoutId)}';
}
