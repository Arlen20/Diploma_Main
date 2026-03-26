import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../profile_settings/presentation/state/user_profile_provider.dart';

class OnboardingGoalPage extends ConsumerStatefulWidget {
  const OnboardingGoalPage({super.key});

  @override
  ConsumerState<OnboardingGoalPage> createState() => _OnboardingGoalPageState();
}

class _OnboardingGoalPageState extends ConsumerState<OnboardingGoalPage> {
  static const _goals = ['Lose weight', 'Maintain', 'Gain muscle'];
  bool _initialized = false;
  int selected = 0;

  void _goToMetrics() {
    context.go(
      AppRoutes.onboardingMetrics,
      extra: <String, dynamic>{'goal': _goals[selected]},
    );
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final payload = extra is Map<String, dynamic>
        ? Map<String, dynamic>.from(extra)
        : <String, dynamic>{};
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.valueOrNull;

    if (!_initialized) {
      final currentGoal = payload['goal'] as String? ?? profile?.goal;
      final index = _goals.indexOf(currentGoal ?? '');
      selected = index >= 0 ? index : 1;
      _initialized = true;
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Let's set\nyour goal",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 34,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose one. You can change it later in Settings.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _GoalTile(
                      title: 'Lose weight',
                      subtitle: 'Cut calories and track meals',
                      icon: Icons.trending_down_rounded,
                      isSelected: selected == 0,
                      accent: const Color(0xFFFFCDEB),
                      onTap: () => setState(() => selected = 0),
                    ),
                    const SizedBox(height: 12),
                    _GoalTile(
                      title: 'Maintain',
                      subtitle: 'Stay consistent and build habits',
                      icon: Icons.auto_graph_rounded,
                      isSelected: selected == 1,
                      accent: const Color(0xFFF4F0B6),
                      onTap: () => setState(() => selected = 1),
                    ),
                    const SizedBox(height: 12),
                    _GoalTile(
                      title: 'Gain muscle',
                      subtitle: 'More protein and strength sessions',
                      icon: Icons.fitness_center_rounded,
                      isSelected: selected == 2,
                      accent: const Color(0xFFCFE8FF),
                      onTap: () => setState(() => selected = 2),
                    ),
                    const Spacer(),
                    Row(
                      children: const [
                        _Dot(active: true),
                        SizedBox(width: 6),
                        _Dot(active: false),
                        SizedBox(width: 6),
                        _Dot(active: false),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: _BottomBar(
                  primaryText: 'Continue',
                  secondaryText: 'Skip',
                  onPrimary: _goToMetrics,
                  onSecondary: _goToMetrics,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  const _GoalTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF1C1C27), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(isSelected ? 0.0 : 0.35),
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Color(0xFF1C1C27))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;

  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(active ? 0.9 : 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const _BottomBar({
    required this.primaryText,
    required this.secondaryText,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onSecondary,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.22)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                secondaryText,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                primaryText,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1C1C27),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
