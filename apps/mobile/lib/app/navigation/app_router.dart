import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../startup/startup_screen.dart';
import 'app_routes.dart';

/// Routing shell aplikace (ADR-003). Route guard nesmí nahrazovat
/// doménovou autorizaci.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.startupPath,
    routes: [
      GoRoute(
        name: AppRoutes.startupName,
        path: AppRoutes.startupPath,
        builder: (context, state) => const StartupScreen(),
      ),
    ],
  );
});
