import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_manager/core/theme/app_colors.dart';

// Global reference to the current active overlay entry to prevent stacking/queuing
OverlayEntry? _currentOverlayEntry;

void customScafoldMessenger(
  BuildContext context,
  String message, {
  Color color = Colors.red,
  String position = "top", // "top", "center", or "bottom"
}) {
  // Remove any existing active toast immediately
  if (_currentOverlayEntry != null) {
    try {
      _currentOverlayEntry!.remove();
    } catch (_) {
      // Handle case where it was already removed
    }
    _currentOverlayEntry = null;
  }

  final overlayState = Overlay.of(context);

  // Map input color (or default) to appropriate icon, title, and theme alignment
  IconData iconData;
  String title;
  Color accentColor;

  if (color == Colors.green || color == AppColors.successColor) {
    iconData = Icons.check_circle_rounded;
    title = "Success";
    accentColor = AppColors.successColor;
  } else if (color == Colors.red || color == AppColors.errorColor) {
    iconData = Icons.error_rounded;
    title = "Error";
    accentColor = AppColors.errorColor;
  } else if (color == Colors.amber || color == AppColors.accentAmber) {
    iconData = Icons.warning_rounded;
    title = "Warning";
    accentColor = AppColors.accentAmber;
  } else {
    // Custom info or notification color
    iconData = Icons.info_rounded;
    title = "Notification";
    accentColor = color;
  }

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _GlassToastOverlay(
      message: message,
      title: title,
      iconData: iconData,
      accentColor: accentColor,
      position: position,
      onDismiss: () {
        if (_currentOverlayEntry == overlayEntry) {
          try {
            overlayEntry.remove();
          } catch (_) {}
          _currentOverlayEntry = null;
        }
      },
    ),
  );

  _currentOverlayEntry = overlayEntry;
  overlayState.insert(overlayEntry);
}

class _GlassToastOverlay extends StatefulWidget {
  final String message;
  final String title;
  final IconData iconData;
  final Color accentColor;
  final String position;
  final VoidCallback onDismiss;

  const _GlassToastOverlay({
    required this.message,
    required this.title,
    required this.iconData,
    required this.accentColor,
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_GlassToastOverlay> createState() => _GlassToastOverlayState();
}

class _GlassToastOverlayState extends State<_GlassToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.position == "top"
          ? const Offset(0, -0.5)
          : (widget.position == "center"
                ? const Offset(0, 0.1)
                : const Offset(0, 0.5)),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(milliseconds: 5000), () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (mounted && !_isDismissing) {
      setState(() {
        _isDismissing = true;
      });
      _controller.reverse().then((_) {
        if (mounted) {
          widget.onDismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    double? topPosition;
    double? bottomPosition;

    if (widget.position == "top") {
      topPosition = mediaQuery.padding.top + 20.0;
    } else if (widget.position == "center") {
      topPosition = mediaQuery.size.height / 2 - 50.0;
    } else {
      bottomPosition = mediaQuery.padding.bottom + 24.0;
    }

    return Positioned(
      top: topPosition,
      bottom: bottomPosition,
      left: 16.0,
      right: 16.0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _dismiss,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.07),
                                Colors.white.withValues(alpha: 0.02),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.85),
                                Colors.white.withValues(alpha: 0.70),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Glowing Icon container
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.accentColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.accentColor.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.iconData,
                            color: widget.accentColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Message content
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.message,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
