import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/routing/app_router.dart';

class CheckInboxPage extends ConsumerWidget {
  const CheckInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Inbox')),
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              ref.read(appSessionProvider.notifier).markEmailVerified(),
          child: const Text('I verified email (dummy)'),
        ),
      ),
    );
  }
}
