import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/routing/app_routes.dart';

import '../../domain/entities/meal_result.dart';
import '../../domain/entities/meal_log.dart';
import '../state/meal_history_notifier.dart'; // adjust import to your provider

class MealResultPage extends ConsumerStatefulWidget {
  const MealResultPage({super.key});

  @override
  ConsumerState<MealResultPage> createState() => _MealResultPageState();
}

class _MealResultPageState extends ConsumerState<MealResultPage> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final result = GoRouterState.of(context).extra as MealResult;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F2FF), Color(0xFFD8C7FF), Color(0xFFBFA6FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                const Text(
                  'Estimated nutrition',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C1C27),
                  ),
                ),
                const SizedBox(height: 14),

                // big card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          "assets/images/meal.jpg",
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // kcal row
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F0B6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF1C1C27),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${result.calories} ",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1C1C27),
                            ),
                          ),
                          const Text(
                            "kcal",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1C1C27),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Divider(color: const Color(0xFF1C1C27).withOpacity(0.10)),
                      const SizedBox(height: 12),

                      // macros
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MacroChip(
                            color: const Color(0xFFF4F0B6),
                            icon: Icons.egg_alt_outlined,
                            value: "${result.protein}g",
                            label: "Protein",
                          ),
                          _MacroChip(
                            color: const Color(0xFFE0D2FF),
                            icon: Icons.grain,
                            value: "${result.carbs}g",
                            label: "Carbs",
                          ),
                          _MacroChip(
                            color: const Color(0xFFFFCDEB),
                            icon: Icons.opacity_outlined,
                            value: "${result.fat}g",
                            label: "Fat",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B1736),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _saved
                        ? null
                        : () {
                            setState(() => _saved = true);
                            final history = ref.read(mealHistoryProvider);
                            final last =
                                history.isEmpty ? null : history.first;
                            final isFastDuplicate = last != null &&
                                last.result.title == result.title &&
                                last.result.calories == result.calories &&
                                DateTime.now()
                                        .difference(last.createdAt)
                                        .inSeconds <
                                    30;
                            if (!isFastDuplicate) {
                              ref.read(mealHistoryProvider.notifier).add(
                                    MealLog(
                                      createdAt: DateTime.now(),
                                      result: result,
                                    ),
                                  );
                            }
                            context.go(AppRoutes.mealHistory);
                          },
                    child: const Text(
                      "Save",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Edit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.70),
                      side: BorderSide(color: Colors.black.withOpacity(0.10)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => context.go(AppRoutes.addMeal),
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1C1C27),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String value;
  final String label;

  const _MacroChip({
    required this.color,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF1C1C27)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1C1C27),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1C27).withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}
