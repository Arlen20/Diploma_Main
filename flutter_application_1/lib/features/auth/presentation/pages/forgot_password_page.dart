import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../utils/auth_error_message.dart';
import '../widgets/auth_shell.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email first.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
      context.go(AppRoutes.login);
    } on FirebaseAuthException catch (error) {
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
            AuthBackButton(onTap: () => context.go(AppRoutes.login)),
            const SizedBox(height: 54),
            const Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "Don't worry! It occurs. Please enter the email\naddress linked with your account.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            AuthField(
              controller: _emailController,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
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
                        'Send Code',
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
                    'Remember Password?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: const Text(
                      'Login',
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
