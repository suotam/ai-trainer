import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/secure_session_storage.dart';
import '../domain/stored_auth_session.dart';

/// Platformní secure storage adaptér (C7 §5): Keychain (iOS) / Keystore-
/// šifrované úložiště (Android) přes flutter_secure_storage. Session
/// materiál žije pod jediným klíčem jako jeden JSON zápis — částečně
/// zapsaný stav není čitelný jako platný. Nikdy Drift/SQLite, preferences
/// ani běžný soubor (TSS-002/003); hodnoty se nelogují (TSS-004).
class FlutterSecureSessionStorage implements SecureSessionStorage {
  FlutterSecureSessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String storageKey = 'aitrainer.auth.session.v1';

  @override
  Future<StoredAuthSession?> read() async {
    final String? raw;
    try {
      raw = await _storage.read(key: storageKey);
    } catch (_) {
      // Platformní selhání → fail-safe signál (TSS-008), žádný raw detail.
      throw const SecureSessionStorageException();
    }
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException();
      }
      return StoredAuthSession(
        accountId: decoded['accountId']! as String,
        sessionId: decoded['sessionId']! as String,
        accessToken: decoded['accessToken']! as String,
        accessExpiresAt: DateTime.parse(
          decoded['accessExpiresAt']! as String,
        ).toUtc(),
        refreshToken: decoded['refreshToken']! as String,
        refreshExpiresAt: DateTime.parse(
          decoded['refreshExpiresAt']! as String,
        ).toUtc(),
      );
    } catch (_) {
      // Poškozený obsah je nečitelný → signál pro bezpečný signed-out
      // fallback (TSS-008); volající materiál vyčistí.
      throw const SecureSessionStorageException();
    }
  }

  @override
  Future<void> write(StoredAuthSession session) async {
    final payload = jsonEncode({
      'accountId': session.accountId,
      'sessionId': session.sessionId,
      'accessToken': session.accessToken,
      'accessExpiresAt': session.accessExpiresAt.toUtc().toIso8601String(),
      'refreshToken': session.refreshToken,
      'refreshExpiresAt': session.refreshExpiresAt.toUtc().toIso8601String(),
    });
    try {
      await _storage.write(key: storageKey, value: payload);
    } catch (_) {
      throw const SecureSessionStorageException();
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: storageKey);
    } catch (_) {
      throw const SecureSessionStorageException();
    }
  }
}
