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
