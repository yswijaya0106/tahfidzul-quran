import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../application/daily_target_providers.dart';
import '../domain/daily_target.dart';

/// Admin-only CRUD for the "Target Tilawah/Tahfidz 300 Hari" reference
/// schedule. All 300 days are fetched once; a search field filters by day
/// number so a specific day is quick to find without paging through 300 rows.
class DailyTargetListScreen extends ConsumerStatefulWidget {
  const DailyTargetListScreen({super.key});

  @override
  ConsumerState<DailyTargetListScreen> createState() =>
      _DailyTargetListScreenState();
}

class _DailyTargetListScreenState
    extends ConsumerState<DailyTargetListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetsAsync = ref.watch(dailyTargetListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Target Harian 300 Hari')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>('/daily-targets/new');
          if (created == true) ref.invalidate(dailyTargetListProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Hari'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cari hari ke-...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(dailyTargetListProvider.future),
              child: AsyncValueView(
                value: targetsAsync,
                onRetry: () => ref.invalidate(dailyTargetListProvider),
                isEmpty: (result) => result.isEmpty,
                empty: (_) => const Center(
                  child: Text('Belum ada data target harian.'),
                ),
                data: (context, result) {
                  final filtered = _query.isEmpty
                      ? result
                      : result
                            .where((t) => t.dayNumber.toString().contains(_query))
                            .toList();
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Tidak ditemukan hari yang cocok.'),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _DailyTargetTile(target: filtered[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTargetTile extends ConsumerWidget {
  final DailyTarget target;

  const _DailyTargetTile({required this.target});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus target hari ke-${target.dayNumber}?'),
        content: const Text(
          'Ini akan gagal jika sudah ada setoran yang tercatat pada hari ini.',
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
      await ref.read(dailyTargetRepositoryProvider).delete(target.dayNumber);
      ref.invalidate(dailyTargetListProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal menghapus. Pastikan tidak ada setoran yang mereferensikan hari ini.',
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
          child: Text(
            '${target.dayNumber}',
            style: const TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          'Hari ke-${target.dayNumber}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Surah ${target.startSurahNumber}:${target.startVerseNumber} — '
          '${target.endSurahNumber}:${target.endVerseNumber}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit target',
              onPressed: () async {
                final changed = await context.push<bool>(
                  '/daily-targets/${target.dayNumber}/edit',
                  extra: target,
                );
                if (changed == true) ref.invalidate(dailyTargetListProvider);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus target',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
