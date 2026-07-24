import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import 'backend_status_providers.dart';

/// Technický stavový blok mobile-to-backend smoke flow (VSP §10).
///
/// Zobrazuje pouze technickou dostupnost backendu pro R0 ověření —
/// nevydává ji za produktovou připravenost aplikace. Chybové stavy
/// neobsahují interní detaily (mobile-architecture §24).
class BackendStatusSection extends ConsumerWidget {
  const BackendStatusSection({super.key});

  static const Key loadingKey = Key('backend_status_loading');
  static const Key successKey = Key('backend_status_success');
  static const Key notReadyKey = Key('backend_status_not_ready');
  static const Key failureKey = Key('backend_status_failure');
  static const Key retryKey = Key('backend_status_retry');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(backendStatusProvider);

    return status.when(
      loading: () => Column(
        key: loadingKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 8),
          Text(l10n.backendStatusChecking),
        ],
      ),
      data: (health) => health.ready
          ? Text(
              key: successKey,
              l10n.backendStatusReady(health.service, health.version),
            )
          : Column(
              key: notReadyKey,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.backendStatusNotReady),
                const SizedBox(height: 8),
                _retryButton(ref, l10n),
              ],
            ),
      // Bezpečná zpráva pro všechny druhy selhání — bez raw výjimky.
      error: (_, _) => Column(
        key: failureKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.backendStatusUnavailable),
          const SizedBox(height: 8),
          _retryButton(ref, l10n),
        ],
      ),
    );
  }

  Widget _retryButton(WidgetRef ref, AppLocalizations l10n) => OutlinedButton(
    key: retryKey,
    onPressed: () => retryBackendStatusCheck(ref),
    child: Text(l10n.backendStatusRetry),
  );
}
