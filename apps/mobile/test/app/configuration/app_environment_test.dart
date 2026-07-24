import 'package:ai_trainer_mobile/app/configuration/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironment', () {
    test('bez definice použije bezpečný development default', () {
      final environment = AppEnvironment.fromBuildEnvironment();

      expect(environment.type, AppEnvironmentType.development);
      expect(environment.name, 'development');
    });

    test('parsuje všechna podporovaná prostředí', () {
      expect(
        AppEnvironment.parseType('development'),
        AppEnvironmentType.development,
      );
      expect(AppEnvironment.parseType('test'), AppEnvironmentType.test);
      expect(AppEnvironment.parseType('staging'), AppEnvironmentType.staging);
      expect(
        AppEnvironment.parseType('production'),
        AppEnvironmentType.production,
      );
    });

    test('bez definice použije Android emulator host default pro backend', () {
      final environment = AppEnvironment.fromBuildEnvironment();

      expect(environment.backendBaseUrl, Uri.parse('http://10.0.2.2:8080'));
    });

    test('parsuje validní backend base URL a normalizuje koncové lomítko', () {
      expect(
        AppEnvironment.parseBackendBaseUrl('http://localhost:8080/'),
        Uri.parse('http://localhost:8080'),
      );
      expect(
        AppEnvironment.parseBackendBaseUrl('https://api.example.test'),
        Uri.parse('https://api.example.test'),
      );
    });

    test('nevalidní backend base URL selže srozumitelnou chybou', () {
      for (final invalid in [
        'not a url',
        'ftp://host',
        'http://',
        'http://user:pass@host:8080',
      ]) {
        expect(
          () => AppEnvironment.parseBackendBaseUrl(invalid),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.name,
              'name',
              'BACKEND_BASE_URL',
            ),
          ),
          reason: invalid,
        );
      }
    });

    test('neznámé prostředí selže srozumitelnou chybou', () {
      expect(
        () => AppEnvironment.parseType('prod'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('Unknown environment'),
          ),
        ),
      );
    });
  });
}
