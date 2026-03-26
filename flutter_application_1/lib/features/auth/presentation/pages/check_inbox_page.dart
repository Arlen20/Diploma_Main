import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/firebase_auth_providers.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../profile_settings/presentation/state/user_profile_provider.dart';
import '../widgets/auth_shell.dart';

class CheckInboxPage extends ConsumerStatefulWidget {
  const CheckInboxPage({super.key});

  @override
  ConsumerState<CheckInboxPage> createState() => _CheckInboxPageState();
}

class _CheckInboxPageState extends ConsumerState<CheckInboxPage> {
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    _startVerificationPolling();
  }

  Future<void> _refreshVerificationState({bool showFeedback = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (!mounted || refreshedUser == null) return;

    if (refreshedUser.emailVerified) {
      _verificationTimer?.cancel();
      ref.invalidate(authStateProvider);
      ref.invalidate(userProfileProvider);
      context.go(AppRoutes.verificationSuccess);
      return;
    }

    if (showFeedback) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email is still not verified. Open the link from your inbox first.'),
        ),
      );
    }
  }

  void _startVerificationPolling() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshVerificationState(),
    );
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthBackButton(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                context.go(AppRoutes.login);
              },
            ),
            const SizedBox(height: 34),
            const AuthBadgeIcon(),
            const SizedBox(height: 22),
            const Text(
              'Check your inbox',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'We sent a verification email.\nOpen it and confirm your account.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 16,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next in Firebase',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '1. Create account\n2. Send verification email\n3. Poll or refresh verification state\n4. Unlock onboarding after verification',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.70),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _refreshVerificationState(showFeedback: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF342055),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Refresh now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser
                      ?.sendEmailVerification();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.24)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Resend email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
