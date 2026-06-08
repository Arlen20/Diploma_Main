import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/firebase_auth_providers.dart';
import 'app_routes.dart';
import 'package:flutter_application_1/core/routing/splash_page.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/check_inbox_page.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/verification_success_page.dart';
import 'package:flutter_application_1/features/achievements/presentation/pages/achievements_page.dart';
import 'package:flutter_application_1/features/home/presentation/pages/home_shell_page.dart';
import 'package:flutter_application_1/features/nutrition/presentation/pages/add_meal_page.dart';
import 'package:flutter_application_1/features/nutrition/presentation/pages/analyzing_meal_page.dart';
import 'package:flutter_application_1/features/nutrition/presentation/pages/calendar_page.dart';
import 'package:flutter_application_1/features/nutrition/presentation/pages/meal_history_page.dart';
import 'package:flutter_application_1/features/nutrition/presentation/pages/meal_result_page.dart';
import 'package:flutter_application_1/features/weight/presentation/pages/weight_log_page.dart';
import 'package:flutter_application_1/features/plan/presentation/pages/training_success_page.dart';
import 'package:flutter_application_1/features/onboarding/presentation/pages/onboarding_finish_page.dart';
import 'package:flutter_application_1/features/onboarding/presentation/pages/onboarding_goal_page.dart';
import 'package:flutter_application_1/features/onboarding/presentation/pages/onboarding_metrics_page.dart';
import 'package:flutter_application_1/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_application_1/features/plan/domain/entities/workout_plan_entry.dart';
import 'package:flutter_application_1/features/plan/presentation/pages/training_session_page.dart';
import 'package:flutter_application_1/features/plan/presentation/pages/weekly_plan_page.dart';
import 'package:flutter_application_1/features/profile_settings/presentation/pages/settings_page.dart';
import 'package:flutter_application_1/features/profile_settings/presentation/state/user_profile_provider.dart';
import 'package:flutter_application_1/features/stats/presentation/pages/stats_page.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final _routerRefreshProvider = Provider<_RouterRefreshNotifier>((ref) {
  final notifier = _RouterRefreshNotifier();

  ref.listen(authStateProvider, (_, _) => notifier.refresh());
  ref.listen(userProfileProvider, (_, _) => notifier.refresh());
  ref.onDispose(notifier.dispose);

  return notifier;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(_routerRefreshProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
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
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.checkInbox,
        builder: (context, state) => const CheckInboxPage(),
      ),
      GoRoute(
        path: AppRoutes.verificationSuccess,
        builder: (context, state) => const VerificationSuccessPage(),
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
        path: AppRoutes.trainingSession,
        builder: (context, state) {
          final entry = state.extra;
          if (entry is! WorkoutPlanEntry) {
            return const WeeklyPlanPage();
          }
          return TrainingSessionPage(planEntry: entry);
        },
      ),
      GoRoute(
        path: AppRoutes.trainingSuccess,
        builder: (context, state) => const TrainingSuccessPage(),
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
        path: AppRoutes.achievements,
        builder: (context, state) => const AchievementsPage(),
      ),
      GoRoute(
        path: AppRoutes.weightLog,
        builder: (context, state) => const WeightLogPage(),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        builder: (context, state) => const CalendarPage(),
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
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final profileState = ref.read(userProfileProvider);
      final loc = state.uri.toString();
      final isPublicRoute =
          loc == AppRoutes.splash ||
          loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.forgotPassword;

      if (authState.isLoading) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final user = authState.valueOrNull;
      if (user == null) {
        return isPublicRoute ? null : AppRoutes.login;
      }

      if (!user.emailVerified) {
        return loc == AppRoutes.checkInbox ? null : AppRoutes.checkInbox;
      }

      if (loc == AppRoutes.verificationSuccess) {
        return null;
      }

      if (profileState.isLoading) {
        if (loc == AppRoutes.onboardingGoal ||
            loc == AppRoutes.onboardingMetrics ||
            loc == AppRoutes.onboardingFinish ||
            loc == AppRoutes.home) {
          return null;
        }
        return AppRoutes.onboardingGoal;
      }

      final profile = profileState.valueOrNull;
      final onboardingDone = profile?.onboardingCompleted ?? false;
      if (!onboardingDone) {
        if (loc == AppRoutes.onboardingGoal ||
            loc == AppRoutes.onboardingMetrics ||
            loc == AppRoutes.onboardingFinish) {
          return null;
        }
        return AppRoutes.onboardingGoal;
      }

      if (loc == AppRoutes.onboardingGoal ||
          loc == AppRoutes.onboardingMetrics ||
          loc == AppRoutes.onboardingFinish) {
        return AppRoutes.home;
      }

      if (isPublicRoute || loc == AppRoutes.checkInbox) {
        return AppRoutes.home;
      }

      if (loc == AppRoutes.splash) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});
