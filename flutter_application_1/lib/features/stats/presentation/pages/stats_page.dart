import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../nutrition/presentation/state/meal_history_notifier.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(mealHistoryProvider);

    // ---- compute simple stats ----
    final mealsCount = history.length;

    final totalCalories = history.fold<int>(
      0,
      (sum, e) => sum + e.result.calories,
    );
    final totalProtein = history.fold<int>(
      0,
      (sum, e) => sum + e.result.protein,
    );
    final totalCarbs = history.fold<int>(0, (sum, e) => sum + e.result.carbs);
    final totalFat = history.fold<int>(0, (sum, e) => sum + e.result.fat);

    final avgCalories = mealsCount == 0
        ? 0
        : (totalCalories / mealsCount).round();

    const bottomNavSpace =
        120.0; // IMPORTANT: space so scroll content isn't hidden

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // -------- SCROLLABLE CONTENT --------
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, bottomNavSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your\nStats", style: AppText.titleBig),
                    const SizedBox(height: 6),
                    Text("Based on saved meals", style: AppText.subtitle),
                    const SizedBox(height: 18),

                    // Summary cards row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: "Meals",
                            value: "$mealsCount",
                            subtitle: "saved",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: "Avg kcal",
                            value: "$avgCalories",
                            subtitle: "per meal",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Big macros card
                    GlassCard(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Macros total",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textOnDark,
                            ),
                          ),
                          const SizedBox(height: 10),

                          _MacroRow(
                            label: "Calories",
                            value: "$totalCalories",
                            unit: "kcal",
                          ),
                          const SizedBox(height: 8),
                          _MacroRow(
                            label: "Protein",
                            value: "$totalProtein",
                            unit: "g",
                          ),
                          const SizedBox(height: 8),
                          _MacroRow(
                            label: "Carbs",
                            value: "$totalCarbs",
                            unit: "g",
                          ),
                          const SizedBox(height: 8),
                          _MacroRow(
                            label: "Fat",
                            value: "$totalFat",
                            unit: "g",
                          ),

                          const SizedBox(height: 12),

                          // Clear for demo/testing
                          if (history.isNotEmpty)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => ref
                                    .read(mealHistoryProvider.notifier)
                                    .clear(),
                                child: Text(
                                  "Clear",
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

                    Text(
                      "Recent meals",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (history.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Center(
                          child: Text(
                            "No meals yet.\nSave a meal result to see stats.",
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
                        children: List.generate(history.length.clamp(0, 8), (
                          i,
                        ) {
                          final item = history[i];
                          final r = item.result;

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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${r.calories} kcal • P ${r.protein}g • C ${r.carbs}g • F ${r.fat}g",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.65,
                                            ),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}",
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

              // -------- FIXED BOTTOM NAV (like schedule) --------
              const Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: AppBottomNav(selectedIndex: 2), // 2 = Stats
              ),
            ],
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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

class _MacroRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          "$value $unit",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
