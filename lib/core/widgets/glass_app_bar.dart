import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_manager/core/theme/app_colors.dart';

/// A glassmorphism-styled AppBar with backdrop blur.
///
/// Sits at the top of the main scaffold and provides:
/// - Menu button (leading)
/// - Brand logo
/// - Actions: theme toggle, notification bell, avatar
///
/// ```dart
/// GlassAppBar(
///   leading: IconButton(icon: Icon(Icons.menu), onPressed: openDrawer),
///   title: Text('Dashboard'),
///   actions: [ThemeToggle(), NotificationBell(), AvatarMenu()],
/// )
/// ```
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.height = 60,
    this.blur = 20,
    this.showBorder = true,
  });

  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final double height;
  final double blur;
  final bool showBorder;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.scaffoldDark.withValues(alpha: 0.7)
                : AppColors.surfaceLight.withValues(alpha: 0.85),
            border: showBorder
                ? Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppColors.dividerLight,
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                if (leading != null) leading!,
                if (title != null) ...[
                  const SizedBox(width: 4),
                  Expanded(child: title!),
                ] else
                  const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
