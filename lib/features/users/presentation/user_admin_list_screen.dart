import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../application/user_admin_providers.dart';
import '../domain/app_user_summary.dart';

/// Admin-only user management screen (CLAUDE.md: "Admin can create,
/// deactivate, reset, and assign location operators.").
class UserAdminListScreen extends ConsumerWidget {
  const UserAdminListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userAdminListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengguna')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>('/users/new');
          if (created == true) ref.invalidate(userAdminListProvider);
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Pengguna'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(userAdminListProvider.future),
        child: AsyncValueView(
          value: users,
          onRetry: () => ref.invalidate(userAdminListProvider),
          isEmpty: (result) => result.data.isEmpty,
          empty: (_) => const Center(child: Text('Belum ada pengguna.')),
          data: (context, result) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: result.data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
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
    final isAdmin = user.role == 'ADMIN';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        minVerticalPadding: 16,
        leading: CircleAvatar(
          backgroundColor: (isAdmin ? AppColors.maroon : AppColors.deepGreen)
              .withValues(alpha: 0.12),
          child: Icon(
            isAdmin ? Icons.shield_outlined : Icons.badge_outlined,
            color: isAdmin ? AppColors.maroon : AppColors.deepGreen,
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${isAdmin ? 'Admin' : 'Operator Lokasi'}${user.isActive ? '' : ' · Nonaktif'}',
        ),
        trailing: user.isActive
            ? TextButton(
                onPressed: () async {
                  await ref
                      .read(userAdminRepositoryProvider)
                      .deactivate(user.id);
                  ref.invalidate(userAdminListProvider);
                },
                child: const Text('Nonaktifkan'),
              )
            : null,
      ),
    );
  }
}
