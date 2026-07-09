import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:team_manager/features/settings/widgets/tab_item.dart';

class TabsSection extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const TabsSection({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tabs = [
      (icon: Icons.person_outline_rounded, label: 'Profile'.tr()),
      (icon: Icons.security_rounded, label: 'Security'.tr()),
      (icon: Icons.settings_outlined, label: 'Preferences'.tr()),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(tabs.length, (index) {
            return TabItem(
              text: tabs[index].label,
              icon: tabs[index].icon,
              index: index,
              isSelected: selectedTab == index,
              onTap: () => onTabChanged(index),
            );
          }),
        ),
      ),
    );
  }
}
