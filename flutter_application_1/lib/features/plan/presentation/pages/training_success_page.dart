import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';

class TrainingSuccessPage extends StatelessWidget {
  const TrainingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              children: [
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ...const [
                      _ConfettiArc(
                        alignment: Alignment.topLeft,
                        color: Color(0xFFFF9A3C),
                        rotation: -0.4,
                      ),
                      _ConfettiArc(
                        alignment: Alignment.topRight,
                        color: Color(0xFF8A5BFF),
                        rotation: 0.6,
                      ),
                      _ConfettiArc(
                        alignment: Alignment.bottomLeft,
                        color: Color(0xFFFF4F9A),
                        rotation: 0.7,
                      ),
                      _ConfettiArc(
                        alignment: Alignment.bottomRight,
                        color: Color(0xFFFF9A3C),
                        rotation: -0.7,
                      ),
                    ],
                    Container(
                      width: 220,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 34,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFFF7B54),
                            size: 56,
                          ),
                          SizedBox(height: 18),
                          Text(
                            'Training completed\nsuccessfully',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1C1C27),
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.schedule),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F0B6),
                      foregroundColor: const Color(0xFF1B1736),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfettiArc extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double rotation;

  const _ConfettiArc({
    required this.alignment,
    required this.color,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: 44,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color, width: 5),
          ),
        ),
      ),
    );
  }
}
