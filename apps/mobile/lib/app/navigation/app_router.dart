import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/workouts/presentation/today_screen.dart';
import '../../features/workouts/presentation/workout_detail_screen.dart';
import '../startup/startup_screen.dart';
import 'app_routes.dart';

/// Routing shell aplikace (ADR-003). Route guard nesmí nahrazovat
/// doménovou autorizaci. Today je od R1-02 kanonický domov; technická
/// R0 startup obrazovka zůstává dostupná na `/startup`.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.todayPath,
    routes: [
      GoRoute(
        name: AppRoutes.todayName,
        path: AppRoutes.todayPath,
        builder: (context, state) => const TodayScreen(),
      ),
      GoRoute(
        name: AppRoutes.workoutDetailName,
        path: AppRoutes.workoutDetailPath,
        builder: (context, state) => WorkoutDetailScreen(
          // Neplatný/chybějící parametr je bezpečně řešen not-found stavem.
          workoutId: state.pathParameters[AppRoutes.workoutIdParam] ?? '',
        ),
      ),
      GoRoute(
        name: AppRoutes.startupName,
        path: AppRoutes.startupPath,
        builder: (context, state) => const StartupScreen(),
      ),
    ],
  );
});
