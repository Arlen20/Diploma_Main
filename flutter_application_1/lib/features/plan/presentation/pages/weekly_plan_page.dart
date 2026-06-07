import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/routing/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../profile_settings/presentation/state/user_profile_provider.dart';
import '../../domain/entities/workout_plan_entry.dart';
import '../state/workout_plan_provider.dart';

class WeeklyPlanPage extends ConsumerStatefulWidget {
  const WeeklyPlanPage({super.key});

  @override
  ConsumerState<WeeklyPlanPage> createState() => _WeeklyPlanPageState();
}

class _WeeklyPlanPageState extends ConsumerState<WeeklyPlanPage> {
  late final DateTime _weekStart;
  late int _selectedIndex;
  bool _isGenerating = false;

  static const _weekdayShort = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _selectedIndex = now.weekday - 1;
  }

  Future<void> _generatePlan() async {
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile == null || profile.uid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Load your profile first.')));
      return;
    }

    setState(() => _isGenerating = true);
    try {
      await ref.read(workoutPlanProvider.notifier).generate(profile);
      if (!mounted) return;
      final nextState = ref.read(workoutPlanProvider);
      if (nextState.hasError) {
        final message = nextState.error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.contains('permission-denied')
                  ? 'Plan generation failed. Publish the updated Firestore rules for plans first.'
                  : 'Plan generation failed: $message',
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Prototype AI plan generated for ${profile.goal.toLowerCase()}.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _weekStart.add(Duration(days: _selectedIndex));
    final headingDate =
        '${selectedDate.day} ${_monthNames[selectedDate.month - 1]} ${selectedDate.year}';
    final planState = ref.watch(workoutPlanProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final allPlans = planState.valueOrNull ?? const <WorkoutPlanEntry>[];
    final selectedPlans = allPlans
        .where((item) => item.dayOfWeek == selectedDate.weekday)
        .toList(growable: false);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly\nPlan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      headingDate,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.68),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 108,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final date = _weekStart.add(Duration(days: index));
                          final isSelected = index == _selectedIndex;
                          final hasWorkout = allPlans.any(
                            (item) => item.dayOfWeek == date.weekday,
                          );
                          return _DayCard(
                            label: _weekdayShort[index],
                            dayNumber: date.day,
                            isSelected: isSelected,
                            hasWorkout: hasWorkout,
                            onTap: () => setState(() => _selectedIndex = index),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  allPlans.isEmpty
                                      ? Icons.auto_awesome_rounded
                                      : Icons.psychology_alt_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      allPlans.isEmpty
                                          ? 'No plan generated yet'
                                          : '${selectedPlans.length} session${selectedPlans.length == 1 ? '' : 's'} for this day',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      profile == null
                                          ? 'Sign in to generate a prototype AI weekly plan.'
                                          : 'Goal: ${profile.goal}. Activity: ${profile.activityLevel}. ${profile.preferredTrainingDays} training days selected.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.66),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isGenerating ? null : _generatePlan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF24134D),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: _isGenerating
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      allPlans.isEmpty
                                          ? 'Generate plan'
                                          : 'Regenerate plan',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Sessions',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: planState.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : planState.hasError
                          ? _PlanErrorState(
                              message: planState.error.toString(),
                              onRetry: _generatePlan,
                            )
                          : selectedPlans.isEmpty
                          ? _EmptyPlanState(dateLabel: headingDate)
                          : ListView.separated(
                              itemCount: selectedPlans.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = selectedPlans[index];
                                return _WorkoutCard(
                                  item: item,
                                  onTap: () => context.go(
                                    AppRoutes.trainingSession,
                                    extra: item,
                                  ),
                                  onToggleComplete: () => ref
                                      .read(workoutPlanProvider.notifier)
                                      .toggleCompleted(item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: AppBottomNav(selectedIndex: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String label;
  final int dayNumber;
  final bool isSelected;
  final bool hasWorkout;
  final VoidCallback onTap;

  const _DayCard({
    required this.label,
    required this.dayNumber,
    required this.isSelected,
    required this.hasWorkout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 74,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFF4F0B6)
                  : Colors.white.withOpacity(0.10),
            ),
            color: isSelected ? Colors.white.withOpacity(0.06) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$dayNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: hasWorkout
                      ? const Color(0xFFF4F0B6)
                      : Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutPlanEntry item;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const _WorkoutCard({
    required this.item,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseNames = item.exercises
        .map((exercise) => exercise.name)
        .toList(growable: false);
    final hasExerciseList = exerciseNames.isNotEmpty;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _focusColor(item.focus),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _focusIcon(item.focus),
                color: const Color(0xFF1C1C27),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.timeLabel,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.62),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (item.completed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  if (hasExerciseList) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final name in exerciseNames)
                          _ExerciseChip(label: name),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: onToggleComplete,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                item.completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: item.completed ? Colors.greenAccent : AppColors.accent,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _focusColor(String focus) {
    switch (focus) {
      case 'legs':
        return const Color(0xFFFFDFC0);
      case 'upper body':
      case 'back':
        return const Color(0xFFCFE8FF);
      case 'core':
        return const Color(0xFFE0D2FF);
      case 'cardio':
        return const Color(0xFFFFCDEB);
      case 'mobility':
        return const Color(0xFFF4F0B6);
      default:
        return const Color(0xFFF4F0B6);
    }
  }

  IconData _focusIcon(String focus) {
    switch (focus) {
      case 'legs':
        return Icons.accessibility_new_rounded;
      case 'upper body':
      case 'back':
        return Icons.fitness_center_rounded;
      case 'core':
        return Icons.bolt_rounded;
      case 'cardio':
        return Icons.directions_run_rounded;
      case 'mobility':
        return Icons.self_improvement_rounded;
      default:
        return Icons.event_available_rounded;
    }
  }
}

class _ExerciseChip extends StatelessWidget {
  final String label;

  const _ExerciseChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.82),
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _EmptyPlanState extends StatelessWidget {
  final String dateLabel;

  const _EmptyPlanState({required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No session for this day',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a plan or use $dateLabel as a recovery day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.66),
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PlanErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Plan generation failed',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message.contains('permission-denied')
                  ? 'Firestore rejected access to plans. Publish the latest rules in Firebase Console.'
                  : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.66),
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF24134D),
              ),
              child: const Text(
                'Try again',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
