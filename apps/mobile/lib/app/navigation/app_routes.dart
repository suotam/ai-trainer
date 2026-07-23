/// Centralizované route names a paths (ADR-003).
///
/// Features nesmí používat literální path řetězce mimo tento soubor.
abstract final class AppRoutes {
  static const String startupName = 'startup';
  static const String startupPath = '/';
}
