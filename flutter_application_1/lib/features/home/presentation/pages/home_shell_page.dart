import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class HomeShellPage extends StatelessWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: Column(
              children: [
                _TopHeader(),
                const SizedBox(height: 18),

                // Nutrition today big card
                _NutritionCard(
                  onAddMeal: () => context.push(AppRoutes.addMeal),
                ),
                const SizedBox(height: 22),

                // Your Schedule title row
                _ScheduleHeader(),
                const SizedBox(height: 14),

                //start button
                _ScheduleTimeline(onStart: () {}),

                const Spacer(),
                const AppBottomNav(selectedIndex: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: Text("Hi!,\nYoussef", style: AppText.titleBig)),
        _SearchPill(),
      ],
    );
  }
}

class _SearchPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
              image: const DecorationImage(
                image: NetworkImage("https://i.pravatar.cc/100?img=12"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final VoidCallback onAddMeal;
  const _NutritionCard({required this.onAddMeal});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: AppRadii.r30,
      blur: 22,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nutrition today",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Track calories and macros from your meal",
            style: AppText.subtitle,
          ),
          const SizedBox(height: 14),

          // Figma-like white pill button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onAddMeal,
                child: Center(
                  child: Text(
                    "+  Add meal",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark.withOpacity(0.92),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your\nSchedule", style: AppText.titleBig),
              const SizedBox(height: 4),
              Text("Today's Activity", style: AppText.labelMuted),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: const Icon(Icons.tune, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

class _ScheduleTimeline extends StatelessWidget {
  final VoidCallback onStart;
  const _ScheduleTimeline({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // left dot
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 12),

            const Expanded(
              child: Text(
                "WarmUp",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),

            // Start pill button (yellow)
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onStart,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Text(
                      "Start",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBtnText,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.play_arrow,
                      size: 20,
                      color: AppColors.primaryBtnText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // subtle timeline dots
        Padding(
          padding: const EdgeInsets.only(left: 7),
          child: Column(
            children: [
              Container(
                width: 2,
                height: 26,
                color: Colors.white.withOpacity(0.16),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // next item preview
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              "Muscle Up\n10 reps, 3 sets with 20 sec rest",
              style: TextStyle(
                color: Colors.white.withOpacity(0.28),
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
