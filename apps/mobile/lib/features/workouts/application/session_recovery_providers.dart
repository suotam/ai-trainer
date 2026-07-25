import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../domain/session_recovery_result.dart';
import 'recover_active_session.dart';
import 'session_providers.dart';
import 'session_tracker_providers.dart';
import 'workout_bootstrap.dart';

/// Composition recovery vrstvy (VSP §16). Presentation čte jen tyto
/// providery — nikdy Drift typy (PDR-008).
final recoverActiveSessionProvider = Provider<RecoverActiveSession>(
  (ref) => RecoverActiveSession(
    sessionRepository: ref.watch(workoutSessionRepositoryProvider),
    performanceRepository: ref.watch(workoutPerformanceRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Startup recovery stav. Nejprve dokončí lokální bootstrap (otevření DB +
/// idempotentní seed), poté jednou spustí recovery aktivní session. Bez
/// sítě, bez background pollingu; automatický retry Riverpodu je vypnutý —
/// opakování je jen explicitní přes invalidaci (Retry). Jeden sdílený
/// future zabraňuje paralelnímu běhu při více rebuildech.
final sessionRecoveryProvider = FutureProvider<SessionRecoveryResult>((
  ref,
) async {
  await ref.watch(workoutBootstrapCompletedProvider.future);
  return ref.watch(recoverActiveSessionProvider).call();
}, retry: (retryCount, error) => null);
