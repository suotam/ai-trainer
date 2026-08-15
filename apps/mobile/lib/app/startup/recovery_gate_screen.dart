import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/workouts/application/session_recovery_providers.dart';
import '../../features/workouts/application/workout_bootstrap.dart';
import '../../features/workouts/domain/session_recovery_result.dart';
import '../../l10n/generated/app_localizations.dart';
import '../navigation/app_routes.dart';

/// Startup recovery gate (VSP §16, mobile-architecture §18 bootstrap
/// pořadí). Kanonická initial route: nejprve obnoví lokální stav a teprve
/// pak rozhodne, kam navigovat — Today se nikdy krátce nezobrazí před
/// rozhodnutím.
///
/// - loading: konečný recovery stav (žádný nekonečný retry, žádný loop),
/// - žádná aktivní session → Today,
/// - obnovená aktivní session → stejný tracker (stejné uložené hodnoty),
/// - nekonzistentní/neopravitelný stav → bezpečný fallback s Retry.
///
/// Navigace je řešena přes GoRouter boundary; recovery rozhodnutí přichází
/// z application provideru, nikoli z databázové vrstvy (MAR-003).
class RecoveryGateScreen extends ConsumerStatefulWidget {
  const RecoveryGateScreen({super.key});

  static const Key screenKey = Key('recovery_gate_screen');
  static const Key loadingKey = Key('recovery_gate_loading');
  static const Key fallbackKey = Key('recovery_gate_fallback');
  static const Key retryButtonKey = Key('recovery_gate_retry');

  @override
  ConsumerState<RecoveryGateScreen> createState() => _RecoveryGateScreenState();
}

class _RecoveryGateScreenState extends ConsumerState<RecoveryGateScreen> {
  bool _navigated = false;

  void _routeFor(SessionRecoveryResult result) {
    // Jednorázová navigace: po přechodu je gate nahrazen cílovou route.
    if (_navigated) {
      return;
    }
    final String? destination = switch (result) {
      // Chat je domov (R7-05, C50 §5 CQC-009); zákon aktivní session
      // trvá beze změny — obnova má přednost níže.
      NoActiveSessionRecovery() => AppRoutes.chatPath,
      ActiveSessionRecovered(:final session) => AppRoutes.activeSessionLocation(
        session.id,
      ),
      ActiveSessionRecoveredAfterRepair(:final session) =>
        AppRoutes.activeSessionLocation(session.id),
      // Fallback stavy zůstávají na gate a vykreslí bezpečnou zprávu.
      MultipleActiveSessionsRecovery() => null,
      InconsistentActiveSessionRecovery() => null,
      UnrecoverableRecovery() => null,
    };
    if (destination == null) {
      return;
    }
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(destination);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recovery = ref.watch(sessionRecoveryProvider);

    return Scaffold(
      key: RecoveryGateScreen.screenKey,
      body: recovery.when(
        loading: () => _Loading(label: l10n.recoveryLoading),
        // Use case chyby zachytává a mapuje na typovaný výsledek; tato větev
        // je poslední záchrana a rovněž vede na bezpečný fallback.
        error: (_, _) => _Fallback(
          message: l10n.recoveryFallbackMessage,
          retryLabel: l10n.recoveryRetry,
          onRetry: _retry,
        ),
        data: (result) {
          _routeFor(result);
          return switch (result) {
            NoActiveSessionRecovery() ||
            ActiveSessionRecovered() ||
            ActiveSessionRecoveredAfterRepair() => _Loading(
              label: l10n.recoveryLoading,
            ),
            MultipleActiveSessionsRecovery() ||
            InconsistentActiveSessionRecovery() ||
            UnrecoverableRecovery() => _Fallback(
              message: l10n.recoveryFallbackMessage,
              retryLabel: l10n.recoveryRetry,
              onRetry: _retry,
            ),
          };
        },
      ),
    );
  }

  void _retry() {
    _navigated = false;
    // Explicitní, uživatelem řízené opakování — žádný automatický loop.
    // Obnoví i bootstrap, aby Retry pokryl selhání otevření DB/seedu i
    // samotné recovery; recovery pak běží znovu (idempotentně).
    ref.invalidate(workoutBootstrapCompletedProvider);
    ref.invalidate(sessionRecoveryProvider);
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        key: RecoveryGateScreen.loadingKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label),
        ],
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        key: RecoveryGateScreen.fallbackKey,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              container: true,
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              key: RecoveryGateScreen.retryButtonKey,
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
