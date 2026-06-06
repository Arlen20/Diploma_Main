import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/auth/firebase_auth_providers.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../domain/entities/user_profile.dart';
import '../state/user_profile_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  String _goal = UserProfile.empty.goal;
  String _sex = UserProfile.empty.sex;
  String _activityLevel = UserProfile.empty.activityLevel;
  int _preferredTrainingDays = UserProfile.empty.preferredTrainingDays;
  bool _isSaving = false;
  bool _isSendingReset = false;
  bool _isSendingVerification = false;
  bool _isLoggingOut = false;
  bool _isPickingAvatar = false;
  String? _lastHydratedUid;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _hydrate(UserProfile profile) {
    if (_lastHydratedUid == profile.uid &&
        _nameController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _ageController.text.isNotEmpty) {
      return;
    }

    _lastHydratedUid = profile.uid;
    _nameController.text = profile.name;
    _heightController.text = profile.heightCm.toString();
    _weightController.text = profile.weightKg.toString();
    _ageController.text = profile.age.toString();
    _goal = profile.goal;
    _sex = profile.sex;
    _activityLevel = profile.activityLevel;
    _preferredTrainingDays = profile.preferredTrainingDays;
  }

  Future<void> _save(UserProfile currentProfile) async {
    final name = _nameController.text.trim();
    final height = int.tryParse(_heightController.text.trim());
    final weight = int.tryParse(_weightController.text.trim());
    final age = int.tryParse(_ageController.text.trim());

    if (name.isEmpty || height == null || weight == null || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields with valid values.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(userProfileProvider.notifier)
          .save(
            currentProfile.copyWith(
              name: name,
              goal: _goal,
              sex: _sex,
              activityLevel: _activityLevel,
              preferredTrainingDays: _preferredTrainingDays,
              heightCm: height,
              weightKg: weight,
              age: age,
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAvatar(UserProfile currentProfile) async {
    setState(() => _isPickingAvatar = true);
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (pickedImage == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final extension = pickedImage.path.split('.').last;
      final avatarFile = File(
        '${directory.path}/avatar_${currentProfile.uid}.$extension',
      );
      await File(pickedImage.path).copy(avatarFile.path);

      await ref
          .read(userProfileProvider.notifier)
          .save(currentProfile.copyWith(avatarLocalPath: avatarFile.path));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Avatar updated.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update avatar.')));
    } finally {
      if (mounted) {
        setState(() => _isPickingAvatar = false);
      }
    }
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email found for this account.')),
      );
      return;
    }

    setState(() => _isSendingReset = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Failed to send reset email.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingReset = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active user session found.')),
      );
      return;
    }

    setState(() => _isSendingVerification = true);
    try {
      await user.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent. Check your inbox.'),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Failed to resend verification.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingVerification = false);
      }
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      ref.invalidate(authStateProvider);
      ref.invalidate(userProfileProvider);
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.valueOrNull ?? UserProfile.empty;
    final currentUser = FirebaseAuth.instance.currentUser;
    final accountEmail = currentUser?.email ?? profile.email;
    final isVerified = currentUser?.emailVerified ?? false;
    _hydrate(profile);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
                child: ListView(
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: _AvatarPicker(
                              avatarLocalPath: profile.avatarLocalPath,
                              isPicking: _isPickingAvatar,
                              onTap: () => _pickAvatar(profile),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _InputLabel(label: 'Name'),
                          _ProfileField(controller: _nameController),
                          const SizedBox(height: 12),
                          _InputLabel(label: 'Goal'),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['Maintain', 'Lose weight', 'Gain muscle']
                                .map(
                                  (goal) => ChoiceChip(
                                    label: Text(goal),
                                    selected: _goal == goal,
                                    onSelected: (_) =>
                                        setState(() => _goal = goal),
                                    showCheckmark: true,
                                    checkmarkColor: const Color(0xFF1C1C27),
                                    selectedColor: const Color(0xFFF3F0B6),
                                    backgroundColor: const Color(0xFF514874),
                                    side: BorderSide(
                                      color: _goal == goal
                                          ? const Color(0xFFF3F0B6)
                                          : Colors.white.withOpacity(0.22),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    labelStyle: TextStyle(
                                      color: _goal == goal
                                          ? const Color(0xFF1C1C27)
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 12),
                          _InputLabel(label: 'Sex'),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['Male', 'Female', 'Other']
                                .map(
                                  (item) => ChoiceChip(
                                    label: Text(item),
                                    selected: _sex == item,
                                    onSelected: (_) =>
                                        setState(() => _sex = item),
                                    showCheckmark: true,
                                    checkmarkColor: const Color(0xFF1C1C27),
                                    selectedColor: const Color(0xFFF3F0B6),
                                    backgroundColor: const Color(0xFF514874),
                                    side: BorderSide(
                                      color: _sex == item
                                          ? const Color(0xFFF3F0B6)
                                          : Colors.white.withOpacity(0.22),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    labelStyle: TextStyle(
                                      color: _sex == item
                                          ? const Color(0xFF1C1C27)
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 12),
                          _InputLabel(label: 'Activity level'),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['Low', 'Moderate', 'High']
                                .map(
                                  (item) => ChoiceChip(
                                    label: Text(item),
                                    selected: _activityLevel == item,
                                    onSelected: (_) =>
                                        setState(() => _activityLevel = item),
                                    showCheckmark: true,
                                    checkmarkColor: const Color(0xFF1C1C27),
                                    selectedColor: const Color(0xFFF3F0B6),
                                    backgroundColor: const Color(0xFF514874),
                                    side: BorderSide(
                                      color: _activityLevel == item
                                          ? const Color(0xFFF3F0B6)
                                          : Colors.white.withOpacity(0.22),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    labelStyle: TextStyle(
                                      color: _activityLevel == item
                                          ? const Color(0xFF1C1C27)
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 12),
                          _InputLabel(label: 'Training days per week'),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(5, (index) => index + 2)
                                .map(
                                  (days) => ChoiceChip(
                                    label: Text('$days days'),
                                    selected: _preferredTrainingDays == days,
                                    onSelected: (_) => setState(
                                      () => _preferredTrainingDays = days,
                                    ),
                                    showCheckmark: true,
                                    checkmarkColor: const Color(0xFF1C1C27),
                                    selectedColor: const Color(0xFFF3F0B6),
                                    backgroundColor: const Color(0xFF514874),
                                    side: BorderSide(
                                      color: _preferredTrainingDays == days
                                          ? const Color(0xFFF3F0B6)
                                          : Colors.white.withOpacity(0.22),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    labelStyle: TextStyle(
                                      color: _preferredTrainingDays == days
                                          ? const Color(0xFF1C1C27)
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _InputLabel(label: 'Height (cm)'),
                                    _ProfileField(
                                      controller: _heightController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _InputLabel(label: 'Weight (kg)'),
                                    _ProfileField(
                                      controller: _weightController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const _InputLabel(label: 'Age'),
                          _ProfileField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => _save(profile),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF24134D),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save profile',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                          if (profileState.hasError) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Failed to save profile. Try again.',
                              style: TextStyle(
                                color: Colors.red.shade100,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            accountEmail,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isVerified
                                      ? Colors.green.withOpacity(0.18)
                                      : Colors.orange.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isVerified
                                        ? Colors.greenAccent.withOpacity(0.35)
                                        : Colors.orangeAccent.withOpacity(0.35),
                                  ),
                                ),
                                child: Text(
                                  isVerified
                                      ? 'Email verified'
                                      : 'Email not verified',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSendingReset
                                  ? null
                                  : () => _sendPasswordResetEmail(accountEmail),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF24134D),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: _isSendingReset
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Send password reset email',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                          if (!isVerified) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _isSendingVerification
                                    ? null
                                    : _resendVerificationEmail,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: _isSendingVerification
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Resend verification email',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isLoggingOut ? null : _logout,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: _isLoggingOut
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Two-factor authentication is not enabled in this version.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: AppBottomNav(selectedIndex: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;

  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withOpacity(0.70),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final String avatarLocalPath;
  final bool isPicking;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.avatarLocalPath,
    required this.isPicking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarFile = avatarLocalPath.isEmpty ? null : File(avatarLocalPath);
    final hasAvatar = avatarFile != null && avatarFile.existsSync();

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: isPicking ? null : onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white.withOpacity(0.14),
                backgroundImage: hasAvatar ? FileImage(avatarFile) : null,
                child: hasAvatar
                    ? null
                    : const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0B6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF24134D), width: 2),
                ),
                child: isPicking
                    ? const Padding(
                        padding: EdgeInsets.all(7),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        color: Color(0xFF24134D),
                        size: 16,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasAvatar ? 'Change avatar' : 'Upload avatar',
            style: TextStyle(
              color: Colors.white.withOpacity(0.76),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _ProfileField({required this.controller, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.10),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.16)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
