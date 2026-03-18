import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/app_router.dart'; // contains appSessionProvider
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_card.dart';

class OnboardingFinishPage extends ConsumerWidget {
  const OnboardingFinishPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = GoRouterState.of(context).extra;

    // ---- Safe parse from state.extra (handles int/double/String/null) ----
    final map = (extra is Map<String, dynamic>) ? extra : <String, dynamic>{};

    final goal = _asString(map["goal"], fallback: "Maintain");
    final weightNum = _asNum(map["weight"], fallback: 70);
    final heightNum = _asNum(map["height"], fallback: 175);

    final weight = weightNum.toStringAsFixed(0);
    final height = heightNum.toStringAsFixed(0);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Main content (scroll-safe + bottom padding for CTA)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      splashRadius: 22,
                    ),
                    const SizedBox(height: 6),

                    const Text(
                      "You’re\nready ✨",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 34,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Confirm your setup before we continue.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Summary card
                    GlassCard(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your setup",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _RowItem(label: "Goal", value: goal),
                          const SizedBox(height: 10),
                          _RowItem(label: "Weight", value: "$weight kg"),
                          const SizedBox(height: 10),
                          _RowItem(label: "Height", value: "$height cm"),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Progress dots (3/3)
                    Row(
                      children: const [
                        _Dot(active: false),
                        SizedBox(width: 6),
                        _Dot(active: false),
                        SizedBox(width: 6),
                        _Dot(active: true),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom CTA bar
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: GlassCard(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            // Mark onboarding as done (your existing session logic)
                            ref
                                .read(appSessionProvider.notifier)
                                .completeOnboarding();

                            // Go home
                            context.go(AppRoutes.home);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Finish & Go Home",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1C1C27),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Onboarding (3/3)",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
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

// ---------- Helpers ----------
num _asNum(dynamic v, {required num fallback}) {
  if (v == null) return fallback;
  if (v is num) return v;
  if (v is String) {
    final parsed = num.tryParse(v.trim());
    return parsed ?? fallback;
  }
  return fallback;
}

String _asString(dynamic v, {required String fallback}) {
  if (v == null) return fallback;
  if (v is String && v.trim().isNotEmpty) return v.trim();
  return fallback;
}

// ---------- UI Bits ----------
class _RowItem extends StatelessWidget {
  final String label;
  final String value;

  const _RowItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: active ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(active ? 0.9 : 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
