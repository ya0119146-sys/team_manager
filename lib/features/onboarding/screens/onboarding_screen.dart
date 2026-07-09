import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/theme/app_colors.dart';
import 'package:team_manager/core/utils/app_router.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:easy_localization/easy_localization.dart';

/// 3-page Glassmorphism onboarding flow for first-time users.
///
/// Pages:
/// 1. Unified Project Hub — managing team workspaces
/// 2. Smart Kanban — task lifecycle & rework tracking
/// 3. AI Insights — performance metrics & 5-star ratings
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.workspaces_rounded,
      gradient: [AppColors.accentBlue, AppColors.accentCyan],
      title: 'Unified Project Hub'.tr(),
      subtitle:
          'Organize all your team workspaces in one place. Create projects, assign members, and track progress with a unified dashboard.'.tr(),
    ),
    _OnboardingData(
      icon: Icons.view_kanban_rounded,
      gradient: [AppColors.accentPurple, AppColors.accentBlue],
      title: 'Smart Kanban Board'.tr(),
      subtitle:
          'Visualize your task lifecycle from Pending to Accepted. Track rework cycles and keep your team moving forward.'.tr(),
    ),
    _OnboardingData(
      icon: Icons.auto_awesome_rounded,
      gradient: [AppColors.accentAmber, AppColors.accentRose],
      title: 'AI-Powered Insights'.tr(),
      subtitle:
          'Get a 5-star performance rating based on quality and timeliness. Leverage AI-generated suggestions to boost team productivity.'.tr(),
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await CacheHelper.setBool(key: 'onboarding_seen', value: true);
    if (mounted) {
      GoRouter.of(context).go(AppRouter.kLoginScreen);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip Button ──
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip'.tr(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Pages ──
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _OnboardingPage(data: page);
                  },
                ),
              ),

              // ── Indicators + Button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.accentBlue
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    // Action button
                    GlassButton(
                      label: _currentPage == _pages.length - 1
                          ? 'Get Started'.tr()
                          : 'Next'.tr(),
                      icon: _currentPage == _pages.length - 1
                          ? Icons.arrow_forward_rounded
                          : null,
                      onPressed: _onNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────────────────────────────
class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
}

// ─────────────────────────────────────────────────────────────────────
//  SINGLE PAGE WIDGET
// ─────────────────────────────────────────────────────────────────────
class _OnboardingPage extends StatefulWidget {
  const _OnboardingPage({required this.data});
  final _OnboardingData data;

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon with glow ──
              GlassPanel(
                blur: 20,
                opacity: 0.08,
                borderRadius: BorderRadius.circular(32),
                padding: const EdgeInsets.all(32),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.data.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.gradient.first
                            .withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.data.icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Title ──
              Text(
                widget.data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // ── Subtitle ──
              Text(
                widget.data.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
