import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5A427C), Color(0xFF24134D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 28, 18, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Text(
                  'Start your\nFitness Journey',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Start your fitness journey\nwith our app's guidance and support.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
                const Spacer(),
                Center(
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFA76AF6).withOpacity(0.50),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.directions_run_rounded,
                      size: 124,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F214E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: Color(0xFF2F214E),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Lets start',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_double_arrow_right_rounded,
                          color: Colors.white.withOpacity(0.70),
                          size: 30,
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
