import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex; // 0=Home, 1=Schedule, 2=Stats, 3=Settings

  const AppBottomNav({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 26,
      blur: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.grid_view_rounded,
            selected: selectedIndex == 0,
            onTap: () => context.go(AppRoutes.home),
          ),
          _NavItem(
            icon: Icons.calendar_month_outlined,
            selected: selectedIndex == 1,
            onTap: () => context.go(AppRoutes.schedule),
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            selected: selectedIndex == 2,
            onTap: () => context.go(AppRoutes.stats),
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            selected: selectedIndex == 3,
            onTap: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: AppColors.bgBottom),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: 0.55,
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
