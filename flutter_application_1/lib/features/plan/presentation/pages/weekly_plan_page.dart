import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';

class WeeklyPlanPage extends StatefulWidget {
  const WeeklyPlanPage({super.key});

  @override
  State<WeeklyPlanPage> createState() => _WeeklyPlanPageState();
}

class _WeeklyPlanPageState extends State<WeeklyPlanPage> {
  late final DateTime _weekStart;
  late int _selectedIndex;

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

  static const Map<int, List<_WorkoutPlanItem>> _weeklyPlans = {
    DateTime.monday: [
      _WorkoutPlanItem(
        title: 'Warm Up Run',
        timeLabel: '08:00',
        subtitle: '12 min light cardio and breathing prep',
        color: Color(0xFFFFCDEB),
        icon: Icons.directions_run_rounded,
      ),
      _WorkoutPlanItem(
        title: 'Upper Body Strength',
        timeLabel: '18:00',
        subtitle: 'Pushups, rows, shoulder press, 3 rounds',
        color: Color(0xFFF4F0B6),
        icon: Icons.fitness_center_rounded,
      ),
    ],
    DateTime.tuesday: [
      _WorkoutPlanItem(
        title: 'Mobility Session',
        timeLabel: '09:30',
        subtitle: 'Hips, spine, ankles, 20 min recovery flow',
        color: Color(0xFFCFE8FF),
        icon: Icons.self_improvement_rounded,
      ),
    ],
    DateTime.wednesday: [
      _WorkoutPlanItem(
        title: 'Core Builder',
        timeLabel: '07:30',
        subtitle: 'Planks, dead bugs, leg raises, 4 rounds',
        color: Color(0xFFE0D2FF),
        icon: Icons.bolt_rounded,
      ),
      _WorkoutPlanItem(
        title: 'Evening Walk',
        timeLabel: '20:00',
        subtitle: '30 min low-intensity recovery walk',
        color: Color(0xFFF4F0B6),
        icon: Icons.directions_walk_rounded,
      ),
    ],
    DateTime.thursday: [
      _WorkoutPlanItem(
        title: 'Lower Body Focus',
        timeLabel: '17:30',
        subtitle: 'Squats, lunges, glute bridge, calf raises',
        color: Color(0xFFFFDFC0),
        icon: Icons.accessibility_new_rounded,
      ),
    ],
    DateTime.friday: [
      _WorkoutPlanItem(
        title: 'Conditioning Circuit',
        timeLabel: '18:30',
        subtitle: 'Jump rope, burpees, mountain climbers',
        color: Color(0xFFFFCDEB),
        icon: Icons.local_fire_department_rounded,
      ),
    ],
    DateTime.saturday: [
      _WorkoutPlanItem(
        title: 'Stretch + Recovery',
        timeLabel: '10:00',
        subtitle: 'Full-body flexibility and breath work',
        color: Color(0xFFCFE8FF),
        icon: Icons.spa_rounded,
      ),
    ],
    DateTime.sunday: [],
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _selectedIndex = now.weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _weekStart.add(Duration(days: _selectedIndex));
    final selectedPlans = _weeklyPlans[selectedDate.weekday] ?? const [];
    final headingDate =
        '${selectedDate.day} ${_monthNames[selectedDate.month - 1]} ${selectedDate.year}';

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
                          final hasWorkout =
                              (_weeklyPlans[date.weekday] ?? const []).isNotEmpty;
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
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              selectedPlans.isEmpty
                                  ? Icons.bedtime_rounded
                                  : Icons.event_available_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedPlans.isEmpty
                                      ? 'Recovery day'
                                      : '${selectedPlans.length} workout${selectedPlans.length == 1 ? '' : 's'} planned',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedPlans.isEmpty
                                      ? 'Use the day for stretching, walking, and sleep.'
                                      : 'Tap a card below to review the session details.',
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
                      child: selectedPlans.isEmpty
                          ? _EmptyPlanState(dateLabel: headingDate)
                          : ListView.separated(
                              itemCount: selectedPlans.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = selectedPlans[index];
                                return _WorkoutCard(
                                  item: item,
                                  onTap: () => context.go(AppRoutes.trainingSuccess),
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
  final _WorkoutPlanItem item;
  final VoidCallback onTap;

  const _WorkoutCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                color: item.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(item.icon, color: const Color(0xFF1C1C27)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.timeLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.62),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
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
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ),
          ],
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
                Icons.bedtime_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No workout planned',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use $dateLabel as a recovery day or add a light mobility session later.',
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

class _WorkoutPlanItem {
  final String title;
  final String timeLabel;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _WorkoutPlanItem({
    required this.title,
    required this.timeLabel,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}
