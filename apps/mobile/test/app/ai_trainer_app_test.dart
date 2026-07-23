import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/app/configuration/app_environment.dart';
import 'package:ai_trainer_mobile/app/startup/startup_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiTrainerApp bootstrap', () {
    testWidgets('vytvoří hlavní widget a zobrazí startup route bez pádu', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: AiTrainerApp()));
      await tester.pumpAndSettle();

      expect(find.byKey(StartupScreen.screenKey), findsOneWidget);
      expect(find.text('AI Trainer'), findsOneWidget);
    });

    testWidgets('úvodní obrazovka zobrazuje environment z Riverpod boundary', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvironmentProvider.overrideWithValue(
              AppEnvironment(
                type: AppEnvironmentType.staging,
                backendBaseUrl: Uri.parse('http://localhost:8080'),
              ),
            ),
          ],
          child: const AiTrainerApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('staging'), findsOneWidget);
    });
  });
}
