import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/settings/cubits/theme_cubit/theme_cubit.dart';
import 'package:team_manager/features/settings/cubits/theme_cubit/theme_state.dart';
import 'package:easy_localization/easy_localization.dart';

class PreferencesSettings extends StatelessWidget {
  const PreferencesSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Preferences'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Theme Switch
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            final isDark = state.themeMode == ThemeMode.dark;
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Dark Mode'.tr()),
              subtitle: Text('Toggle between dark and light themes'.tr()),
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDark ? Colors.indigoAccent : Colors.orange,
              ),
              value: isDark,
              onChanged: (_) {
                context.read<ThemeCubit>().toggleTheme();
              },
            );
          },
        ),

        const Divider(height: 24),

        // Language Switch
        Builder(
          builder: (context) {
            final isArabic = context.locale.languageCode == 'ar';
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('اللغة العربية (Arabic)'.tr()),
              subtitle: Text('Switch app language to Arabic'.tr()),
              secondary: const Icon(Icons.language_rounded, color: Colors.teal),
              value: isArabic,
              onChanged: (_) {
                if (isArabic) {
                  context.setLocale(const Locale('en'));
                } else {
                  context.setLocale(const Locale('ar'));
                }
              },
            );
          }
        ),
      ],
    );
  }
}
