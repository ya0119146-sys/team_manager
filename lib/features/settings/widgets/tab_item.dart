import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  const TabItem({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.widget,
    this.icon,
  });

  final String text;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? widget;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedBg = theme.colorScheme.primary;
    final selectedFg = theme.colorScheme.onPrimary;
    final unselectedFg =
        isDark ? Colors.white.withValues(alpha: 0.55) : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: widget ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 13,
                    color: isSelected ? selectedFg : unselectedFg,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? selectedFg : unselectedFg,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
