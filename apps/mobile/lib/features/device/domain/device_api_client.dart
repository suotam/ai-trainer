import '../../auth/domain/auth_api_client.dart';

/// Registrovaná instalace potvrzená serverem (C9 §5).
final class RegisteredDevice {
  const RegisteredDevice({required this.installationId, required this.status});

  final String installationId;
  final String status;
}

/// Klientská hranice device API (C9). Registrace je idempotentní upsert
/// podle installation ID (DRC-006); selhání se mapují na typované
/// [AuthApiFailure] — žádný raw HTTP detail do application/UI vrstvy.
abstract interface class DeviceApiClient {
  Future<RegisteredDevice> registerDevice({
    required String accessToken,
    required String installationId,
    required String platform,
    required String appVersion,
    required String localSchemaVersion,
  });
}
