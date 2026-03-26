import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../widgets/auth_shell.dart';

class VerificationSuccessPage extends StatefulWidget {
  const VerificationSuccessPage({super.key});

  @override
  State<VerificationSuccessPage> createState() => _VerificationSuccessPageState();
}

class _VerificationSuccessPageState extends State<VerificationSuccessPage> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      context.go(AppRoutes.onboardingGoal);
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthBackButton(onTap: () => context.go(AppRoutes.login)),
            const Spacer(),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Color(0xFFDDF0F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 52,
                  color: Color(0xFF2B174F),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Center(
              child: Text(
                'Verification successful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Redirecting you to onboarding...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.70),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.onboardingGoal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF342055),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
