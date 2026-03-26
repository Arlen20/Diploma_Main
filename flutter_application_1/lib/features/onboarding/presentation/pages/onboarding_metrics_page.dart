import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../profile_settings/presentation/state/user_profile_provider.dart';

class OnboardingMetricsPage extends ConsumerStatefulWidget {
  const OnboardingMetricsPage({super.key});

  @override
  ConsumerState<OnboardingMetricsPage> createState() =>
      _OnboardingMetricsPageState();
}

class _OnboardingMetricsPageState extends ConsumerState<OnboardingMetricsPage> {
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _age = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final payload = extra is Map<String, dynamic>
        ? Map<String, dynamic>.from(extra)
        : <String, dynamic>{};
    final profile = ref.watch(userProfileProvider).valueOrNull;

    if (!_initialized && profile != null) {
      _height.text = profile.heightCm.toString();
      _weight.text = profile.weightKg.toString();
      _age.text = profile.age.toString();
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.go(
                            AppRoutes.onboardingGoal,
                            extra: payload,
                          ),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          splashRadius: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Step 2 of 3',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your\nmetrics',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 34,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We use this to estimate calories and macros.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GlassCard(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      child: Column(
                        children: [
                          _MetricField(
                            label: 'Height',
                            unit: 'cm',
                            controller: _height,
                            icon: Icons.height_rounded,
                          ),
                          const SizedBox(height: 12),
                          _MetricField(
                            label: 'Weight',
                            unit: 'kg',
                            controller: _weight,
                            icon: Icons.monitor_weight_rounded,
                          ),
                          const SizedBox(height: 12),
                          _MetricField(
                            label: 'Age',
                            unit: 'years',
                            controller: _age,
                            icon: Icons.cake_rounded,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: const [
                        _Dot(active: false),
                        SizedBox(width: 6),
                        _Dot(active: true),
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
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go(
                            AppRoutes.onboardingGoal,
                            extra: payload,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.22),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Back',
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
                          onPressed: () {
                            final height = int.tryParse(_height.text.trim());
                            final weight = int.tryParse(_weight.text.trim());
                            final age = int.tryParse(_age.text.trim());

                            if (height == null ||
                                weight == null ||
                                age == null ||
                                height <= 0 ||
                                weight <= 0 ||
                                age <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Enter valid height, weight, and age.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final nextPayload = <String, dynamic>{
                              ...payload,
                              'height': height,
                              'weight': weight,
                              'age': age,
                            };
                            context.go(
                              AppRoutes.onboardingFinish,
                              extra: nextPayload,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1C1C27),
                            ),
                          ),
                        ),
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

class _MetricField extends StatelessWidget {
  final String label;
  final String unit;
  final TextEditingController controller;
  final IconData icon;

  const _MetricField({
    required this.label,
    required this.unit,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontWeight: FontWeight.w800,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.35)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          unit,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
