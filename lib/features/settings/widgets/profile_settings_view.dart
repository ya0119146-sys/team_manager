import 'package:flutter/material.dart';
import 'package:team_manager/features/auth/model/profle_model.dart';
import 'package:team_manager/features/settings/widgets/personal_information.dart';
import 'package:team_manager/features/settings/widgets/profile_card.dart';
import 'package:team_manager/features/settings/widgets/security_settings.dart';
import 'package:team_manager/features/settings/widgets/tabs_section.dart';
import 'package:team_manager/features/settings/widgets/preferences_settings.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileSettingsView extends StatelessWidget {
  final ProfileModel profile;
  final int selectedTab;
  final Function(int) onTabChanged;

  const ProfileSettingsView({
    super.key,
    required this.profile,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Profile & Settings'.tr(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage your account settings and preferences'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 28),

        ProfileCard(profile: profile),

        const SizedBox(height: 24),

        TabsSection(selectedTab: selectedTab, onTabChanged: onTabChanged),

        const SizedBox(height: 24),

        switch (selectedTab) {
          0 => PersonalInformation(profileModel: profile),
          1 => const SecuritySettings(),
          2 => const PreferencesSettings(),
          _ => PersonalInformation(profileModel: profile),
        },
      ],
    );
  }
}
