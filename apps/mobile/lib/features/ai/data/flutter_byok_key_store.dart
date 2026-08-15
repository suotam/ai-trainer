import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/byok_key_store.dart';

/// Platformní secure storage adaptér klíče (C46 §2): Keychain/Keystore
/// přes flutter_secure_storage pod vyhrazeným klíčem. Hodnota se nikdy
/// neloguje ani nedostává do DB/preferences (BYK-001).
class FlutterByokKeyStore implements ByokKeyStore {
  FlutterByokKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String storageKey = 'aitrainer.ai.byok.v1';

  @override
  Future<String?> read() async {
    try {
      final raw = await _storage.read(key: storageKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      return raw;
    } catch (_) {
      // Platformní selhání → typovaný fail-safe, žádný raw detail (BYK-010).
      throw const ByokKeyStoreException();
    }
  }

  @override
  Future<void> write(String key) async {
    try {
      await _storage.write(key: storageKey, value: key);
    } catch (_) {
      throw const ByokKeyStoreException();
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: storageKey);
    } catch (_) {
      throw const ByokKeyStoreException();
    }
  }
}
