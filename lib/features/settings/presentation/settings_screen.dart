import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(user.fullName),
              subtitle: Text(user.email ?? user.phone ?? ''),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out of this device'),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Sign out of all devices'),
            onTap: () async {
              await ref
                  .read(authControllerProvider.notifier)
                  .logoutAllDevices();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
