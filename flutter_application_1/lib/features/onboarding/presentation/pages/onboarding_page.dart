import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go(AppRoutes.onboardingGoal),
          child: const Text('Continue onboarding'),
        ),
      ),
    );
  }
}
