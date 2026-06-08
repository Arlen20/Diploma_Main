import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../domain/entities/meal_log.dart';
import '../../domain/entities/meal_result.dart';
import '../state/meal_history_notifier.dart';

class MealHistoryPage extends ConsumerStatefulWidget {
  const MealHistoryPage({super.key});

  @override
  ConsumerState<MealHistoryPage> createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends ConsumerState<MealHistoryPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(mealHistoryProvider);
    final allHistory = historyState.valueOrNull ?? const <MealLog>[];

    final query = _query.trim().toLowerCase();
    final history = query.isEmpty
        ? allHistory
        : allHistory
            .where((m) => m.result.title.toLowerCase().contains(query))
            .toList(growable: false);

    const bottomNavSpace = 120.0;
    const bottomNavInset = 18.0;
    const bottomNavHeight = 70.0;
    const addButtonLift = 12.0;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 12, 6),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Meal\nHistory', style: AppText.titleBig),
                        ),
                        if (allHistory.isNotEmpty)
                          TextButton(
                            onPressed: () =>
                                ref.read(mealHistoryProvider.notifier).clear(),
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                  ),
                  if (allHistory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search meals…',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.16),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: historyState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : historyState.hasError
                        ? _CenteredMessage(
                            message: 'Failed to load meals',
                            actionLabel: 'Retry',
                            onAction: () =>
                                ref.read(mealHistoryProvider.notifier).load(),
                            bottomPadding: bottomNavSpace,
                          )
                        : allHistory.isEmpty
                        ? _CenteredMessage(
                            message: 'No meals yet',
                            actionLabel: 'Add a meal',
                            onAction: () => context.go(AppRoutes.addMeal),
                            bottomPadding: bottomNavSpace,
                          )
                        : history.isEmpty
                        ? _CenteredMessage(
                            message: 'No meals match "$_query"',
                            actionLabel: 'Clear search',
                            onAction: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            bottomPadding: bottomNavSpace,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              8,
                              16,
                              bottomNavSpace,
                            ),
                            itemCount: history.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final item = history[i];
                              return _MealCard(item: item);
                            },
                          ),
                  ),
                ],
              ),
              const Positioned(
                left: bottomNavInset,
                right: bottomNavInset,
                bottom: bottomNavInset,
                child: AppBottomNav(selectedIndex: 0),
              ),
              if (allHistory.isNotEmpty)
                Positioned(
                  right: 24,
                  bottom: bottomNavInset + bottomNavHeight + addButtonLift,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.addMeal),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add meal'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealCard extends ConsumerWidget {
  final MealLog item;

  const _MealCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = item.result;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(mealHistoryProvider.notifier).remove(item.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          context.go(
            AppRoutes.mealResult,
            extra: <String, dynamic>{
              'result': result,
              'readOnly': true,
              'imageBase64': item.imageBase64,
              'imageMimeType': item.imageMimeType,
              'category': item.category,
            },
          );
        },
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image(
                  image: _imageProviderFor(item),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            result.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (item.category.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _CategoryTag(label: item.category),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _macroLine(result),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
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
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String label;

  const _CategoryTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0B6).withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF3F0B6).withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFF3F0B6),
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final double bottomPadding;

  const _CenteredMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

String _macroLine(MealResult result) {
  return '${result.calories} kcal | P ${result.protein}g | C ${result.carbs}g | F ${result.fat}g';
}

ImageProvider _imageProviderFor(MealLog item) {
  if (item.imageBase64.isEmpty) {
    return const AssetImage('assets/images/meal.jpg');
  }

  try {
    return MemoryImage(base64Decode(item.imageBase64));
  } catch (_) {
    return const AssetImage('assets/images/meal.jpg');
  }
}
