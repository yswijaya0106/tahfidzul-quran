import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user.dart';
import '../../locations/application/location_providers.dart';
import '../application/angkatan_providers.dart';
import '../domain/angkatan.dart';

/// Manages the angkatan (intake cohorts) for the currently selected location.
/// Every role can view the list (used elsewhere as a dropdown source), but
/// create/edit/delete are admin-only, per project rule: all writes besides
/// memorization assessments are admin-only.
class AngkatanListScreen extends ConsumerWidget {
  const AngkatanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationId = ref.watch(selectedLocationIdProvider);
    if (locationId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin =
        ref.watch(authControllerProvider).valueOrNull?.role == UserRole.admin;
    final angkatanList = ref.watch(angkatanListProvider(locationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Angkatan')),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await context.push<bool>(
                  '/angkatan/new',
                  extra: locationId,
                );
                if (created == true) {
                  ref.invalidate(angkatanListProvider(locationId));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Angkatan'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(angkatanListProvider(locationId).future),
        child: AsyncValueView(
          value: angkatanList,
          onRetry: () => ref.invalidate(angkatanListProvider(locationId)),
          isEmpty: (result) => result.data.isEmpty,
          empty: (_) => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada angkatan untuk lokasi ini.'),
            ),
          ),
          data: (context, result) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: result.data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _AngkatanTile(
              angkatan: result.data[index],
              locationId: locationId,
              isAdmin: isAdmin,
            ),
          ),
        ),
      ),
    );
  }
}

class _AngkatanTile extends ConsumerWidget {
  final Angkatan angkatan;
  final String locationId;
  final bool isAdmin;

  const _AngkatanTile({
    required this.angkatan,
    required this.locationId,
    required this.isAdmin,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus angkatan?'),
        content: Text(
          'Angkatan "${angkatan.name}" akan dihapus. Ini gagal jika masih ada siswa yang terdaftar di angkatan ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(angkatanRepositoryProvider).delete(angkatan.id);
      ref.invalidate(angkatanListProvider(locationId));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal menghapus angkatan. Pastikan tidak ada siswa yang masih terdaftar.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.deepGreen.withValues(alpha: 0.1),
          child: const Icon(Icons.groups_outlined, color: AppColors.deepGreen),
        ),
        title: Text(
          angkatan.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${angkatan.startDate} — ${angkatan.endDate}'),
        trailing: isAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit angkatan',
                    onPressed: () async {
                      final changed = await context.push<bool>(
                        '/angkatan/${angkatan.id}/edit',
                        extra: {'locationId': locationId, 'angkatan': angkatan},
                      );
                      if (changed == true) {
                        ref.invalidate(angkatanListProvider(locationId));
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Hapus angkatan',
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
