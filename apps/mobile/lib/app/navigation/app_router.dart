import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/account_screen.dart';
import '../../features/goals/presentation/goals_screen.dart';
import '../../features/sports/presentation/sports_profile_screen.dart';
import '../../features/workouts/presentation/active_session_screen.dart';
import '../../features/workouts/presentation/completed_workout_detail_screen.dart';
import '../../features/workouts/presentation/history_screen.dart';
import '../../features/workouts/presentation/today_screen.dart';
import '../../features/workouts/presentation/workout_detail_screen.dart';
import '../startup/recovery_gate_screen.dart';
import '../startup/startup_screen.dart';
import 'app_routes.dart';

/// Routing shell aplikace (ADR-003). Route guard nesmí nahrazovat
/// doménovou autorizaci. Kanonická initial route je startup recovery gate
/// (R1-05), který po restartu rozhodne mezi Today a obnovenou session.
/// Today zůstává produktový domov; technická R0 startup obrazovka je na
/// `/startup`.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.startupGatePath,
    routes: [
      GoRoute(
        name: AppRoutes.startupGateName,
        path: AppRoutes.startupGatePath,
        builder: (context, state) => const RecoveryGateScreen(),
      ),
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
        name: AppRoutes.activeSessionName,
        path: AppRoutes.activeSessionPath,
        builder: (context, state) => ActiveSessionScreen(
          sessionId: state.pathParameters[AppRoutes.sessionIdParam] ?? '',
        ),
      ),
      GoRoute(
        name: AppRoutes.historyName,
        path: AppRoutes.historyPath,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        name: AppRoutes.completedWorkoutName,
        path: AppRoutes.completedWorkoutPath,
        builder: (context, state) => CompletedWorkoutDetailScreen(
          sessionId: state.pathParameters[AppRoutes.sessionIdParam] ?? '',
        ),
      ),
      GoRoute(
        name: AppRoutes.accountName,
        path: AppRoutes.accountPath,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        name: AppRoutes.sportsProfileName,
        path: AppRoutes.sportsProfilePath,
        builder: (context, state) => const SportsProfileScreen(),
      ),
      GoRoute(
        name: AppRoutes.goalsName,
        path: AppRoutes.goalsPath,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        name: AppRoutes.startupName,
        path: AppRoutes.startupPath,
        builder: (context, state) => const StartupScreen(),
      ),
    ],
  );
});
