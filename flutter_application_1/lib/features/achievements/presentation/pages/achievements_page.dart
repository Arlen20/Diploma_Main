import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/health/health_calculator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../nutrition/domain/entities/meal_log.dart';
import '../../../nutrition/presentation/state/meal_history_notifier.dart';
import '../../../nutrition/presentation/state/water_notifier.dart';

class _Badge {
  final IconData icon;
  final String title;
  final String description;
  final bool unlocked;

  const _Badge({
    required this.icon,
    required this.title,
    required this.description,
    required this.unlocked,
  });
}

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealHistoryProvider).valueOrNull ?? const <MealLog>[];
    final glasses = ref.watch(waterProvider).valueOrNull ?? 0;
    final streak = HealthCalculator.currentStreak(
      meals.map((m) => m.createdAt).toList(growable: false),
    );
    final mealCount = meals.length;

    final badges = <_Badge>[
      _Badge(
        icon: Icons.restaurant_rounded,
        title: 'First meal',
        description: 'Log your first meal',
        unlocked: mealCount >= 1,
      ),
      _Badge(
        icon: Icons.local_dining_rounded,
        title: 'Getting started',
        description: 'Log 10 meals',
        unlocked: mealCount >= 10,
      ),
      _Badge(
        icon: Icons.workspace_premium_rounded,
        title: 'Dedicated',
        description: 'Log 50 meals',
        unlocked: mealCount >= 50,
      ),
      _Badge(
        icon: Icons.local_fire_department_rounded,
        title: 'On a roll',
        description: '3-day logging streak',
        unlocked: streak >= 3,
      ),
      _Badge(
        icon: Icons.bolt_rounded,
        title: 'Unstoppable',
        description: '7-day logging streak',
        unlocked: streak >= 7,
      ),
      _Badge(
        icon: Icons.water_drop_rounded,
        title: 'Hydrated',
        description: 'Hit your water goal today',
        unlocked: glasses >= kWaterDailyGoal,
      ),
    ];

    final unlockedCount = badges.where((b) => b.unlocked).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(
                '$unlockedCount of ${badges.length} unlocked',
                style: AppText.subtitle,
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: badges
                    .map((b) => _BadgeTile(badge: b))
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final _Badge badge;

  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.unlocked;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      fillOpacity: unlocked ? 0.12 : 0.05,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.accent.withOpacity(0.20)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: unlocked
                    ? AppColors.accent.withOpacity(0.5)
                    : Colors.white.withOpacity(0.12),
              ),
            ),
            child: Icon(
              unlocked ? badge.icon : Icons.lock_rounded,
              color: unlocked ? AppColors.accent : Colors.white.withOpacity(0.4),
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(unlocked ? 0.62 : 0.4),
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
