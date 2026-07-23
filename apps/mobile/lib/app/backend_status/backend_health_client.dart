/// Klientský boundary R0 health API (VSP §10). Transportní modely patří
/// pouze ke kontraktu `packages/contracts/openapi/ai-trainer-api.yaml`
/// a nesmí se stát základem budoucí workout domény (APR-012, RER-005).
library;

/// Výsledek technického smoke checku backendu.
///
/// `ready == false` je pravdivý stav (proces běží, služba nepřijímá
/// provoz) — není to chyba klienta ani sítě.
class BackendHealthStatus {
  const BackendHealthStatus({
    required this.service,
    required this.version,
    required this.ready,
    this.requestId,
  });

  final String service;
  final String version;
  final bool ready;

  /// Korelační ID poslední odpovědi — pouze technická diagnostika,
  /// nikdy hlavní uživatelský obsah.
  final String? requestId;
}

enum BackendHealthFailureKind { unreachable, timeout, invalidResponse }

/// Bezpečná chyba smoke checku: nese pouze klasifikaci, žádné interní
/// detaily, stack trace ani URL (mobile-architecture §24).
class BackendHealthException implements Exception {
  const BackendHealthException(this.kind);

  final BackendHealthFailureKind kind;

  @override
  String toString() => 'BackendHealthException(${kind.name})';
}

/// Port pro ověření dostupnosti backendu. V testech se nahrazuje fake
/// implementací přes Riverpod override.
abstract interface class BackendHealthClient {
  /// Načte liveness (proces odpovídá) a readiness (služba přijímá provoz).
  ///
  /// Vrací [BackendHealthStatus], nebo vyhodí [BackendHealthException].
  Future<BackendHealthStatus> checkHealth();
}
