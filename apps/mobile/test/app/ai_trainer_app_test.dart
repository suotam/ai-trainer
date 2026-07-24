import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/app/startup/startup_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/today_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/workout_test_scope.dart';

void main() {
  group('AiTrainerApp bootstrap', () {
    testWidgets('vytvoří hlavní widget a zobrazí Today domov bez pádu', (
      tester,
    ) async {
      await tester.pumpWidget(
        workoutTestScope(
          database: createTestDatabase(),
          now: DateTime(2026, 7, 20, 8),
          child: const AiTrainerApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
      expect(find.text('AI Trainer'), findsNothing);
    });

    testWidgets('technická startup route zůstává dostupná', (tester) async {
      await tester.pumpWidget(
        workoutTestScope(
          database: createTestDatabase(),
          now: DateTime(2026, 7, 20, 8),
          child: const AiTrainerApp(),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byKey(TodayScreen.screenKey));
      GoRouter.of(context).go('/startup');
      await tester.pumpAndSettle();

      expect(find.byKey(StartupScreen.screenKey), findsOneWidget);
    });
  });
}
