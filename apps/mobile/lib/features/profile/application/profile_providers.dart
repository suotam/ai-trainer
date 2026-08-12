import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../app/configuration/app_environment.dart';
import '../../../core/ids/id_generator.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_api_client.dart';
import '../../auth/domain/auth_session_state.dart';
import '../../auth/domain/secure_session_storage.dart';
import '../data/http_profile_api_client.dart';
import '../domain/profile_api_client.dart';

/// Composition profile vrstvy (R2-04). UI čte jen tyto providery;
/// v testech se hranice přepisují přes `ProviderScope(overrides: ...)`.

final profileApiClientProvider = Provider<ProfileApiClient>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return HttpProfileApiClient(
    baseUrl: environment.backendBaseUrl,
    httpClient: http.Client(),
  );
});

/// SELF profil přihlášeného účtu; `null` = žádný profil nebo anonymní stav.
/// Načítá se jednou na auth stav; opakování je explicitní invalidací —
/// žádný automatický retry loop.
final currentProfileProvider = FutureProvider<AthleteProfileView?>((ref) async {
  final authState = await ref.watch(authSessionManagerProvider.future);
  if (authState is! AuthenticatedAuthState) {
    return null;
  }
  final stored = await ref.read(secureSessionStorageProvider).read();
  if (stored == null) {
    return null;
  }
  return ref.read(profileApiClientProvider).currentProfile(stored.accessToken);
}, retry: (retryCount, error) => null);

sealed class ProfileCreateResult {
  const ProfileCreateResult();
}

final class ProfileCreateSuccess extends ProfileCreateResult {
  const ProfileCreateSuccess(this.profile);

  final AthleteProfileView profile;
}

enum ProfileCreateFailureReason { invalidInput, notSignedIn, network, server }

final class ProfileCreateFailure extends ProfileCreateResult {
  const ProfileCreateFailure(this.reason);

  final ProfileCreateFailureReason reason;
}

/// Vytvoření SELF profilu s client-generated ID (SDM-005). ID zůstává
/// stabilní přes retry po neznámém výsledku — server je idempotentní
/// podle profileId, takže opakování nevytvoří druhý profil.
class CreateProfileController {
  CreateProfileController(this._ref);

  final Ref _ref;

  String? _pendingProfileId;

  Future<ProfileCreateResult> create({
    required String displayName,
    String? primarySport,
  }) async {
    final trimmedName = displayName.trim();
    if (trimmedName.isEmpty || trimmedName.length > 100) {
      return const ProfileCreateFailure(
        ProfileCreateFailureReason.invalidInput,
      );
    }
    final StoredSessionToken? token = await _readToken();
    if (token == null) {
      return const ProfileCreateFailure(ProfileCreateFailureReason.notSignedIn);
    }
    final profileId = _pendingProfileId ??= _ref
        .read(idGeneratorProvider)
        .newId();
    try {
      final profile = await _ref
          .read(profileApiClientProvider)
          .createProfile(
            accessToken: token.accessToken,
            profileId: profileId,
            displayName: trimmedName,
            primarySport: primarySport,
          );
      _pendingProfileId = null;
      _ref.invalidate(currentProfileProvider);
      return ProfileCreateSuccess(profile);
    } on AuthApiFailure catch (failure) {
      switch (failure.kind) {
        case AuthApiFailureKind.network:
          // Klíč zůstává — retry se stejným ID je bez duplicit.
          return const ProfileCreateFailure(ProfileCreateFailureReason.network);
        case AuthApiFailureKind.invalidRequest:
          _pendingProfileId = null;
          return const ProfileCreateFailure(
            ProfileCreateFailureReason.invalidInput,
          );
        case AuthApiFailureKind.accessSessionExpired:
        case AuthApiFailureKind.sessionRevoked:
          _pendingProfileId = null;
          return const ProfileCreateFailure(
            ProfileCreateFailureReason.notSignedIn,
          );
        default:
          _pendingProfileId = null;
          return const ProfileCreateFailure(ProfileCreateFailureReason.server);
      }
    }
  }

  Future<StoredSessionToken?> _readToken() async {
    try {
      final stored = await _ref.read(secureSessionStorageProvider).read();
      if (stored == null) {
        return null;
      }
      return StoredSessionToken(stored.accessToken);
    } on SecureSessionStorageException {
      return null;
    }
  }
}

/// Obal access credential pro interní předání — nikdy se neloguje.
final class StoredSessionToken {
  const StoredSessionToken(this.accessToken);

  final String accessToken;

  @override
  String toString() => 'StoredSessionToken(<redacted>)';
}

final createProfileControllerProvider = Provider<CreateProfileController>(
  CreateProfileController.new,
);
