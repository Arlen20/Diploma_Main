import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/health/health_calculator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../nutrition/domain/entities/meal_log.dart';
import '../../../nutrition/presentation/state/meal_history_notifier.dart';
import '../../../profile_settings/domain/entities/user_profile.dart';
import '../../../profile_settings/presentation/state/user_profile_provider.dart';

enum _StatsRange { day, week }

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  _StatsRange _range = _StatsRange.day;

  bool _isInRange(DateTime createdAt, DateTime now) {
    switch (_range) {
      case _StatsRange.day:
        return createdAt.year == now.year &&
            createdAt.month == now.month &&
            createdAt.day == now.day;
      case _StatsRange.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return createdAt.isAfter(weekAgo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(mealHistoryProvider);
    final allHistory = historyState.valueOrNull ?? const <MealLog>[];
    final now = DateTime.now();

    final history = allHistory
        .where((meal) => _isInRange(meal.createdAt, now))
        .toList(growable: false);

    final mealsCount = history.length;
    final totalCalories = history.fold<int>(
      0,
      (sum, e) => sum + e.result.calories,
    );
    final totalProtein = history.fold<int>(0, (sum, e) => sum + e.result.protein);
    final totalCarbs = history.fold<int>(0, (sum, e) => sum + e.result.carbs);
    final totalFat = history.fold<int>(0, (sum, e) => sum + e.result.fat);
    final avgCalories = mealsCount == 0 ? 0 : (totalCalories / mealsCount).round();

    final rangeLabel = _range == _StatsRange.day ? 'Today' : 'Last 7 days';
    final emptyMessage = _range == _StatsRange.day
        ? 'No meals today.\nSave a meal result to see stats.'
        : 'No meals in the last 7 days.\nSave a meal result to see stats.';

    final profile = ref.watch(userProfileProvider).valueOrNull ?? UserProfile.empty;
    final targets = HealthCalculator.dailyTargets(
      sex: profile.sex,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      age: profile.age,
      activityLevel: profile.activityLevel,
      goal: profile.goal,
    );
    final days = _range == _StatsRange.day ? 1 : 7;
    final calorieGoal = targets.calories * days;
    final bmi = HealthCalculator.bmi(
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
    );

    const bottomNavSpace = 120.0;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, bottomNavSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your\nStats', style: AppText.titleBig),
                    const SizedBox(height: 6),
                    Text(rangeLabel, style: AppText.subtitle),
                    const SizedBox(height: 14),
                    _RangeToggle(
                      range: _range,
                      onChanged: (next) => setState(() => _range = next),
                    ),
                    const SizedBox(height: 14),
                    _CalorieGoalCard(
                      consumed: totalCalories,
                      goal: calorieGoal,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Meals',
                            value: '$mealsCount',
                            subtitle: 'saved',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Avg kcal',
                            value: '$avgCalories',
                            subtitle: 'per meal',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _range == _StatsRange.day
                                ? 'Macros today'
                                : 'Macros this week',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textOnDark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _MacroBar(
                            label: 'Protein',
                            consumed: totalProtein,
                            goal: targets.protein * days,
                            color: const Color(0xFFF3F0B6),
                          ),
                          const SizedBox(height: 12),
                          _MacroBar(
                            label: 'Carbs',
                            consumed: totalCarbs,
                            goal: targets.carbs * days,
                            color: const Color(0xFFBDA6FF),
                          ),
                          const SizedBox(height: 12),
                          _MacroBar(
                            label: 'Fat',
                            consumed: totalFat,
                            goal: targets.fat * days,
                            color: const Color(0xFFFFADD8),
                          ),
                          if (allHistory.isNotEmpty)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => ref
                                    .read(mealHistoryProvider.notifier)
                                    .clear(),
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _BmiCard(bmi: bmi),
                    const SizedBox(height: 14),
                    Text(
                      'Recent meals',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (historyState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (historyState.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Center(
                          child: Text(
                            'Failed to load meal stats.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else if (history.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Center(
                          child: Text(
                            emptyMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: List.generate(history.length.clamp(0, 8), (i) {
                          final item = history[i];
                          final result = item.result;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          result.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${result.calories} kcal | P ${result.protein}g | C ${result.carbs}g | F ${result.fat}g',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.65),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.55),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
              const Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: AppBottomNav(selectedIndex: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeToggle extends StatelessWidget {
  final _StatsRange range;
  final ValueChanged<_StatsRange> onChanged;

  const _RangeToggle({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Day',
              selected: range == _StatsRange.day,
              onTap: () => onChanged(_StatsRange.day),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ToggleOption(
              label: 'Week',
              selected: range == _StatsRange.week,
              onTap: () => onChanged(_StatsRange.week),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppColors.primaryBtnText
                : Colors.white.withOpacity(0.80),
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 26,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.60),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieGoalCard extends StatelessWidget {
  final int consumed;
  final int goal;

  const _CalorieGoalCard({required this.consumed, required this.goal});

  @override
  Widget build(BuildContext context) {
    final safeGoal = goal <= 0 ? 1 : goal;
    final progress = (consumed / safeGoal).clamp(0.0, 1.0);
    final remaining = goal - consumed;
    final over = remaining < 0;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 9,
                    backgroundColor: Colors.white.withOpacity(0.14),
                    valueColor: AlwaysStoppedAnimation(
                      over ? const Color(0xFFFFADD8) : AppColors.accent,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calorie goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$consumed / $goal kcal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  over
                      ? '${-remaining} kcal over'
                      : '$remaining kcal remaining',
                  style: TextStyle(
                    color: over
                        ? const Color(0xFFFFADD8)
                        : Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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

class _MacroBar extends StatelessWidget {
  final String label;
  final int consumed;
  final int goal;
  final Color color;

  const _MacroBar({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeGoal = goal <= 0 ? 1 : goal;
    final progress = (consumed / safeGoal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.80),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              '$consumed / $goal g',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _BmiCard extends StatelessWidget {
  final double bmi;

  const _BmiCard({required this.bmi});

  @override
  Widget build(BuildContext context) {
    final category = HealthCalculator.bmiCategory(bmi);
    final color = switch (category) {
      'Underweight' => const Color(0xFFBDA6FF),
      'Normal' => const Color(0xFF8BE0B0),
      'Overweight' => const Color(0xFFF3F0B6),
      'Obese' => const Color(0xFFFFADD8),
      _ => Colors.white,
    };

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Body Mass Index',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Based on your height & weight',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bmi <= 0 ? '-' : bmi.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
