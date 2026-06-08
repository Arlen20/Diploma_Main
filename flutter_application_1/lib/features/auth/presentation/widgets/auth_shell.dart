import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;

  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2352), Color(0xFF1B1736)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
          child: child,
        ),
      ),
    );
  }
}

class AuthBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const AuthBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.42)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class AuthBadgeIcon extends StatelessWidget {
  const AuthBadgeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE7D47A), width: 2),
      ),
      child: const Icon(
        Icons.fitness_center_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.16),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
