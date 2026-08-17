import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/app/navigation/app_routes.dart';
import 'package:ai_trainer_mobile/app/navigation/app_shell.dart';
import 'package:ai_trainer_mobile/features/chat/presentation/chat_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/history_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/workout_test_scope.dart';

/// On-device nálezy 5/6 (R8 Exit Review): systémové „zpět" z obrazovky
/// otevřené přes `go()` (bez zásobníku) vrací na domov místo ukončení
/// aplikace; z domova teprve odchod; push-nutá obrazovka se pop-ne. Shell
/// zároveň drží obsah nad spodní systémovou lištou.
void main() {
  Future<BuildContext> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      workoutTestScope(
        database: createTestDatabase(),
        now: DateTime(2026, 8, 17, 8),
        child: const AiTrainerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(ChatScreen.screenKey), findsOneWidget);
    return tester.element(find.byKey(ChatScreen.screenKey));
  }

  testWidgets('zpět z go() obrazovky → domov (chat), ne ukončení', (
    tester,
  ) async {
    final context = await pumpApp(tester);
    GoRouter.of(context).go(AppRoutes.historyPath);
    await tester.pumpAndSettle();
    expect(find.byKey(HistoryScreen.screenKey), findsOneWidget);

    // Systémové zpět (Android back) → domov.
    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(find.byKey(ChatScreen.screenKey), findsOneWidget);
    expect(find.byKey(HistoryScreen.screenKey), findsNothing);
  });

  testWidgets('zpět z push-nuté obrazovky pop-ne; z domova odchod z aplikace', (
    tester,
  ) async {
    final context = await pumpApp(tester);
    GoRouter.of(context).push(AppRoutes.todayPath);
    await tester.pumpAndSettle();
    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.byKey(ChatScreen.screenKey), findsOneWidget);

    // Na domově: shell požádá systém o odchod (SystemNavigator.pop).
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(calls, contains('SystemNavigator.pop'));
    expect(find.byKey(AppShell.shellKey), findsOneWidget);
  });

  testWidgets('shell drží obsah nad spodní systémovou lištou (SafeArea)', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 120);
    tester.view.viewPadding = const FakeViewPadding(bottom: 120);
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    final shell = tester.getRect(find.byKey(AppShell.shellKey));
    // Vnitřní obsah (Scaffold chatu) končí nad lištou.
    final scaffold = tester.getRect(
      find
          .descendant(
            of: find.byKey(AppShell.shellKey),
            matching: find.byType(Scaffold),
          )
          .first,
    );
    expect(scaffold.bottom, lessThanOrEqualTo(shell.bottom - 120 + 0.01));
  });
}
