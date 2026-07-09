import 'package:flutter/material.dart';
import 'package:team_manager/core/theme/app_colors.dart';

/// Displays a 5-star performance rating with partial-fill support.
///
/// Uses the formula: `5.0 - (reworks × 0.1) - (lateDays × 0.3)`.
///
/// ```dart
/// StarRatingWidget(rating: 4.3)
/// StarRatingWidget.fromMetrics(reworks: 2, lateDays: 1)
/// ```
class StarRatingWidget extends StatelessWidget {
  const StarRatingWidget({
    super.key,
    required this.rating,
    this.size = 22,
    this.starColor = AppColors.accentAmber,
    this.emptyColor,
    this.showLabel = true,
    this.labelStyle,
  });

  /// Convenience factory that calculates the rating from raw metrics.
  factory StarRatingWidget.fromMetrics({
    Key? key,
    required int reworks,
    required int lateDays,
    double size = 22,
    bool showLabel = true,
  }) {
    final rating = (5.0 - (reworks * 0.1) - (lateDays * 0.3)).clamp(0.0, 5.0);
    return StarRatingWidget(
      key: key,
      rating: rating,
      size: size,
      showLabel: showLabel,
    );
  }

  final double rating;
  final double size;
  final Color starColor;
  final Color? emptyColor;
  final bool showLabel;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final empty = emptyColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.3));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Stars ──
        ...List.generate(5, (index) {
          final starValue = index + 1;
          if (rating >= starValue) {
            // Full star
            return Icon(Icons.star_rounded, size: size, color: starColor);
          } else if (rating > starValue - 1) {
            // Partial star — use a shader mask for fractional fill
            final fraction = rating - (starValue - 1);
            return _PartialStar(
              fraction: fraction,
              size: size,
              filledColor: starColor,
              emptyColor: empty,
            );
          } else {
            // Empty star
            return Icon(Icons.star_rounded, size: size, color: empty);
          }
        }),

        // ── Label ──
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: labelStyle ??
                theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: starColor,
                ),
          ),
        ],
      ],
    );
  }
}

/// A single star icon that is partially filled from left to right.
class _PartialStar extends StatelessWidget {
  const _PartialStar({
    required this.fraction,
    required this.size,
    required this.filledColor,
    required this.emptyColor,
  });

  final double fraction;
  final double size;
  final Color filledColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Empty background star
          Icon(Icons.star_rounded, size: size, color: emptyColor),
          // Clipped filled star
          ClipRect(
            clipper: _StarClipper(fraction),
            child: Icon(Icons.star_rounded, size: size, color: filledColor),
          ),
        ],
      ),
    );
  }
}

/// Clips from the left by [fraction] (0.0 → 1.0).
class _StarClipper extends CustomClipper<Rect> {
  _StarClipper(this.fraction);
  final double fraction;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(covariant _StarClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}
