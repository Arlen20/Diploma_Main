// lib/features/profile_settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/gradient_background.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: AppBottomNav(selectedIndex: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
