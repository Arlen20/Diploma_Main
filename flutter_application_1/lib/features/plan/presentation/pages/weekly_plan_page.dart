import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class WeeklyPlanPage extends StatelessWidget {
  const WeeklyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
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
    final monthName = months[now.month - 1];

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // ---------- TOP (date + calendar) ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    // Header: TODAY IS + Date + arrows
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TODAY IS",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.70),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    height: 1.05,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "${now.day},$monthName\n",
                                      style: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${now.year}",
                                      style: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.chevron_left,
                              color: Colors.white.withOpacity(0.55),
                              size: 28,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white.withOpacity(0.55),
                              size: 28,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const _WeekdayRow(),
                    const SizedBox(height: 12),

                    const _CalendarGrid(selectedDay: 11),

                    const SizedBox(height: 18),

                    // (Removed the old "handle" here — we add it INSIDE the sheet so it looks like Figma)
                  ],
                ),
              ),

              // ---------- BOTTOM SHEET (white panel) ----------
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  // Slightly smaller so the sheet starts lower (less overlap with calendar)
                  height: 420,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F2FA),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(44),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // sheet content (scrollable so it never clips behind nav)
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // handle pill (Figma-like)
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 86,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Center(
                              child: Text(
                                "Your Schedule",
                                style: TextStyle(
                                  color: AppColors.textDark.withOpacity(0.92),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // timeline + first card
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _TimelineLeft(activeTop: true),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _WorkoutCard(
                                    color: const Color(0xFFFFCDEB),
                                    dateTime: "December, 11, 8am",
                                    title: "WarmUp",
                                    subtitle: "",
                                    icon: Icons.directions_run,
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // timeline + second card
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _TimelineLeft(activeTop: false),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _WorkoutCard(
                                    color: const Color(0xFFF4F0B6),
                                    dateTime: "December, 11, 4pm",
                                    title: "Pushups session",
                                    subtitle: "25 rep, 3 sets with 20 sec rest",
                                    icon: Icons.fitness_center,
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // bottom nav overlay (shared widget)
                      const Positioned(
                        left: 18,
                        right: 18,
                        bottom: 18,
                        child: AppBottomNav(
                          selectedIndex: 1,
                        ), // 1 = Schedule tab
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    const labels = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (t) => Text(
              t,
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final int selectedDay;
  const _CalendarGrid({required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final days = List<int>.generate(14, (i) => i + 1);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: days.map((d) {
        final isSelected = d == selectedDay;
        return _DayCircle(day: d, selected: isSelected);
      }).toList(),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final int day;
  final bool selected;
  const _DayCircle({required this.day, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFCDEB) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? Colors.transparent : Colors.white.withOpacity(0.28),
          width: 1,
        ),
      ),
      child: Text(
        "$day",
        style: TextStyle(
          color: selected
              ? AppColors.textDark.withOpacity(0.90)
              : Colors.white.withOpacity(0.75),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TimelineLeft extends StatelessWidget {
  final bool activeTop;
  const _TimelineLeft({required this.activeTop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      child: Column(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: activeTop
                  ? const Color(0xFFF4F0B6)
                  : const Color(0xFFDAD7E7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: activeTop
                ? const Icon(Icons.check, size: 14, color: Color(0xFF1C1C27))
                : null,
          ),
          const SizedBox(height: 10),

          // softer line like Figma
          Container(
            width: 2,
            height: 90,
            color: const Color(0xFF1C1C27).withOpacity(0.10),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Color color;
  final String dateTime;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _WorkoutCard({
    required this.color,
    required this.dateTime,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateTime,
                    style: TextStyle(
                      // darker than before (better contrast)
                      color: const Color(0xFF1C1C27).withOpacity(0.65),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.92),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textDark.withOpacity(0.65),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColors.textDark.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
