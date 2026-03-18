import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/routing/app_routes.dart';

import '../../data/datasources/mock_meal_analyzer.dart';
import '../../domain/entities/meal_result.dart';

class AnalyzingMealPage extends StatefulWidget {
  const AnalyzingMealPage({super.key});

  @override
  State<AnalyzingMealPage> createState() => _AnalyzingMealPageState();
}

class _AnalyzingMealPageState extends State<AnalyzingMealPage> {
  final _analyzer = MockMealAnalyzer();

  final bool _canceled = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final MealResult result = await _analyzer.analyze();
    if (!mounted || _canceled) return;

    context.push(AppRoutes.mealResult, extra: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F2FF), Color(0xFFD8C7FF), Color(0xFFBFA6FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            child: Column(
              children: [
                const SizedBox(height: 18),
                const Text(
                  'Analyzing your meal...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C1C27),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This may take a few seconds.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1C27).withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 26),

                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // outer ring
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: CircularProgressIndicator(
                            strokeWidth: 14,
                            valueColor: AlwaysStoppedAnimation(
                              const Color(0xFF7F5BFF).withOpacity(0.30),
                            ),
                            backgroundColor: const Color(
                              0xFF7F5BFF,
                            ).withOpacity(0.10),
                          ),
                        ),

                        // inner soft circle
                        Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),

                        // rocket icon
                        Icon(
                          Icons.rocket_launch_rounded,
                          size: 64,
                          color: const Color(0xFF7F5BFF).withOpacity(0.70),
                        ),

                        // little spark
                        Positioned(
                          left: 78,
                          top: 98,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F0B6).withOpacity(0.90),
                              borderRadius: BorderRadius.circular(999),
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
      ),
    );
  }
}
