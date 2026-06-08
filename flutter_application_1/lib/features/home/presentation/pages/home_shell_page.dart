import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/health/health_calculator.dart';
import '../../../../core/health/health_tips.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/storage/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../nutrition/domain/entities/meal_log.dart';
import '../../../nutrition/presentation/state/meal_history_notifier.dart';
import '../../../nutrition/presentation/state/water_notifier.dart';
import '../../../plan/domain/entities/workout_plan_entry.dart';
import '../../../plan/presentation/state/workout_plan_provider.dart';
import '../../../profile_settings/presentation/state/user_profile_provider.dart';

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final workoutPlanState = ref.watch(workoutPlanProvider);
    final workoutPlan =
        workoutPlanState.valueOrNull ?? const <WorkoutPlanEntry>[];
    final mealHistoryState = ref.watch(mealHistoryProvider);
    final mealHistory = mealHistoryState.valueOrNull ?? const <MealLog>[];
    final today = DateTime.now();
    final todaysMeals = mealHistory
        .where((meal) {
          final createdAt = meal.createdAt;
          return createdAt.year == today.year &&
              createdAt.month == today.month &&
              createdAt.day == today.day;
        })
        .toList(growable: false);
    final todaysCalories = todaysMeals.fold<int>(
      0,
      (sum, meal) => sum + meal.result.calories,
    );
    final latestMeal = mealHistory.isEmpty ? null : mealHistory.first;
    final todaysWorkouts = workoutPlan
        .where((item) => item.dayOfWeek == today.weekday)
        .toList(growable: false);
    WorkoutPlanEntry? todaysWorkout;
    for (final workout in todaysWorkouts) {
      if (!workout.completed) {
        todaysWorkout = workout;
        break;
      }
    }
    todaysWorkout ??= todaysWorkouts.isEmpty ? null : todaysWorkouts.first;

    final calorieGoal = HealthCalculator.dailyTargets(
      sex: profile?.sex ?? 'Male',
      heightCm: profile?.heightCm ?? 175,
      weightKg: profile?.weightKg ?? 70,
      age: profile?.age ?? 20,
      activityLevel: profile?.activityLevel ?? 'Moderate',
      goal: profile?.goal ?? 'Maintain',
    ).calories;
    final streak = HealthCalculator.currentStreak(
      mealHistory.map((m) => m.createdAt).toList(growable: false),
    );
    final glasses = ref.watch(waterProvider).valueOrNull ?? 0;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                child: Column(
                  children: [
                    _TopHeader(
                      name: profile?.name ?? 'User',
                      avatarLocalPath: resolveLocalAvatarPath(
                        ref.watch(appDocumentsPathProvider),
                        profile?.avatarLocalPath ?? '',
                      ),
                      onAvatarTap: () => context.go(AppRoutes.settings),
                    ),
                    const SizedBox(height: 18),
                    _NutritionCard(
                      onAddMeal: () => context.push(AppRoutes.addMeal),
                      todaysCalories: todaysCalories,
                      calorieGoal: calorieGoal,
                      todaysMealsCount: todaysMeals.length,
                      latestMealTitle: latestMeal?.result.title,
                      streak: streak,
                      isLoading: mealHistoryState.isLoading,
                    ),
                    const SizedBox(height: 14),
                    _WaterCard(
                      glasses: glasses,
                      onAdd: () => ref.read(waterProvider.notifier).add(),
                      onRemove: () => ref.read(waterProvider.notifier).remove(),
                    ),
                    const SizedBox(height: 14),
                    _TipCard(tip: HealthTips.today()),
                    const SizedBox(height: 14),
                    _QuickActionsRow(
                      onHistory: () => context.go(AppRoutes.mealHistory),
                      onCalendar: () => context.push(AppRoutes.calendar),
                      onWeight: () => context.push(AppRoutes.weightLog),
                      onAwards: () => context.push(AppRoutes.achievements),
                    ),
                    const SizedBox(height: 22),
                    _ScheduleHeader(goal: profile?.goal ?? 'Maintain'),
                    const SizedBox(height: 14),
                    _ScheduleTimeline(
                      workout: todaysWorkout,
                      isLoading: workoutPlanState.isLoading,
                      onStart: todaysWorkout == null
                          ? () => context.go(AppRoutes.schedule)
                          : () => context.go(
                              AppRoutes.trainingSession,
                              extra: todaysWorkout,
                            ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AppBottomNav(selectedIndex: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final String name;
  final String avatarLocalPath;
  final VoidCallback onAvatarTap;

  const _TopHeader({
    required this.name,
    required this.avatarLocalPath,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text('Hi,\n$name', style: AppText.titleBig)),
        _SearchPill(avatarLocalPath: avatarLocalPath, onTap: onAvatarTap),
      ],
    );
  }
}

class _SearchPill extends StatelessWidget {
  final String avatarLocalPath;
  final VoidCallback onTap;

  const _SearchPill({required this.avatarLocalPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatarFile = avatarLocalPath.isEmpty ? null : File(avatarLocalPath);
    final hasAvatar = avatarFile != null && avatarFile.existsSync();

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.22),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.35)),
                image: hasAvatar
                    ? DecorationImage(
                        image: FileImage(avatarFile),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: hasAvatar
                  ? null
                  : const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final VoidCallback onAddMeal;
  final int todaysCalories;
  final int calorieGoal;
  final int todaysMealsCount;
  final String? latestMealTitle;
  final int streak;
  final bool isLoading;

  const _NutritionCard({
    required this.onAddMeal,
    required this.todaysCalories,
    required this.calorieGoal,
    required this.todaysMealsCount,
    required this.latestMealTitle,
    required this.streak,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final goal = calorieGoal <= 0 ? 1 : calorieGoal;
    final progress = (todaysCalories / goal).clamp(0.0, 1.0);
    final remaining = calorieGoal - todaysCalories;

    return GlassCard(
      radius: AppRadii.r30,
      blur: 22,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Nutrition today',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
              if (streak > 0) _StreakChip(streak: streak),
            ],
          ),
          const SizedBox(height: 6),
          if (isLoading)
            Text('Loading your meals...', style: AppText.subtitle)
          else
            Text(
              todaysMealsCount == 0
                  ? 'No meals saved yet. Start tracking today.'
                  : '$todaysMealsCount meals today',
              style: AppText.subtitle,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$todaysCalories',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
              Text(
                ' / $calorieGoal kcal',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                remaining >= 0 ? '$remaining left' : '${-remaining} over',
                style: TextStyle(
                  color: remaining >= 0
                      ? AppColors.accent
                      : const Color(0xFFFFADD8),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestMealTitle ?? 'No recent meals',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        latestMealTitle == null
                            ? 'Add your first meal to build stats'
                            : 'Latest saved meal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.62),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onAddMeal,
                child: Center(
                  child: Text(
                    '+ Add meal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark.withOpacity(0.92),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onHistory;
  final VoidCallback onCalendar;
  final VoidCallback onWeight;
  final VoidCallback onAwards;

  const _QuickActionsRow({
    required this.onHistory,
    required this.onCalendar,
    required this.onWeight,
    required this.onAwards,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionChip(
            icon: Icons.history_rounded,
            label: 'History',
            onTap: onHistory,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionChip(
            icon: Icons.calendar_month_rounded,
            label: 'Calendar',
            onTap: onCalendar,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionChip(
            icon: Icons.monitor_weight_outlined,
            label: 'Weight',
            onTap: onWeight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionChip(
            icon: Icons.emoji_events_rounded,
            label: 'Awards',
            onTap: onAwards,
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tip of the day',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleHeader extends StatelessWidget {
  final String goal;

  const _ScheduleHeader({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your\nSchedule', style: AppText.titleBig),
              const SizedBox(height: 4),
              Text('$goal plan', style: AppText.labelMuted),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: const Icon(Icons.tune, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

class _ScheduleTimeline extends StatelessWidget {
  final WorkoutPlanEntry? workout;
  final bool isLoading;
  final VoidCallback onStart;

  const _ScheduleTimeline({
    required this.workout,
    required this.isLoading,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseSummary = workout == null
        ? 'Open schedule to generate or choose a workout.'
        : workout!.exercises.isEmpty
        ? workout!.subtitle
        : workout!.exercises.map((exercise) => exercise.name).join(', ');
    final title = isLoading
        ? 'Loading today'
        : workout?.title ?? 'No training today';
    final buttonLabel = workout == null ? 'Schedule' : 'Start';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onStart,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBtnText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.play_arrow,
                      size: 20,
                      color: AppColors.primaryBtnText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 7),
          child: Column(
            children: [
              Container(
                width: 2,
                height: 26,
                color: Colors.white.withOpacity(0.16),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              exerciseSummary,
              style: TextStyle(
                color: Colors.white.withOpacity(0.28),
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int streak;

  const _StreakChip({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accent.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.accent,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak day${streak == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  final int glasses;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _WaterCard({
    required this.glasses,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_rounded,
                color: Color(0xFF8FD3FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Water',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '$glasses / $kWaterDailyGoal glasses',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(kWaterDailyGoal, (i) {
                    final filled = i < glasses;
                    return Icon(
                      filled
                          ? Icons.local_drink_rounded
                          : Icons.local_drink_outlined,
                      size: 24,
                      color: filled
                          ? const Color(0xFF8FD3FF)
                          : Colors.white.withOpacity(0.30),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              _RoundIconButton(
                icon: Icons.remove_rounded,
                onTap: glasses > 0 ? onRemove : null,
              ),
              const SizedBox(width: 8),
              _RoundIconButton(icon: Icons.add_rounded, onTap: onAdd),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(onTap == null ? 0.06 : 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            color: Colors.white.withOpacity(onTap == null ? 0.3 : 0.9),
            size: 20,
          ),
        ),
      ),
    );
  }
}
