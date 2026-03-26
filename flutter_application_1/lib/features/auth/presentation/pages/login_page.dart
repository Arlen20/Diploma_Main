import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/firebase_auth_providers.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../profile_settings/presentation/state/user_profile_provider.dart';
import '../utils/auth_error_message.dart';
import '../widgets/auth_shell.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final credentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await credentials.user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      ref.invalidate(authStateProvider);
      ref.invalidate(userProfileProvider);

      if (!mounted) return;
      if (refreshedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
        return;
      }

      if (!refreshedUser.emailVerified) {
        context.go(AppRoutes.checkInbox);
        return;
      }

      context.go(AppRoutes.onboardingGoal);
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Login FirebaseAuthException: code=${error.code}, message=${error.message}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message?.trim().isNotEmpty == true
                ? '${authErrorMessage(error.code)} ${error.message}'
                : authErrorMessage(error.code),
          ),
        ),
      );
    } catch (error) {
      debugPrint('Login unknown exception: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthBackButton(onTap: () => context.go(AppRoutes.splash)),
            const SizedBox(height: 34),
            const AuthBadgeIcon(),
            const SizedBox(height: 22),
            const Text(
              'Welcome back! Glad\nto see you, Again!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 28),
            AuthField(
              controller: _emailController,
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AuthField(
              controller: _passwordController,
              hint: 'Enter your password',
              obscureText: _obscurePassword,
              suffix: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.forgotPassword),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF342055),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const Spacer(),
            Center(
              child: Wrap(
                spacing: 4,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.register),
                    child: const Text(
                      'Register Now',
                      style: TextStyle(
                        color: Color(0xFFE7D47A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
