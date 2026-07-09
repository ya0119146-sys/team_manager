import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_manager/core/theme/app_colors.dart';

/// A reusable frosted-glass panel built on [BackdropFilter].
///
/// Wraps its [child] in a clipped, blurred container with a semi-transparent
/// fill and a thin white border — the signature "cut glass" look.
///
/// ```dart
/// GlassPanel(
///   child: Text('Hello Glass'),
/// )
/// ```
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.05,
    this.borderWidth = 0.5,
    this.borderOpacity = 0.1,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.border,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double borderWidth;
  final double borderOpacity;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: opacity)
                  : Colors.white.withValues(alpha: 0.65),
              borderRadius: borderRadius,
              border: border ?? Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: borderOpacity)
                    : AppColors.dividerLight,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
