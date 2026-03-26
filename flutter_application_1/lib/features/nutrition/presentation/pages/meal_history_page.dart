import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/meal_log.dart';
import '../../domain/entities/meal_result.dart';
import '../state/meal_history_notifier.dart';

class MealHistoryPage extends ConsumerWidget {
  const MealHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(mealHistoryProvider);
    final history = historyState.valueOrNull ?? const <MealLog>[];

    const bottomNavSpace = 120.0;
    const bottomNavInset = 18.0;
    const bottomNavHeight = 70.0;
    const addButtonLift = 12.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
        actions: [
          if (history.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(mealHistoryProvider.notifier).clear(),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Stack(
        children: [
          historyState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : historyState.hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: bottomNavSpace),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Failed to load meals'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(mealHistoryProvider.notifier).load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : history.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: bottomNavSpace),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No meals yet'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.go(AppRoutes.addMeal),
                          child: const Text('Add a meal'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    bottomNavSpace,
                  ),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = history[i];
                    final result = item.result;

                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        ref.read(mealHistoryProvider.notifier).remove(item.id);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.withOpacity(0.2),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          context.go(
                            AppRoutes.mealResult,
                            extra: <String, dynamic>{
                              'result': result,
                              'readOnly': true,
                            },
                          );
                        },
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  'assets/images/meal.jpg',
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _macroLine(result),
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.60),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.45),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          const Positioned(
            left: bottomNavInset,
            right: bottomNavInset,
            bottom: bottomNavInset,
            child: AppBottomNav(selectedIndex: 0),
          ),
          if (history.isNotEmpty)
            Positioned(
              right: 24,
              bottom: bottomNavInset + bottomNavHeight + addButtonLift,
              child: ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.addMeal),
                icon: const Icon(Icons.add),
                label: const Text('Add meal'),
              ),
            ),
        ],
      ),
    );
  }
}

String _macroLine(MealResult result) {
  return '${result.calories} kcal | P ${result.protein}g | C ${result.carbs}g | F ${result.fat}g';
}
