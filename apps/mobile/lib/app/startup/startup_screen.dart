import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../configuration/app_environment.dart';

/// Technická úvodní obrazovka pro ověření R0 bootstrapu (VSP §5).
///
/// Není to produktová feature — pouze potvrzuje, že composition root,
/// routing, theme, lokalizace a environment boundary fungují. V R0-07
/// bude rozšířena o technické zobrazení dostupnosti backendu.
class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  /// Stabilní klíč pro widget testy a pozdější smoke testy.
  static const Key screenKey = Key('startup_screen');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final environment = ref.watch(appEnvironmentProvider);

    return Scaffold(
      key: screenKey,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.startupScreenTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.startupScreenSubtitle),
            const SizedBox(height: 8),
            Text(l10n.startupScreenEnvironmentLabel(environment.name)),
          ],
        ),
      ),
    );
  }
}
