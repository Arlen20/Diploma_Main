import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

// ✅ Import real pages (create these files first)
import 'package:flutter_application_1/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/check_inbox_page.dart';
import 'package:flutter_application_1/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_application_1/features/home/presentation/pages/home_shell_page.dart';
import 'package:flutter_application_1/features/nutrition/presentation/pages/add_meal_page.dart';
import 'package:flutter_application_1/features/nutrition/presentation/pages/analyzing_meal_page.dart';
import 'package:flutter_application_1/features/nutrition/presentation/pages/meal_result_page.dart';
import 'package:flutter_application_1/features/nutrition/presentation/pages/meal_history_page.dart';
import 'package:flutter_application_1/core/routing/splash_page.dart'; // you can also put splash in features
import 'package:flutter_application_1/features/plan/presentation/pages/weekly_plan_page.dart';
import 'package:flutter_application_1/features/stats/presentation/pages/stats_page.dart';
import 'package:flutter_application_1/features/profile_settings/presentation/pages/settings_page.dart';
import 'package:flutter_application_1/features/onboarding/presentation/pages/onboarding_goal_page.dart';
import 'package:flutter_application_1/features/onboarding/presentation/pages/onboarding_metrics_page.dart';
import 'package:flutter_application_1/features/onboarding/presentation/pages/onboarding_finish_page.dart';

// --- App state (fake for now) ---
class AppSessionState {
  final bool isLoggedIn;
  final bool isEmailVerified;
  final bool isOnboardingDone;

  const AppSessionState({
    required this.isLoggedIn,
    required this.isEmailVerified,
    required this.isOnboardingDone,
  });

  AppSessionState copyWith({
    bool? isLoggedIn,
    bool? isEmailVerified,
    bool? isOnboardingDone,
  }) {
    return AppSessionState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isOnboardingDone: isOnboardingDone ?? this.isOnboardingDone,
    );
  }

  static const initial = AppSessionState(
    isLoggedIn: false,
    isEmailVerified: false,
    isOnboardingDone: false,
  );
}

class AppSessionNotifier extends StateNotifier<AppSessionState> {
  AppSessionNotifier() : super(AppSessionState.initial);

  // Dummy methods (later connect Firebase)
  void login() => state = state.copyWith(isLoggedIn: true);
  void logout() => state = AppSessionState.initial;

  void markEmailVerified() => state = state.copyWith(isEmailVerified: true);
  void completeOnboarding() => state = state.copyWith(isOnboardingDone: true);
}

final appSessionProvider =
    StateNotifierProvider<AppSessionNotifier, AppSessionState>(
      (ref) => AppSessionNotifier(),
    );

// router provider
final goRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(appSessionProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.checkInbox,
        builder: (context, state) => const CheckInboxPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeShellPage(),
      ),
      GoRoute(
        path: AppRoutes.addMeal,
        builder: (context, state) => const AddMealPage(),
      ),
      GoRoute(
        path: AppRoutes.analyzingMeal,
        builder: (context, state) => const AnalyzingMealPage(),
      ),
      GoRoute(
        path: AppRoutes.mealResult,
        builder: (context, state) => const MealResultPage(),
      ),
      GoRoute(
        path: AppRoutes.mealHistory,
        builder: (context, state) => const MealHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.schedule,
        builder: (context, state) => const WeeklyPlanPage(),
      ),
      GoRoute(
        path: AppRoutes.stats,
        builder: (context, state) => const StatsPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingGoal,
        builder: (context, state) => const OnboardingGoalPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingMetrics,
        builder: (context, state) => const OnboardingMetricsPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingFinish,
        builder: (context, state) => const OnboardingFinishPage(),
      ),
    ],

    // Redirect logic
    redirect: (context, state) {
      final loc = state.uri.toString();

      final isAuthRoute =
          loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.checkInbox;

      // Not logged in -> go login (except auth pages)
      if (!session.isLoggedIn) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      // Logged in but email not verified -> go check inbox
      if (session.isLoggedIn && !session.isEmailVerified) {
        return loc == AppRoutes.checkInbox ? null : AppRoutes.checkInbox;
      }

      if (session.isLoggedIn &&
          session.isEmailVerified &&
          !session.isOnboardingDone) {
        // force start of onboarding flow
        if (loc == AppRoutes.onboardingGoal ||
            loc == AppRoutes.onboardingMetrics ||
            loc == AppRoutes.onboardingFinish) {
          return null;
        }
        return AppRoutes.onboardingGoal;
      }

      // If fully ready, block access to auth pages
      if (session.isLoggedIn &&
          session.isEmailVerified &&
          session.isOnboardingDone &&
          isAuthRoute) {
        return AppRoutes.home;
      }

      // Splash should push to home once state is known
      if (loc == AppRoutes.splash) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});
