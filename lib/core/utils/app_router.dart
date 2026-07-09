import 'package:go_router/go_router.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/utils/auth_notifier.dart';

import 'package:team_manager/features/splash/screens/splash_screen.dart';
import 'package:team_manager/features/onboarding/screens/onboarding_screen.dart';

import 'package:team_manager/features/home/screens/home_main_screen.dart';
import 'package:team_manager/features/home/screens/home_project_screen.dart';
import 'package:team_manager/features/home/screens/home_task_screen.dart';

import 'package:team_manager/features/auth/screens/forget_password_screen.dart';
import 'package:team_manager/features/auth/screens/forget_password_screen2.dart';
import 'package:team_manager/features/auth/screens/forget_password_screen3.dart';
import 'package:team_manager/features/auth/screens/login_screen.dart';
import 'package:team_manager/features/auth/screens/sign_up_screen.dart';
import 'package:team_manager/features/auth/screens/verfiy_code_register_screen.dart';

import 'package:team_manager/features/settings/screens/profile_settings_screen.dart';

abstract class AppRouter {
  static final AuthNotifier authNotifier = AuthNotifier();

  // SPLASH & ONBOARDING
  static const kSplashScreen = '/';
  static const kOnboardingScreen = '/onboarding';

  // AUTH
  static const kLoginScreen = '/login';
  static const kSignUpScreen = '/signup';
  static const kForgotPasswordScreen = '/forgot-password';
  static const kVerfiyCodeRegisterScreen = '/verify-code';
  static const kForgetPasswordScreen2 = '/forgot-password-2';
  static const kForgotPasswordScreen3 = '/forgot-password-3';

  // ADMIN
  static const kAdminMainScreen = '/admin/main';
  static const kAdminProjectScreen = '/admin/projects';
  static const kAdminTaskScreen = '/admin/tasks';

  // COMMON
  static const kSettingsScreen = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: kSplashScreen,
    refreshListenable: authNotifier,

    redirect: (context, state) {
      final location = state.matchedLocation;

      // Allow splash & onboarding
      if (location == kSplashScreen || location == kOnboardingScreen) {
        return null;
      }

      final isAuthenticated = CacheHelper.getBool(key: 'auth_active') ?? false;

      final isAuthRoute =
          location == kLoginScreen ||
          location == kSignUpScreen ||
          location == kForgotPasswordScreen ||
          location == kVerfiyCodeRegisterScreen ||
          location == kForgetPasswordScreen2 ||
          location == kForgotPasswordScreen3;

      // User is not authenticated
      if (!isAuthenticated) {
        return isAuthRoute ? null : kLoginScreen;
      }

      // Prevent authenticated users from opening auth screens
      if (isAuthenticated && isAuthRoute) {
        return kAdminMainScreen;
      }

      // Common routes
      if (location == kSettingsScreen) {
        return null;
      }

      return null;
    },

    routes: [
      /// Splash
      GoRoute(
        path: kSplashScreen,
        builder: (context, state) => const SplashScreen(),
      ),

      /// Onboarding
      GoRoute(
        path: kOnboardingScreen,
        builder: (context, state) => const OnboardingScreen(),
      ),

      /// Auth
      GoRoute(
        path: kLoginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: kSignUpScreen,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: kForgotPasswordScreen,
        builder: (context, state) => const ForgetPasswordScreen(),
      ),
      GoRoute(
        path: kVerfiyCodeRegisterScreen,
        builder: (context, state) => const VerfiyCodeRegisterScreen(),
      ),
      GoRoute(
        path: kForgetPasswordScreen2,
        builder: (context, state) => const ForgetPasswordScreen2(),
      ),
      GoRoute(
        path: kForgotPasswordScreen3,
        builder: (context, state) => const ForgetPasswordScreen3(),
      ),

      /// Admin
      GoRoute(
        path: kAdminMainScreen,
        builder: (context, state) {
          final isAdmin = CacheHelper.getData(key: 'role') == 'admin';
          return HomeMainScreen(isAdmin: isAdmin);
        },
      ),

      GoRoute(
        path: kAdminProjectScreen,
        builder: (context, state) {
          final isAdmin = CacheHelper.getData(key: 'role') == 'admin';
          return HomeProjectScreen(isAdmin: isAdmin);
        },
      ),

      GoRoute(
        path: kAdminTaskScreen,
        builder: (context, state) {
          final isAdmin = CacheHelper.getData(key: 'role') == 'admin';
          return HomeTaskScreen(isAdmin: isAdmin);
        },
      ),

      /// Settings
      GoRoute(
        path: kSettingsScreen,
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
    ],
  );
}
