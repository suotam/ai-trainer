import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Podporovaná běhová prostředí (mobile-architecture §31).
enum AppEnvironmentType { development, test, staging, production }

/// Environment configuration boundary.
///
/// Jediné místo, které čte build-time environment konfiguraci. Widgety ani
/// budoucí features nesmí číst `String.fromEnvironment` přímo — závisí pouze
/// na [appEnvironmentProvider]. Neobsahuje a nesmí obsahovat secrets.
class AppEnvironment {
  const AppEnvironment({required this.type});

  /// Načte prostředí z `--dart-define=APP_ENVIRONMENT=<name>`.
  ///
  /// Bez definice platí bezpečný default [AppEnvironmentType.development].
  factory AppEnvironment.fromBuildEnvironment() {
    const name = String.fromEnvironment(
      'APP_ENVIRONMENT',
      defaultValue: 'development',
    );
    return AppEnvironment(type: parseType(name));
  }

  final AppEnvironmentType type;

  String get name => type.name;

  /// Neznámá hodnota je chyba konfigurace a musí selhat srozumitelně,
  /// nikoli tiše spadnout do defaultu.
  static AppEnvironmentType parseType(String name) {
    return AppEnvironmentType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => throw ArgumentError.value(
        name,
        'APP_ENVIRONMENT',
        'Unknown environment. Supported values: '
            '${AppEnvironmentType.values.map((type) => type.name).join(', ')}.',
      ),
    );
  }
}

/// Zdroj environment konfigurace pro celou aplikaci.
/// V testech se přepisuje přes `ProviderScope(overrides: ...)`.
final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => AppEnvironment.fromBuildEnvironment(),
);
