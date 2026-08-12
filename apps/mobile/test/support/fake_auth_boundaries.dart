import 'package:ai_trainer_mobile/features/auth/domain/auth_api_client.dart';
import 'package:ai_trainer_mobile/features/auth/domain/secure_session_storage.dart';
import 'package:ai_trainer_mobile/features/auth/domain/stored_auth_session.dart';
import 'package:ai_trainer_mobile/features/sync/domain/local_owner_binding.dart';

/// In-memory vazba lokálního vlastníka (R2-05) pro testy bez DB.
class FakeLocalOwnerBinding implements LocalOwnerBinding {
  String currentOwner = 'local-anonymous';

  @override
  Future<void> bindAccount(String accountId) async {
    currentOwner = accountId;
  }

  @override
  Future<void> bindAnonymous() async {
    currentOwner = 'local-anonymous';
  }
}

/// In-memory secure storage fake (TSS-005 — testy neběží proti reálnému
/// Keychain/Keystore). Instance přežívá mezi ProviderContainery, takže
/// simuluje restart aplikace se zachovaným zařízením.
class InMemorySecureSessionStorage implements SecureSessionStorage {
  StoredAuthSession? stored;

  /// Simulace nedostupného/poškozeného úložiště (TSS-008).
  bool failReads = false;
  bool failWrites = false;

  int clearCount = 0;

  @override
  Future<StoredAuthSession?> read() async {
    if (failReads) {
      throw const SecureSessionStorageException();
    }
    return stored;
  }

  @override
  Future<void> write(StoredAuthSession session) async {
    if (failWrites) {
      throw const SecureSessionStorageException();
    }
    stored = session;
  }

  @override
  Future<void> clear() async {
    clearCount += 1;
    stored = null;
  }
}

class _FakeServerSession {
  _FakeServerSession({
    required this.accountId,
    required this.sessionId,
    required this.accessToken,
    required this.refreshToken,
  });

  final String accountId;
  final String sessionId;
  String accessToken;
  String refreshToken;
  final Set<String> rotatedRefreshTokens = {};
  bool revoked = false;
  bool accessExpired = false;
}

/// Deterministický fake auth API se sémantikou R2-02 backendu (C4):
/// idempotentní registrace, generické INVALID_CREDENTIALS, refresh rotace
/// s replay detekcí (replay revokuje celou session), idempotentní logout.
class FakeAuthApiClient implements AuthApiClient {
  /// Simulace nedostupného serveru — offline režim (R2P-004).
  bool offline = false;

  final Map<String, String> _passwords = {};
  final Map<String, String> _accountIds = {};
  final Map<String, String> _idempotencyKeys = {};
  final List<_FakeServerSession> _sessions = [];

  int _counter = 0;

  static final DateTime _base = DateTime.utc(2026, 8, 12, 12);

  int get accountCount => _accountIds.length;

  List<String> get usedIdempotencyKeys => _idempotencyKeys.keys.toList();

  bool sessionRevoked(String sessionId) =>
      _sessions.any((s) => s.sessionId == sessionId && s.revoked);

  /// Testovací zásah: access credential dané session expirovala.
  void expireAccess(String sessionId) {
    _sessions.firstWhere((s) => s.sessionId == sessionId).accessExpired = true;
  }

  /// Testovací zásah: serverová revokace session (např. z jiného zařízení).
  void revokeSession(String sessionId) {
    _sessions.firstWhere((s) => s.sessionId == sessionId).revoked = true;
  }

  void _requireOnline() {
    if (offline) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
  }

  GrantedAuthSession _grant(String email) {
    _counter += 1;
    final session = _FakeServerSession(
      accountId: _accountIds[email]!,
      sessionId: 'session-$_counter',
      accessToken: 'fake-access-token-$_counter',
      refreshToken: 'fake-refresh-token-$_counter',
    );
    _sessions.add(session);
    return GrantedAuthSession(
      accountId: session.accountId,
      sessionId: session.sessionId,
      accessToken: session.accessToken,
      accessExpiresAt: _base.add(const Duration(minutes: 15)),
      refreshToken: session.refreshToken,
      refreshExpiresAt: _base.add(const Duration(days: 30)),
    );
  }

  @override
  Future<GrantedAuthSession> register({
    required String email,
    required String password,
    required String idempotencyKey,
  }) async {
    _requireOnline();
    final linkedEmail = _idempotencyKeys[idempotencyKey];
    if (linkedEmail == email && _passwords[email] == password) {
      return _grant(email);
    }
    if (_accountIds.containsKey(email)) {
      throw const AuthApiFailure(AuthApiFailureKind.duplicateLoginIdentity);
    }
    _passwords[email] = password;
    _accountIds[email] = 'account-${_accountIds.length + 1}';
    _idempotencyKeys[idempotencyKey] = email;
    return _grant(email);
  }

  @override
  Future<GrantedAuthSession> login({
    required String email,
    required String password,
  }) async {
    _requireOnline();
    if (_passwords[email] != password) {
      // Generické selhání bez enumeration (AAC-008).
      throw const AuthApiFailure(AuthApiFailureKind.invalidCredentials);
    }
    return _grant(email);
  }

  @override
  Future<GrantedAuthSession> refresh(String refreshToken) async {
    _requireOnline();
    for (final session in _sessions) {
      if (session.rotatedRefreshTokens.contains(refreshToken)) {
        // Replay rotované credential → revokace celé session (C4 §7).
        session.revoked = true;
        throw const AuthApiFailure(AuthApiFailureKind.sessionRevoked);
      }
    }
    final session = _sessions.where((s) => s.refreshToken == refreshToken);
    if (session.isEmpty) {
      throw const AuthApiFailure(AuthApiFailureKind.invalidRefresh);
    }
    final current = session.first;
    if (current.revoked) {
      throw const AuthApiFailure(AuthApiFailureKind.sessionRevoked);
    }
    _counter += 1;
    current.rotatedRefreshTokens.add(current.refreshToken);
    current.accessToken = 'fake-access-token-$_counter';
    current.refreshToken = 'fake-refresh-token-$_counter';
    current.accessExpired = false;
    return GrantedAuthSession(
      accountId: current.accountId,
      sessionId: current.sessionId,
      accessToken: current.accessToken,
      accessExpiresAt: _base.add(const Duration(minutes: 15)),
      refreshToken: current.refreshToken,
      refreshExpiresAt: _base.add(const Duration(days: 30)),
    );
  }

  @override
  Future<void> logout(String accessToken) async {
    _requireOnline();
    final matches = _sessions.where((s) => s.accessToken == accessToken);
    if (matches.isEmpty) {
      throw const AuthApiFailure(AuthApiFailureKind.accessSessionExpired);
    }
    // Idempotentní no-op na již revokované session (C4 §10).
    matches.first.revoked = true;
  }

  @override
  Future<AuthSessionContext> sessionContext(String accessToken) async {
    _requireOnline();
    final matches = _sessions.where((s) => s.accessToken == accessToken);
    if (matches.isEmpty) {
      throw const AuthApiFailure(AuthApiFailureKind.accessSessionExpired);
    }
    final session = matches.first;
    if (session.revoked) {
      throw const AuthApiFailure(AuthApiFailureKind.sessionRevoked);
    }
    if (session.accessExpired) {
      throw const AuthApiFailure(AuthApiFailureKind.accessSessionExpired);
    }
    return AuthSessionContext(
      accountId: session.accountId,
      sessionId: session.sessionId,
      accountType: 'STANDARD',
      accountStatus: 'ACTIVE',
      accessExpiresAt: _base.add(const Duration(minutes: 15)),
    );
  }
}
