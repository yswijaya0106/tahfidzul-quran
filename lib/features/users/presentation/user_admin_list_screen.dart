import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_value_view.dart';
import '../application/user_admin_providers.dart';
import '../domain/app_user_summary.dart';

/// Admin-only user management screen (CLAUDE.md: "Admin can create,
/// deactivate, reset, and assign location operators."). This build covers
/// list + deactivate; create/assign forms are a follow-up increment.
class UserAdminListScreen extends ConsumerWidget {
  const UserAdminListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userAdminListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(userAdminListProvider.future),
        child: AsyncValueView(
          value: users,
          onRetry: () => ref.invalidate(userAdminListProvider),
          isEmpty: (result) => result.data.isEmpty,
          empty: (_) => const Center(child: Text('No users yet.')),
          data: (context, result) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: result.data.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _UserTile(user: result.data[index]),
          ),
        ),
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  final AppUserSummary user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      minVerticalPadding: 16,
      title: Text(user.fullName),
      subtitle: Text('${user.role}${user.isActive ? '' : ' · Deactivated'}'),
      trailing: user.isActive
          ? TextButton(
              onPressed: () async {
                await ref.read(userAdminRepositoryProvider).deactivate(user.id);
                ref.invalidate(userAdminListProvider);
              },
              child: const Text('Deactivate'),
            )
          : null,
    );
  }
}
