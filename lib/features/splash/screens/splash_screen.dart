import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/secure_storage_helper.dart';
import 'package:team_manager/core/theme/app_colors.dart';
import 'package:team_manager/core/utils/app_router.dart';
import 'package:easy_localization/easy_localization.dart';

/// Animated splash screen with pulsing logo over a Midnight Navy gradient.
///
/// Flow: pulse animation → 2.5s delay → check onboarding →
/// check token → navigate to appropriate route.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // ── Pulse animation for the logo ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Fade-in for the text ──
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Start text fade after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fadeController.forward();
    });

    // Navigate after the splash duration
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // ── Check onboarding status ──
    final onboardingSeen = CacheHelper.getBool(key: 'onboarding_seen') ?? false;

    if (!onboardingSeen) {
      if (mounted) GoRouter.of(context).go(AppRouter.kOnboardingScreen);
      return;
    }

    // ── Check authentication (async secure storage → sync bridge) ──
    final token = await SecureStorageHelper.getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Bridge to sync flag for the router's redirect
      await CacheHelper.setBool(key: 'auth_active', value: true);
      if (!mounted) return;
      AppRouter.authNotifier.notify();

      GoRouter.of(context).go(AppRouter.kAdminMainScreen);
    } else {
      await CacheHelper.setBool(key: 'auth_active', value: false);
      if (!mounted) return;
      GoRouter.of(context).go(AppRouter.kLoginScreen);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundGradient = isDark
        ? AppColors.splashGradient
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
          );

    final primaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.95)
        : AppColors.textPrimaryLight;

    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : AppColors.textSecondaryLight;

    final progressIndicatorColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Pulsing Logo ──
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentBlue.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'TM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── App Name (fades in) ──
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  Text(
                    'TeamManager'.tr(),
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Project & Task Management'.tr(),
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // ── Loading indicator ──
            FadeTransition(
              opacity: _fadeAnim,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: progressIndicatorColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
