import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_manager/core/theme/app_colors.dart';

/// A premium animated button with gradient fill and scale-press effect.
///
/// On tap-down the button scales to 0.95, giving a satisfying tactile feel.
/// Supports both gradient and solid-color modes.
///
/// ```dart
/// GlassButton(
///   label: 'Get Started',
///   onPressed: () {},
///   icon: Icons.arrow_forward,
/// )
/// ```
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
    this.isLoading = false,
    this.isOutlined = false,
    this.fontSize = 14,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color foregroundColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final bool isOutlined;
  final double fontSize;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveGradient = widget.gradient ??
        (widget.isOutlined ? null : AppColors.primaryGradient);

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: widget.isOutlined
                ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.isOutlined ? null : effectiveGradient,
                color: widget.isOutlined
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.7))
                    : widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: widget.isOutlined
                    ? Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.dividerLight,
                        width: 0.5,
                      )
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: widget.foregroundColor,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: widget.isOutlined
                                  ? (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight)
                                  : widget.foregroundColor,
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (widget.icon != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              widget.icon,
                              color: widget.isOutlined
                                  ? (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight)
                                  : widget.foregroundColor,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
