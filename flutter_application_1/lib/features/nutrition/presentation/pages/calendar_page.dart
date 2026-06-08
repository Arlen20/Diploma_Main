import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../domain/entities/meal_log.dart';
import '../state/meal_history_notifier.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealHistoryProvider).valueOrNull ?? const <MealLog>[];

    final mealsByDay = <DateTime, List<MealLog>>{};
    for (final meal in meals) {
      final key = DateTime(
        meal.createdAt.year,
        meal.createdAt.month,
        meal.createdAt.day,
      );
      mealsByDay.putIfAbsent(key, () => []).add(meal);
    }

    List<MealLog> mealsFor(DateTime day) =>
        mealsByDay[DateTime(day.year, day.month, day.day)] ?? const [];

    final selectedMeals = mealsFor(_selectedDay);
    final dayCalories =
        selectedMeals.fold<int>(0, (sum, m) => sum + m.result.calories);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              GlassCard(
                padding: const EdgeInsets.all(8),
                child: TableCalendar<MealLog>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: mealsFor,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w700,
                    ),
                    weekendStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: const TextStyle(color: Colors.white),
                    outsideTextStyle: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(color: Colors.white),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Color(0xFF1B1736),
                      fontWeight: FontWeight.w900,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFF8FD3FF),
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(_selectedDay),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (selectedMeals.isNotEmpty)
                    Text(
                      '$dayCalories kcal',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (selectedMeals.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      'No meals logged on this day.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                ...selectedMeals.map((m) => _DayMealTile(meal: m)),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class _DayMealTile extends StatelessWidget {
  final MealLog meal;

  const _DayMealTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: _imageProviderFor(meal),
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.result.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${meal.result.calories} kcal | P ${meal.result.protein}g · C ${meal.result.carbs}g · F ${meal.result.fat}g',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.62),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
