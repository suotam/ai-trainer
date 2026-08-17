import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Kořenový obal všech obrazovek (on-device nálezy 5 a 6, R8 Exit Review):
///
/// - **Systémové „zpět" nikdy nezavře aplikaci z ne-domovské obrazovky.**
///   Obrazovky otevřené přes `go()` (obnovená session po startu, historie
///   po dokončení, hluboké odkazy) nemají nic k pop-nutí — dřív se tím
///   aplikace ukončila (uživatel to vnímal jako pád). Teď: je-li co
///   pop-nout, pop; jinak návrat na domov (chat, CQC-009); z domova
///   teprve odchod z aplikace.
/// - **Spodní systémová lišta (gesture bar) nepřekrývá obsah.** Android 15
///   vykresluje edge-to-edge; obrazovky s vlastním `padding` u seznamů
///   ztrácely automatický spodní inset. Bezpečná zóna se aplikuje jednou,
///   tady, a plocha pod lištou se maluje barvou povrchu.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const Key shellKey = Key('app_shell');

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        handleBack(context);
      },
      child: ColoredBox(
        key: shellKey,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(top: false, child: child),
      ),
    );
  }

  /// Rozhodnutí o „zpět" (testovatelné bez systémového kanálu).
  static void handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    final location = router.state.uri.path;
    if (location != AppRoutes.chatPath) {
      router.go(AppRoutes.chatPath);
      return;
    }
    SystemNavigator.pop();
  }
}
