import 'package:flutter/foundation.dart';

/// R2 baseline AthleteProfile pohled na klientu (C6 §8.1) — jen ne-secret
/// hodnoty pro zobrazení.
@immutable
final class AthleteProfileView {
  const AthleteProfileView({
    required this.profileId,
    required this.displayName,
    this.primarySport,
    this.experienceLevel,
  });

  final String profileId;
  final String displayName;
  final String? primarySport;
  final String? experienceLevel;
}

/// Klientská hranice profile API (R2-04). Server je autorita ownership
/// (AOC-002/004); selhání se mapují na typované AuthApiFailure.
abstract interface class ProfileApiClient {
  /// Vytvoří SELF profil s client-generated [profileId] (SDM-005). Retry se
  /// stejným ID je na serveru idempotentní.
  Future<AthleteProfileView> createProfile({
    required String accessToken,
    required String profileId,
    required String displayName,
    String? primarySport,
  });

  /// SELF profil principala; `null`, pokud zatím neexistuje.
  Future<AthleteProfileView?> currentProfile(String accessToken);
}
