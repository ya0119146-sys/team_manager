import 'package:flutter/material.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';

/// A titled section wrapper that uses [GlassPanel] as its container.
///
/// Renders a section heading with an optional trailing widget (e.g. "View all"
/// button) above a glass-panelled body.
///
/// ```dart
/// SectionShell(
///   title: 'Recent Projects',
///   trailing: TextButton(onPressed: () {}, child: Text('View all')),
///   child: ProjectList(),
/// )
/// ```
class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
    this.titleStyle,
    this.wrapInGlass = true,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets padding;
  final TextStyle? titleStyle;
  final bool wrapInGlass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title Row ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: titleStyle ?? theme.textTheme.headlineSmall,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        const SizedBox(height: 4),

        // ── Body ──
        if (wrapInGlass)
          GlassPanel(padding: padding, child: child)
        else
          Padding(padding: padding, child: child),
      ],
    );
  }
}
