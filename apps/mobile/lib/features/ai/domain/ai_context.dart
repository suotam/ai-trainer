import 'package:flutter/foundation.dart';

/// Klasifikace AI požadavků (C27 §2 + C36 §2). Nový typ se přidává
/// výhradně kontraktem, ne implementací (ACX-001).
enum AiRequestType {
  planProposal('PLAN_PROPOSAL'),

  /// Úprava existujícího dne/týdne (R5, C36).
  adjustmentProposal('ADJUSTMENT_PROPOSAL');

  const AiRequestType(this.code);

  final String code;
}

/// Minimalizovaný autorizovaný AIContext (C27) — jediný obsah, který o
/// uživateli odchází do modelu. By-value bez identifikátorů (ACX-003),
/// bez poznámek (ACX-005), jen aktivní data (ACX-006), deterministický
/// (ACX-008).
@immutable
class AiContext {
  const AiContext({required this.requestType, required this.payload});

  final AiRequestType requestType;

  /// Deterministicky uspořádaný JSON-serializovatelný obsah dle C27 §3.
  final Map<String, Object?> payload;
}

/// Port builderu kontextu (C27, R4-02). Čistě lokální, bez sítě (ACX-014);
/// data výhradně aktuálního vlastníka (ACX-012).
abstract interface class AiContextBuilder {
  Future<AiContext> buildPlanProposalContext({required DateTime now});

  /// Adjustment kontext (C36 §3): C27 základ + týden plánu by-value,
  /// check-in agregáty a C34 safety stav jako fakt (ADX-005).
  Future<AiContext> buildAdjustmentContext({required DateTime now});
}
