import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../app/configuration/app_environment.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../activity/application/activity_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../availability/application/availability_providers.dart';
import '../../goals/application/goals_providers.dart';
import '../../sports/application/sports_profile_providers.dart';
import '../data/drift_ai_context_builder.dart';
import '../data/drift_ai_proposal_repository.dart';
import '../data/http_ai_api_client.dart';
import '../domain/ai_context.dart';
import '../domain/ai_proposal.dart';
import '../domain/ai_proposal_repository.dart';
import 'request_plan_proposal.dart';

/// Composition AI vrstvy (R4-02/03, C27–C29). Builder je čistě lokální
/// (ACX-014); jediný AI endpoint jde přes backend (AGW-001).
final aiContextBuilderProvider = Provider<AiContextBuilder>(
  (ref) => DriftAiContextBuilder(
    ref.watch(userSportRepositoryProvider),
    ref.watch(goalRepositoryProvider),
    ref.watch(availabilityProfileRepositoryProvider),
    ref.watch(activityRepositoryProvider),
  ),
);

final aiApiClientProvider = Provider<AiApiClient>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return HttpAiApiClient(
    baseUrl: environment.backendBaseUrl,
    httpClient: http.Client(),
  );
});

final aiProposalRepositoryProvider = Provider<AiProposalRepository>(
  (ref) => DriftAiProposalRepository(ref.watch(appDatabaseProvider)),
);

/// Návrhy aktuálního vlastníka (APL-012).
final aiProposalsProvider = FutureProvider<List<AiProposal>>(
  (ref) => ref.watch(aiProposalRepositoryProvider).proposalsForCurrentOwner(),
  retry: (retryCount, error) => null,
);

final requestPlanProposalProvider = Provider<RequestPlanProposal>(
  (ref) => RequestPlanProposal(
    storage: ref.watch(secureSessionStorageProvider),
    contextBuilder: ref.watch(aiContextBuilderProvider),
    apiClient: ref.watch(aiApiClientProvider),
    proposals: ref.watch(aiProposalRepositoryProvider),
    newId: ref.watch(idGeneratorProvider).newId,
    clock: ref.watch(clockProvider),
  ),
);

/// UI stav AI obrazovky (R4-04): žádost i rozhodnutí, typované chyby.
sealed class AiScreenState {
  const AiScreenState();
}

class AiIdle extends AiScreenState {
  const AiIdle();
}

class AiWorking extends AiScreenState {
  const AiWorking();
}

class AiDone extends AiScreenState {
  const AiDone();
}

class AiRequestFailure extends AiScreenState {
  const AiRequestFailure(this.result);
  final RequestProposalResult result;
}

class AiDecisionFailure extends AiScreenState {
  const AiDecisionFailure(this.result);
  final DecideProposalResult result;
}

/// Controller AI obrazovky: double-submit guard, typované chyby,
/// invalidace read modelu; rozhodnutí výhradně explicitní akcí (APL-005).
class AiScreenController extends Notifier<AiScreenState> {
  bool _inFlight = false;

  @override
  AiScreenState build() => const AiIdle();

  Future<void> requestProposal() => _run(() async {
    final result = await ref.read(requestPlanProposalProvider)();
    return switch (result) {
      ProposalCreated() => const AiDone(),
      _ => AiRequestFailure(result),
    };
  });

  Future<void> decide(String proposalId, ProposalDecision decision) =>
      _run(() async {
        final result = await ref
            .read(aiProposalRepositoryProvider)
            .decide(proposalId, decision, now: ref.read(clockProvider)());
        return switch (result) {
          DecisionSaved() => const AiDone(),
          _ => AiDecisionFailure(result),
        };
      });

  Future<void> _run(Future<AiScreenState> Function() action) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    state = const AiWorking();
    try {
      state = await action();
    } catch (_) {
      // Raw výjimka se nepropaguje do UI (R4P-010).
      state = const AiRequestFailure(ProposalUnavailable());
    } finally {
      _inFlight = false;
      ref.invalidate(aiProposalsProvider);
    }
  }
}

final aiScreenControllerProvider =
    NotifierProvider<AiScreenController, AiScreenState>(AiScreenController.new);
