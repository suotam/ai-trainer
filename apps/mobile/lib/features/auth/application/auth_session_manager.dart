import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sync/application/local_sync_providers.dart';
import '../domain/auth_api_client.dart';
import '../domain/auth_results.dart';
import '../domain/auth_session_state.dart';
import '../domain/secure_session_storage.dart';
import '../domain/stored_auth_session.dart';
import 'auth_providers.dart';

/// Jediný zapisující vlastník session materiálu (C7 §5, TSS-006).
///
/// Všechny operace se session materiálem (restore/sign-in/register/refresh/
/// sign-out) procházejí tímto manažerem; ostatní vrstvy konzumují pouze
/// odvozený [AuthSessionState] bez credentials. Platnost session určuje
/// výhradně server (TSS-011) — uložený materiál je jen credential cache.
class AuthSessionManager extends AsyncNotifier<AuthSessionState> {
  SecureSessionStorage get _storage => ref.read(secureSessionStorageProvider);

  AuthApiClient get _api => ref.read(authApiClientProvider);

  /// Idempotency key registrace per normalizovaný e-mail (AAC-005):
  /// retry po neznámém výsledku opakuje stejný klíč, takže nevznikne
  /// druhý účet. Jen v paměti — klíč není session materiál.
  final Map<String, String> _registrationKeys = {};

  static const int _minPasswordLength = 8;

  @override
  Future<AuthSessionState> build() => _restore();

  /// Obnova přihlašovacího stavu po startu (C7 §6): čte výhradně secure
  /// storage, bez sítě. Chybějící materiál je validní anonymní stav
  /// (TSS-007); poškozené úložiště vede na bezpečný signed-out fallback
  /// bez pádu a bez dotyku lokálních workout dat (TSS-008).
  Future<AuthSessionState> _restore() async {
    try {
      final stored = await _storage.read();
      if (stored == null) {
        return const AnonymousAuthState();
      }
      return _stateOf(stored);
    } on SecureSessionStorageException {
      await _clearQuietly();
      return const AnonymousAuthState();
    }
  }

  /// Přihlášení first-party credential (C4 login). Restart přežije jen
  /// materiál uložený přes secure storage boundary.
  Future<AuthFlowResult> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return const AuthFlowFailure(AuthFlowFailureReason.invalidInput);
    }
    if (password.isEmpty) {
      return const AuthFlowFailure(AuthFlowFailureReason.invalidInput);
    }
    try {
      final granted = await _api.login(
        email: normalizedEmail,
        password: password,
      );
      await _persist(granted);
      return const AuthFlowSuccess();
    } on AuthApiFailure catch (failure) {
      return _flowFailure(failure);
    } on SecureSessionStorageException {
      await _clearQuietly();
      state = const AsyncData(AnonymousAuthState());
      return const AuthFlowFailure(AuthFlowFailureReason.server);
    }
  }

  /// Registrace účtu (C4 register) s idempotency key stabilním per e-mail
  /// (AAC-005). Potvrzuje jen identity binding — přenos lokálních dat
  /// vlastní C15/R2-07 (AAC-015).
  Future<AuthFlowResult> registerAccount({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return const AuthFlowFailure(AuthFlowFailureReason.invalidInput);
    }
    if (password.length < _minPasswordLength) {
      return const AuthFlowFailure(AuthFlowFailureReason.invalidInput);
    }
    final idempotencyKey = _registrationKeys.putIfAbsent(
      normalizedEmail,
      () => ref.read(authIdempotencyKeyGeneratorProvider).newId(),
    );
    try {
      final granted = await _api.register(
        email: normalizedEmail,
        password: password,
        idempotencyKey: idempotencyKey,
      );
      _registrationKeys.remove(normalizedEmail);
      await _persist(granted);
      return const AuthFlowSuccess();
    } on AuthApiFailure catch (failure) {
      if (failure.kind != AuthApiFailureKind.network) {
        // Definitivní odpověď serveru — příští pokus je nová operace.
        _registrationKeys.remove(normalizedEmail);
      }
      return _flowFailure(failure);
    } on SecureSessionStorageException {
      await _clearQuietly();
      state = const AsyncData(AnonymousAuthState());
      return const AuthFlowFailure(AuthFlowFailureReason.server);
    }
  }

  /// Odhlášení (C3 §6.2, C7 §7): lokální zneplatnění je first — materiál
  /// se odstraní i offline nebo při selhání serveru (TSS-009); serverový
  /// logout je best-effort. Lokální workout data a outbox zůstávají
  /// nedotčené (LSM-006, ISC-012).
  Future<void> signOut() async {
    String? accessToken;
    try {
      accessToken = (await _storage.read())?.accessToken;
    } on SecureSessionStorageException {
      // Fail-safe: pokračuje se lokálním vyčištěním.
    }
    await _clearQuietly();
    state = const AsyncData(AnonymousAuthState());
    await _bindAnonymousQuietly();
    if (accessToken != null) {
      try {
        await _api.logout(accessToken);
      } on AuthApiFailure {
        // Best-effort — serverová revokace se dokoná při konektivitě (C13).
      }
    }
  }

  Future<void> _bindAnonymousQuietly() async {
    try {
      await ref.read(localOwnerBindingProvider).bindAnonymous();
    } catch (_) {
      // Fail-safe: vazba vlastníka nesmí shodit odhlášení.
    }
  }

  /// Serverové ověření uložené session s obnovou access session přes
  /// refresh rotaci (C4 §7, C7 §8). Revokace vede na odstranění materiálu
  /// bez ztráty lokálních dat (TSS-010); nedostupný server zachová lokální
  /// stav (offline session, security §7.3).
  Future<SessionVerification> verifySession() async {
    final StoredAuthSession? stored;
    try {
      stored = await _storage.read();
    } on SecureSessionStorageException {
      await _clearQuietly();
      state = const AsyncData(AnonymousAuthState());
      return SessionVerification.signedOutRevoked;
    }
    if (stored == null) {
      state = const AsyncData(AnonymousAuthState());
      return SessionVerification.anonymous;
    }
    try {
      await _api.sessionContext(stored.accessToken);
      state = AsyncData(_stateOf(stored));
      return SessionVerification.verifiedActive;
    } on AuthApiFailure catch (failure) {
      switch (failure.kind) {
        case AuthApiFailureKind.accessSessionExpired:
          return _refreshStored(stored);
        case AuthApiFailureKind.sessionRevoked:
        case AuthApiFailureKind.accountDisabled:
        case AuthApiFailureKind.accountDeleted:
          return _signOutRevoked();
        case AuthApiFailureKind.network:
        case AuthApiFailureKind.rateLimited:
        case AuthApiFailureKind.server:
        case AuthApiFailureKind.invalidRequest:
        case AuthApiFailureKind.invalidCredentials:
        case AuthApiFailureKind.invalidRefresh:
        case AuthApiFailureKind.duplicateLoginIdentity:
          // Konzervativně: bez potvrzené revokace se materiál nemaže,
          // ale serverové oprávnění se nepotvrzuje (TSS-011).
          return SessionVerification.offlineUnverified;
      }
    }
  }

  Future<SessionVerification> _refreshStored(StoredAuthSession stored) async {
    try {
      final granted = await _api.refresh(stored.refreshToken);
      await _persist(granted);
      return SessionVerification.refreshed;
    } on AuthApiFailure catch (failure) {
      switch (failure.kind) {
        case AuthApiFailureKind.sessionRevoked:
        case AuthApiFailureKind.invalidRefresh:
        case AuthApiFailureKind.accountDisabled:
        case AuthApiFailureKind.accountDeleted:
          return _signOutRevoked();
        case AuthApiFailureKind.network:
        case AuthApiFailureKind.rateLimited:
        case AuthApiFailureKind.server:
        case AuthApiFailureKind.invalidRequest:
        case AuthApiFailureKind.invalidCredentials:
        case AuthApiFailureKind.accessSessionExpired:
        case AuthApiFailureKind.duplicateLoginIdentity:
          return SessionVerification.offlineUnverified;
      }
    } on SecureSessionStorageException {
      await _clearQuietly();
      state = const AsyncData(AnonymousAuthState());
      return SessionVerification.signedOutRevoked;
    }
  }

  Future<SessionVerification> _signOutRevoked() async {
    await _clearQuietly();
    state = const AsyncData(AnonymousAuthState());
    await _bindAnonymousQuietly();
    return SessionVerification.signedOutRevoked;
  }

  Future<void> _persist(GrantedAuthSession granted) async {
    final stored = StoredAuthSession(
      accountId: granted.accountId,
      sessionId: granted.sessionId,
      accessToken: granted.accessToken,
      accessExpiresAt: granted.accessExpiresAt,
      refreshToken: granted.refreshToken,
      refreshExpiresAt: granted.refreshExpiresAt,
    );
    await _storage.write(stored);
    state = AsyncData(_stateOf(stored));
    // Data vytvořená po přihlášení vlastní účet (R2-05, C2 §4 ↔ C3 §7);
    // vlastnictví existujících dat se nemění (attach vlastní C15).
    try {
      await ref.read(localOwnerBindingProvider).bindAccount(granted.accountId);
    } catch (_) {
      // Selhání vazby nesmí shodit přihlášení; nová data zůstanou anonymní
      // a připojí je C15/R2-07.
    }
  }

  Future<void> _clearQuietly() async {
    try {
      await _storage.clear();
    } on SecureSessionStorageException {
      // Fail-safe (TSS-008): nedostupné úložiště nesmí shodit signed-out
      // přechod; stav aplikace je přesto anonymní.
    }
  }

  AuthenticatedAuthState _stateOf(StoredAuthSession stored) =>
      AuthenticatedAuthState(
        accountId: stored.accountId,
        sessionId: stored.sessionId,
        accessExpiresAt: stored.accessExpiresAt,
        refreshExpiresAt: stored.refreshExpiresAt,
      );

  AuthFlowFailure _flowFailure(AuthApiFailure failure) =>
      switch (failure.kind) {
        AuthApiFailureKind.invalidCredentials => const AuthFlowFailure(
          AuthFlowFailureReason.invalidCredentials,
        ),
        AuthApiFailureKind.duplicateLoginIdentity => const AuthFlowFailure(
          AuthFlowFailureReason.duplicateIdentity,
        ),
        AuthApiFailureKind.accountDisabled ||
        AuthApiFailureKind.accountDeleted => const AuthFlowFailure(
          AuthFlowFailureReason.accountUnavailable,
        ),
        AuthApiFailureKind.rateLimited => AuthFlowFailure(
          AuthFlowFailureReason.rateLimited,
          retryAfter: failure.retryAfter,
        ),
        AuthApiFailureKind.network => const AuthFlowFailure(
          AuthFlowFailureReason.network,
        ),
        AuthApiFailureKind.invalidRequest => const AuthFlowFailure(
          AuthFlowFailureReason.invalidInput,
        ),
        AuthApiFailureKind.accessSessionExpired ||
        AuthApiFailureKind.invalidRefresh ||
        AuthApiFailureKind.sessionRevoked ||
        AuthApiFailureKind.server => const AuthFlowFailure(
          AuthFlowFailureReason.server,
        ),
      };

  static String _normalizeEmail(String raw) => raw.trim().toLowerCase();
}
