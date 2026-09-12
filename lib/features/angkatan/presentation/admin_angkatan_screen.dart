import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../locations/application/location_providers.dart';
import '../../locations/domain/location.dart';
import '../application/angkatan_providers.dart';
import '../domain/angkatan.dart';

/// "Angkatan" tab in the admin's main shell: every Rumah Tahfidz, collapsed
/// by default. Expanding one fetches (and manages) that location's cohorts
/// only at that point, mirroring the "Kegiatan" tab's pattern.
class AdminAngkatanScreen extends ConsumerWidget {
  const AdminAngkatanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Angkatan')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(locationListProvider.future),
        child: AsyncValueView(
          value: locations,
          onRetry: () => ref.invalidate(locationListProvider),
          isEmpty: (result) => result.data.isEmpty,
          empty: (_) => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada rumah tahfidz yang terdaftar.'),
            ),
          ),
          data: (context, result) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: result.data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _LocationAngkatanTile(location: result.data[index]),
          ),
        ),
      ),
    );
  }
}

class _LocationAngkatanTile extends StatefulWidget {
  final TahfidzLocation location;

  const _LocationAngkatanTile({required this.location});

  @override
  State<_LocationAngkatanTile> createState() => _LocationAngkatanTileState();
}

class _LocationAngkatanTileState extends State<_LocationAngkatanTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.deepGreen.withValues(alpha: 0.1),
              child: const Icon(
                Icons.mosque_outlined,
                color: AppColors.deepGreen,
              ),
            ),
            title: Text(
              widget.location.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              widget.location.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _AngkatanForLocation(locationId: widget.location.id),
            ),
        ],
      ),
    );
  }
}

class _AngkatanForLocation extends ConsumerWidget {
  final String locationId;

  const _AngkatanForLocation({required this.locationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final angkatanList = ref.watch(angkatanListProvider(locationId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        AsyncValueView(
          value: angkatanList,
          onRetry: () => ref.invalidate(angkatanListProvider(locationId)),
          isEmpty: (result) => result.data.isEmpty,
          empty: (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Belum ada angkatan di lokasi ini.'),
          ),
          data: (context, result) => Column(
            children: [
              for (final angkatan in result.data)
                _AngkatanRow(angkatan: angkatan, locationId: locationId),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () async {
              final created = await context.push<bool>(
                '/angkatan/new',
                extra: locationId,
              );
              if (created == true) {
                ref.invalidate(angkatanListProvider(locationId));
              }
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Angkatan'),
          ),
        ),
      ],
    );
  }
}

class _AngkatanRow extends ConsumerWidget {
  final Angkatan angkatan;
  final String locationId;

  const _AngkatanRow({required this.angkatan, required this.locationId});

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  angkatan.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${angkatan.startDate} — ${angkatan.endDate}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
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
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Hapus angkatan',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }
}
