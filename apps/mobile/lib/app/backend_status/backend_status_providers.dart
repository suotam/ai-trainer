import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../configuration/app_environment.dart';
import 'backend_health_client.dart';
import 'http_backend_health_client.dart';

/// Composition health clientu (ADR-002). V testech se přepisuje fake
/// implementací přes `ProviderScope(overrides: ...)`.
final backendHealthClientProvider = Provider<BackendHealthClient>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return HttpBackendHealthClient(
    baseUrl: environment.backendBaseUrl,
    httpClient: http.Client(),
  );
});

/// Stav smoke checku: loading/success/failure jako `AsyncValue`.
///
/// Kontrola proběhne jednou při prvním čtení; opakování je pouze
/// explicitní přes [retryBackendStatusCheck] — defaultní automatický
/// retry Riverpodu je vypnutý, žádný reconnect loop (r0-api-contract §9).
final backendStatusProvider = FutureProvider<BackendHealthStatus>(
  (ref) => ref.watch(backendHealthClientProvider).checkHealth(),
  retry: (retryCount, error) => null,
);

/// Jediný podporovaný způsob opakování požadavku z UI.
void retryBackendStatusCheck(WidgetRef ref) {
  ref.invalidate(backendStatusProvider);
}
