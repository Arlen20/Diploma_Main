import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../profile_settings/domain/entities/user_profile.dart';
import '../../../profile_settings/presentation/state/user_profile_provider.dart';
import '../utils/auth_error_message.dart';
import '../widgets/auth_shell.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all fields.')),
      );
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await credentials.user?.updateDisplayName(_nameController.text.trim());
      await credentials.user?.sendEmailVerification();

      final currentProfile = ref.read(userProfileProvider).valueOrNull ??
          UserProfile.empty;
      await ref.read(userProfileProvider.notifier).save(
            currentProfile.copyWith(
              uid: credentials.user?.uid ?? '',
              email: _emailController.text.trim(),
              name: _nameController.text.trim().isEmpty
                  ? currentProfile.name
                  : _nameController.text.trim(),
            ),
          );

      if (!mounted) return;
      context.go(AppRoutes.checkInbox);
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Register FirebaseAuthException: code=${error.code}, message=${error.message}',
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
      debugPrint('Register unknown exception: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $error')),
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
            const SizedBox(height: 34),
            const AuthBadgeIcon(),
            const SizedBox(height: 22),
            const Text(
              'Hello! Register to get\nstarted',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 28),
            AuthField(controller: _nameController, hint: 'Username'),
            const SizedBox(height: 16),
            AuthField(
              controller: _emailController,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AuthField(
              controller: _passwordController,
              hint: 'Password',
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
            const SizedBox(height: 16),
            AuthField(
              controller: _confirmPasswordController,
              hint: 'Confirm password',
              obscureText: _obscureConfirmPassword,
              suffix: IconButton(
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
            ),
            const SizedBox(height: 28),
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
                        'Register',
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
                    'Already have an account?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: const Text(
                      'Login Now',
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
