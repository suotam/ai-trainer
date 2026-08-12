import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../app/configuration/app_environment.dart';
import '../../../core/ids/id_generator.dart';
import '../data/flutter_secure_session_storage.dart';
import '../data/http_auth_api_client.dart';
import '../domain/auth_api_client.dart';
import '../domain/auth_session_state.dart';
import '../domain/secure_session_storage.dart';
import 'auth_session_manager.dart';

/// Composition auth vrstvy (R2-03). Presentation čte výhradně tyto
/// providery; na platformní secure storage ani HTTP nesahá přímo
/// (TSS-005, MAR-015). V testech se hranice přepisují přes
/// `ProviderScope(overrides: ...)`.

/// Secure storage boundary (C7 §5) — platformní adaptér.
final secureSessionStorageProvider = Provider<SecureSessionStorage>(
  (ref) => FlutterSecureSessionStorage(),
);

/// Klient auth API podle C4.
final authApiClientProvider = Provider<AuthApiClient>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return HttpAuthApiClient(
    baseUrl: environment.backendBaseUrl,
    httpClient: http.Client(),
  );
});

/// Generátor idempotency key registrace (AAC-005); v testech deterministický.
final authIdempotencyKeyGeneratorProvider = Provider<IdGenerator>(
  (ref) => ref.watch(idGeneratorProvider),
);

/// Autentizační stav aplikace. První čtení spustí obnovu ze secure storage
/// (C7 §6) — bez sítě; anonymní stav je validní first-class výsledek.
final authSessionManagerProvider =
    AsyncNotifierProvider<AuthSessionManager, AuthSessionState>(
      AuthSessionManager.new,
    );
