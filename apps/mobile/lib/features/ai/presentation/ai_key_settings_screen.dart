import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/ai_providers.dart';
import '../data/anthropic_direct_client.dart';
import '../domain/byok_key_store.dart';

/// Správa BYOK klíče (R7-01, C46 §2/§5): zadání, maskované zobrazení
/// (BYK-002 — nikdy celý klíč), smazání (BYK-014) a explicitní ověření
/// (BYK-012). Klíč žije výhradně v secure storage (BYK-001).
class AiKeySettingsScreen extends ConsumerWidget {
  const AiKeySettingsScreen({super.key});

  static const Key screenKey = Key('ai_key_screen');
  static const Key fieldKey = Key('ai_key_field');
  static const Key saveButtonKey = Key('ai_key_save');
  static const Key deleteButtonKey = Key('ai_key_delete');
  static const Key verifyButtonKey = Key('ai_key_verify');
  static const Key statusKey = Key('ai_key_status');
  static const Key verifyResultKey = Key('ai_key_verify_result');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(byokControllerProvider);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(l10n.byokTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.byokIntro),
          const SizedBox(height: 16),
          Text(
            key: statusKey,
            state.maskedKey == null
                ? l10n.byokMissingLabel
                : l10n.byokStoredLabel(state.maskedKey!),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          _KeyEntryField(enabled: !state.busy),
          const SizedBox(height: 16),
          if (state.maskedKey != null) ...[
            OutlinedButton.icon(
              key: verifyButtonKey,
              icon: const Icon(Icons.verified_outlined),
              label: Text(l10n.byokVerifyButton),
              onPressed: state.busy
                  ? null
                  : () => ref.read(byokControllerProvider.notifier).verify(),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              key: deleteButtonKey,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.byokDeleteButton),
              onPressed: state.busy
                  ? null
                  : () => ref.read(byokControllerProvider.notifier).delete(),
            ),
          ],
          if (state.verifyResult != null) ...[
            const SizedBox(height: 16),
            Text(key: verifyResultKey, switch (state.verifyResult!) {
              ByokVerifyResult.valid => l10n.byokVerifyValid,
              ByokVerifyResult.invalidKey => l10n.byokVerifyInvalidKey,
              ByokVerifyResult.noCredit => l10n.byokVerifyNoCredit,
              ByokVerifyResult.network => l10n.byokVerifyNetwork,
            }),
          ],
        ],
      ),
    );
  }
}

class _KeyEntryField extends ConsumerStatefulWidget {
  const _KeyEntryField({required this.enabled});

  final bool enabled;

  @override
  ConsumerState<_KeyEntryField> createState() => _KeyEntryFieldState();
}

class _KeyEntryFieldState extends ConsumerState<_KeyEntryField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: AiKeySettingsScreen.fieldKey,
          controller: _controller,
          enabled: widget.enabled,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(labelText: l10n.byokFieldLabel),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: AiKeySettingsScreen.saveButtonKey,
          onPressed: widget.enabled
              ? () async {
                  final saved = await ref
                      .read(byokControllerProvider.notifier)
                      .save(_controller.text);
                  if (saved) {
                    _controller.clear();
                  }
                }
              : null,
          child: Text(l10n.byokSaveButton),
        ),
      ],
    );
  }
}

/// UI stav správy klíče — jen maska, nikdy celý klíč (BYK-002).
class ByokState {
  const ByokState({this.maskedKey, this.busy = false, this.verifyResult});

  final String? maskedKey;
  final bool busy;
  final ByokVerifyResult? verifyResult;
}

/// Controller správy klíče: čtení masky, uložení (trim, bez mezer),
/// smazání a explicitní ověření (BYK-012). Klíč drží jen secure storage.
class ByokController extends Notifier<ByokState> {
  @override
  ByokState build() {
    _load();
    return const ByokState(busy: true);
  }

  Future<void> _load() async {
    String? masked;
    try {
      final key = await ref.read(byokKeyStoreProvider).read();
      masked = key == null ? null : maskByokKey(key);
    } on ByokKeyStoreException {
      masked = null;
    }
    state = ByokState(maskedKey: masked);
  }

  Future<bool> save(String rawKey) async {
    final key = rawKey.trim();
    if (key.isEmpty || key.contains(' ')) {
      return false;
    }
    state = ByokState(maskedKey: state.maskedKey, busy: true);
    try {
      await ref.read(byokKeyStoreProvider).write(key);
      state = ByokState(maskedKey: maskByokKey(key));
      return true;
    } on ByokKeyStoreException {
      state = ByokState(maskedKey: state.maskedKey);
      return false;
    }
  }

  Future<void> delete() async {
    state = ByokState(maskedKey: state.maskedKey, busy: true);
    try {
      await ref.read(byokKeyStoreProvider).clear();
    } on ByokKeyStoreException {
      // Fail-safe: stav se znovu načte z úložiště níže.
    }
    await _load();
  }

  Future<void> verify() async {
    state = ByokState(maskedKey: state.maskedKey, busy: true);
    final client = ref.read(aiApiClientProvider);
    final result = client is AnthropicDirectClient
        ? await client.verifyKey()
        : ByokVerifyResult.network;
    state = ByokState(maskedKey: state.maskedKey, verifyResult: result);
  }
}

final byokControllerProvider = NotifierProvider<ByokController, ByokState>(
  ByokController.new,
);
