import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/profile_providers.dart';
import '../domain/profile_api_client.dart';

/// Sekce R2 baseline AthleteProfile na account obrazovce (R2-04):
/// zobrazení existujícího profilu, nebo minimální formulář vytvoření.
/// Chyby jsou typované a bezpečné; načtení se neopakuje automaticky.
class ProfileSection extends ConsumerStatefulWidget {
  const ProfileSection({super.key});

  static const Key sectionKey = Key('profile_section');
  static const Key nameFieldKey = Key('profile_name_field');
  static const Key createButtonKey = Key('profile_create_button');
  static const Key profileLabelKey = Key('profile_label');
  static const Key errorKey = Key('profile_error');
  static const Key loadErrorKey = Key('profile_load_error');

  @override
  ConsumerState<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<ProfileSection> {
  final _nameController = TextEditingController();
  bool _creating = false;
  ProfileCreateFailureReason? _failure;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_creating) {
      return;
    }
    setState(() {
      _creating = true;
      _failure = null;
    });
    final result = await ref
        .read(createProfileControllerProvider)
        .create(displayName: _nameController.text);
    if (!mounted) {
      return;
    }
    setState(() {
      _creating = false;
      _failure = switch (result) {
        ProfileCreateSuccess() => null,
        ProfileCreateFailure(:final reason) => reason,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(currentProfileProvider);

    return Column(
      key: ProfileSection.sectionKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.profileSectionTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        profile.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          // Bezpečná chyba bez interního detailu; opakování explicitně.
          error: (_, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.profileLoadError, key: ProfileSection.loadErrorKey),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(currentProfileProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
          data: (existing) => existing == null
              ? _buildCreateForm(l10n)
              : _buildProfile(l10n, existing),
        ),
      ],
    );
  }

  Widget _buildProfile(AppLocalizations l10n, AthleteProfileView profile) =>
      Text(
        l10n.profileLabel(profile.displayName),
        key: ProfileSection.profileLabelKey,
      );

  Widget _buildCreateForm(AppLocalizations l10n) {
    final failure = _failure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.profileEmpty),
        const SizedBox(height: 8),
        Semantics(
          textField: true,
          label: l10n.profileDisplayNameLabel,
          child: TextField(
            key: ProfileSection.nameFieldKey,
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.profileDisplayNameLabel,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (failure != null) ...[
          Text(
            switch (failure) {
              ProfileCreateFailureReason.invalidInput =>
                l10n.profileCreateInvalid,
              ProfileCreateFailureReason.network => l10n.authErrorNetwork,
              ProfileCreateFailureReason.notSignedIn ||
              ProfileCreateFailureReason.server => l10n.profileCreateError,
            },
            key: ProfileSection.errorKey,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton(
          key: ProfileSection.createButtonKey,
          onPressed: _creating ? null : _create,
          child: Text(l10n.profileCreateButton),
        ),
      ],
    );
  }
}
