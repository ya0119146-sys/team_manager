import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized constants for the TeamManager application.
class AppConstants {
  AppConstants._();

  // ─── API ───
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get socketUrl => dotenv.env['BASE_URL'] ?? '';

  // ─── Cache Keys ───
  static const String tokenKey = 'token';
  static const String roleKey = 'role';
  static const String usernameKey = 'username';
  static const String onboardingSeenKey = 'onboarding_seen';
  static const String isDarkKey = 'isDark';

  // ─── Animation Durations (ms) ───
  static const int splashDuration = 2500;
  static const int fadeUpDuration = 600;
  static const int staggerDelay = 80;
  static const int scalePressDuration = 150;

  // ─── Glass Defaults ───
  static const double glassBlur = 15.0;
  static const double glassOpacity = 0.05;
  static const double glassBorderWidth = 0.5;
  static const double glassBorderOpacity = 0.1;

  // ─── Task Statuses ───
  static const List<String> taskStatuses = [
    'Pending',
    'In-progress',
    'Done',
    'Reviewing',
    'Accepted',
  ];

  // ─── Project Statuses ───
  static const List<String> projectStatuses = ['Active', 'Inactive', 'Done'];

  // ─── Performance Rating Formula ───
  static double calculateRating({required int reworks, required int lateDays}) {
    final rating = 5.0 - (reworks * 0.1) - (lateDays * 0.3);
    return rating.clamp(0.0, 5.0);
  }
}
