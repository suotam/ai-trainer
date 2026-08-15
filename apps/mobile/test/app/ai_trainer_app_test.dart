import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/app/startup/startup_screen.dart';
import 'package:ai_trainer_mobile/features/chat/presentation/chat_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/workout_test_scope.dart';

void main() {
  group('AiTrainerApp bootstrap', () {
    testWidgets(
      'vytvoří hlavní widget a zobrazí chat domov bez pádu (CQC-009)',
      (tester) async {
        await tester.pumpWidget(
          workoutTestScope(
            database: createTestDatabase(),
            now: DateTime(2026, 7, 20, 8),
            child: const AiTrainerApp(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(ChatScreen.screenKey), findsOneWidget);
        expect(find.text('AI Trainer'), findsNothing);
      },
    );

    testWidgets('technická startup route zůstává dostupná', (tester) async {
      await tester.pumpWidget(
        workoutTestScope(
          database: createTestDatabase(),
          now: DateTime(2026, 7, 20, 8),
          child: const AiTrainerApp(),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byKey(ChatScreen.screenKey));
      GoRouter.of(context).go('/startup');
      await tester.pumpAndSettle();

      expect(find.byKey(StartupScreen.screenKey), findsOneWidget);
    });
  });
}
