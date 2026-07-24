import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Podporovaná běhová prostředí (mobile-architecture §31).
enum AppEnvironmentType { development, test, staging, production }

/// Environment configuration boundary.
///
/// Jediné místo, které čte build-time environment konfiguraci. Widgety ani
/// budoucí features nesmí číst `String.fromEnvironment` přímo — závisí pouze
/// na [appEnvironmentProvider]. Neobsahuje a nesmí obsahovat secrets.
class AppEnvironment {
  const AppEnvironment({required this.type, required this.backendBaseUrl});

  /// Načte prostředí z `--dart-define=APP_ENVIRONMENT=<name>` a backend
  /// base URL z `--dart-define=BACKEND_BASE_URL=<url>`.
  ///
  /// Bez definice platí bezpečné development defaults:
  /// [AppEnvironmentType.development] a `http://10.0.2.2:8080`
  /// (host loopback z pohledu Android emulátoru; iOS simulátor a fyzická
  /// zařízení předávají vlastní URL — viz README).
  factory AppEnvironment.fromBuildEnvironment() {
    const name = String.fromEnvironment(
      'APP_ENVIRONMENT',
      defaultValue: 'development',
    );
    const baseUrl = String.fromEnvironment(
      'BACKEND_BASE_URL',
      defaultValue: 'http://10.0.2.2:8080',
    );
    return AppEnvironment(
      type: parseType(name),
      backendBaseUrl: parseBackendBaseUrl(baseUrl),
    );
  }

  final AppEnvironmentType type;

  /// Base URL backendu bez credentials; koncové lomítko se normalizuje.
  final Uri backendBaseUrl;

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

  /// Nevalidní URL je chyba konfigurace a selže srozumitelně.
  static Uri parseBackendBaseUrl(String value) {
    final uri = Uri.tryParse(value);
    final valid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
    if (!valid) {
      throw ArgumentError.value(
        value,
        'BACKEND_BASE_URL',
        'Expected an absolute http(s) URL without credentials, '
            'e.g. http://10.0.2.2:8080',
      );
    }
    final normalizedPath = uri.path.endsWith('/')
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    return uri.replace(path: normalizedPath);
  }
}

/// Zdroj environment konfigurace pro celou aplikaci.
/// V testech se přepisuje přes `ProviderScope(overrides: ...)`.
final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => AppEnvironment.fromBuildEnvironment(),
);
