import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/routing/app_routes.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/meal_log.dart';
import '../../domain/entities/meal_result.dart';
import '../state/meal_history_notifier.dart';

class MealResultPage extends ConsumerStatefulWidget {
  const MealResultPage({super.key});

  @override
  ConsumerState<MealResultPage> createState() => _MealResultPageState();
}

class _MealResultPageState extends ConsumerState<MealResultPage> {
  bool _saved = false;
  bool _saving = false;
  String _category = MealCategories.defaultForTime(DateTime.now());

  Future<void> _share(MealResult r) async {
    final text =
        '${r.title} — ${r.calories} kcal\n'
        'Protein ${r.protein}g · Carbs ${r.carbs}g · Fat ${r.fat}g\n'
        'Tracked with my fitness app 💪';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final payload = extra is Map<String, dynamic>
        ? Map<String, dynamic>.from(extra)
        : null;
    final result = payload != null
        ? payload['result'] as MealResult
        : extra as MealResult;
    final isReadOnly = payload?['readOnly'] == true;
    final imageBytes = _imageBytesFromPayload(payload);
    final imageMimeType = payload?['imageMimeType'] as String? ?? 'image/jpeg';
    final savedCategory = payload?['category'] as String? ?? '';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B2352), Color(0xFF1B1736)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isReadOnly ? 'Saved meal details' : 'Estimated nutrition',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _share(result),
                      icon: const Icon(Icons.ios_share_rounded,
                          color: Colors.white),
                      tooltip: 'Share',
                    ),
                  ],
                ),
                if (isReadOnly && savedCategory.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _CategoryPill(label: savedCategory),
                ],
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _MealPhoto(bytes: imageBytes, height: 180),
                      ),
                      const SizedBox(height: 12),
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
                            '${result.calories} ',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.white.withOpacity(0.12)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MacroChip(
                            color: const Color(0xFFF4F0B6),
                            icon: Icons.egg_alt_outlined,
                            value: '${result.protein}g',
                            label: 'Protein',
                          ),
                          _MacroChip(
                            color: const Color(0xFFE0D2FF),
                            icon: Icons.grain,
                            value: '${result.carbs}g',
                            label: 'Carbs',
                          ),
                          _MacroChip(
                            color: const Color(0xFFFFCDEB),
                            icon: Icons.opacity_outlined,
                            value: '${result.fat}g',
                            label: 'Fat',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isReadOnly) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F0B6),
                        foregroundColor: const Color(0xFF1B1736),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => context.go(AppRoutes.mealHistory),
                      child: const Text(
                        'Back to history',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ] else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Meal type',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MealCategories.all.map((category) {
                      final selected = _category == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) => setState(() => _category = category),
                        showCheckmark: false,
                        selectedColor: const Color(0xFFF3F0B6),
                        backgroundColor: Colors.white.withOpacity(0.10),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFFF3F0B6)
                              : Colors.white.withOpacity(0.20),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? const Color(0xFF1B1736)
                              : Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F0B6),
                        foregroundColor: const Color(0xFF1B1736),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _saved || _saving
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              try {
                                await ref
                                    .read(mealHistoryProvider.notifier)
                                    .add(
                                      result,
                                      imageBytes: imageBytes,
                                      imageMimeType: imageMimeType,
                                      category: _category,
                                    );
                                if (!mounted) return;
                                setState(() {
                                  _saved = true;
                                  _saving = false;
                                });
                                context.go(AppRoutes.mealHistory);
                              } catch (error) {
                                if (!mounted) return;
                                setState(() => _saving = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Could not save meal: $error'),
                                  ),
                                );
                              }
                            },
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                color: Color(0xFF1B1736),
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => context.go(AppRoutes.addMeal),
                      child: const Text(
                        'Edit',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Uint8List? _imageBytesFromPayload(Map<String, dynamic>? payload) {
  if (payload == null) return null;
  final bytes = payload['imageBytes'];
  if (bytes is Uint8List) return bytes;

  final imageBase64 = payload['imageBase64'];
  if (imageBase64 is String && imageBase64.isNotEmpty) {
    try {
      return base64Decode(imageBase64);
    } catch (_) {
      return null;
    }
  }

  return null;
}

class _MealPhoto extends StatelessWidget {
  final Uint8List? bytes;
  final double height;

  const _MealPhoto({
    required this.bytes,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final imageBytes = bytes;
    if (imageBytes == null) {
      return Image.asset(
        'assets/images/meal.jpg',
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.memory(
      imageBytes,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;

  const _CategoryPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
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
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}
