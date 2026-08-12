import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../device/application/device_registrar.dart';
import '../../profile/presentation/profile_section.dart';
import '../application/auth_providers.dart';
import '../domain/auth_results.dart';
import '../domain/auth_session_state.dart';

/// Account obrazovka (R2-03): přihlášení/registrace a odhlášení nad
/// [authSessionManagerProvider]. R1 offline tok na přihlášení nezávisí —
/// obrazovka je volitelný vstup, ne gate (R2P-004). Zobrazuje jen odvozený
/// stav bez credentials (TSS-012); chyby jsou typované a bezpečné.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  static const Key screenKey = Key('account_screen');
  static const Key emailFieldKey = Key('account_email_field');
  static const Key passwordFieldKey = Key('account_password_field');
  static const Key submitButtonKey = Key('account_submit_button');
  static const Key switchModeKey = Key('account_switch_mode');
  static const Key errorKey = Key('account_error');
  static const Key signedInKey = Key('account_signed_in');
  static const Key signOutButtonKey = Key('account_sign_out_button');
  static const Key verifyButtonKey = Key('account_verify_button');
  static const Key verificationStatusKey = Key('account_verification_status');

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registerMode = false;
  bool _submitting = false;
  AuthFlowFailure? _failure;
  SessionVerification? _verification;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Guard proti dvojitému tapu — jedna operace v letu.
    if (_submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _failure = null;
    });
    final manager = ref.read(authSessionManagerProvider.notifier);
    final result = _registerMode
        ? await manager.registerAccount(
            email: _emailController.text,
            password: _passwordController.text,
          )
        : await manager.signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
      _failure = switch (result) {
        AuthFlowSuccess() => null,
        AuthFlowFailure() => result,
      };
      if (result is AuthFlowSuccess) {
        _passwordController.clear();
        _verification = null;
      }
    });
    if (result is AuthFlowSuccess) {
      // Registrace zařízení po přihlášení (C9 §5, DRC-004/015): best-effort,
      // bez retry loopu — selhání nebrání použití aplikace, další pokus
      // proběhne při příštím přihlášení.
      unawaited(ref.read(deviceRegistrarProvider).registerThisDevice());
    }
  }

  Future<void> _signOut() async {
    if (_submitting) {
      return;
    }
    setState(() => _submitting = true);
    await ref.read(authSessionManagerProvider.notifier).signOut();
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
      _verification = null;
    });
  }

  Future<void> _verify() async {
    if (_submitting) {
      return;
    }
    setState(() => _submitting = true);
    final verification = await ref
        .read(authSessionManagerProvider.notifier)
        .verifySession();
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
      _verification = verification;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authSessionManagerProvider);

    return Scaffold(
      key: AccountScreen.screenKey,
      appBar: AppBar(title: Text(l10n.accountScreenTitle)),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // Manager mapuje selhání na anonymní stav; tato větev je poslední
        // záchrana a vede na přihlašovací formulář.
        error: (_, _) => _buildForm(l10n),
        data: (state) => switch (state) {
          AnonymousAuthState() => _buildForm(l10n),
          AuthenticatedAuthState() => _buildSignedIn(l10n, state),
        },
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final failure = _failure;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _registerMode ? l10n.authRegisterIntro : l10n.authSignInIntro,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.accountLocalDataNote),
          const SizedBox(height: 24),
          Semantics(
            textField: true,
            label: l10n.authEmailLabel,
            child: TextField(
              key: AccountScreen.emailFieldKey,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(labelText: l10n.authEmailLabel),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            textField: true,
            label: l10n.authPasswordLabel,
            child: TextField(
              key: AccountScreen.passwordFieldKey,
              controller: _passwordController,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(labelText: l10n.authPasswordLabel),
            ),
          ),
          const SizedBox(height: 24),
          if (failure != null) ...[
            Text(
              _failureMessage(l10n, failure),
              key: AccountScreen.errorKey,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            key: AccountScreen.submitButtonKey,
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _registerMode
                        ? l10n.authRegisterButton
                        : l10n.authSignInButton,
                  ),
          ),
          TextButton(
            key: AccountScreen.switchModeKey,
            onPressed: _submitting
                ? null
                : () => setState(() {
                    _registerMode = !_registerMode;
                    _failure = null;
                  }),
            child: Text(
              _registerMode
                  ? l10n.authSwitchToSignIn
                  : l10n.authSwitchToRegister,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignedIn(AppLocalizations l10n, AuthenticatedAuthState state) {
    final verification = _verification;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            child: Text(
              l10n.accountSignedIn,
              key: AccountScreen.signedInKey,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.accountIdLabel(state.accountId)),
          const SizedBox(height: 8),
          Text(l10n.accountLocalDataNote),
          const SizedBox(height: 24),
          const ProfileSection(),
          const SizedBox(height: 24),
          if (verification != null) ...[
            Text(
              _verificationMessage(l10n, verification),
              key: AccountScreen.verificationStatusKey,
            ),
            const SizedBox(height: 16),
          ],
          OutlinedButton(
            key: AccountScreen.verifyButtonKey,
            onPressed: _submitting ? null : _verify,
            child: Text(l10n.accountVerifyButton),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            key: AccountScreen.signOutButtonKey,
            onPressed: _submitting ? null : _signOut,
            child: Text(l10n.accountSignOutButton),
          ),
        ],
      ),
    );
  }

  String _failureMessage(AppLocalizations l10n, AuthFlowFailure failure) =>
      switch (failure.reason) {
        AuthFlowFailureReason.invalidInput => l10n.authErrorInvalidInput,
        AuthFlowFailureReason.invalidCredentials =>
          l10n.authErrorInvalidCredentials,
        AuthFlowFailureReason.duplicateIdentity =>
          l10n.authErrorDuplicateIdentity,
        AuthFlowFailureReason.accountUnavailable =>
          l10n.authErrorAccountUnavailable,
        AuthFlowFailureReason.rateLimited => l10n.authErrorRateLimited,
        AuthFlowFailureReason.network => l10n.authErrorNetwork,
        AuthFlowFailureReason.server => l10n.authErrorServer,
      };

  String _verificationMessage(
    AppLocalizations l10n,
    SessionVerification verification,
  ) => switch (verification) {
    SessionVerification.anonymous ||
    SessionVerification.signedOutRevoked => l10n.accountVerifyRevoked,
    SessionVerification.verifiedActive => l10n.accountVerifyActive,
    SessionVerification.refreshed => l10n.accountVerifyRefreshed,
    SessionVerification.offlineUnverified => l10n.accountVerifyOffline,
  };
}
