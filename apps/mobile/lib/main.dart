import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap/ai_trainer_app.dart';

/// Composition root: jediné místo, kde se sestavuje kořenový
/// ProviderScope (ADR-002) a spouští aplikace.
void main() {
  runApp(const ProviderScope(child: AiTrainerApp()));
}
