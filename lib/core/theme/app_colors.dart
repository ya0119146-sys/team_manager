import 'package:flutter/material.dart';

/// Premium color palette for the TeamManager Glassmorphism design system.
///
/// Uses Midnight Navy (#020617) as the dark base to maintain depth —
/// pure black is avoided intentionally to preserve the "cut glass" illusion.
class AppColors {
  AppColors._();

  // ──────────────────────────── Scaffold ────────────────────────────
  static const Color scaffoldDark = Color(0xFF020617);
  static const Color scaffoldLight = Color(0xFFF1F5F9);

  // ──────────────────────────── Surface ─────────────────────────────
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // ──────────────────────────── Glass Fill ──────────────────────────
  static Color glassFillDark = Colors.white.withValues(alpha: 0.05);
  static Color glassFillLight = Colors.white.withValues(alpha: 0.65);
  static Color glassBorderColor = Colors.white.withValues(alpha: 0.1);

  // ──────────────────────────── Accent Palette ──────────────────────
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFF43F5E);

  // ──────────────────────────── Gradient Presets ────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBlue, accentPurple],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF020617)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF020617), Color(0xFF0A0F1E)],
  );

  // ──────────────────────────── Task Status ─────────────────────────
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusDone = Color(0xFF10B981);
  static const Color statusReviewing = Color(0xFF8B5CF6);
  static const Color statusAccepted = Color(0xFF14B8A6);

  /// Returns the semantic color for a given task status string.
  static Color statusColor(String status) {
    switch (status.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '')) {
      case 'pending':
        return statusPending;
      case 'inprogress':
        return statusInProgress;
      case 'done':
        return statusDone;
      case 'reviewing':
        return statusReviewing;
      case 'accepted':
        return statusAccepted;
      default:
        return statusPending;
    }
  }

  // ──────────────────────────── Text ────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // ──────────────────────────── Misc ────────────────────────────────
  static const Color dividerDark = Color(0xFF1E293B);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E);
}
