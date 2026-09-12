import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../assessments/presentation/assessment_history_list.dart';
import '../application/student_providers.dart';
import '../domain/student.dart';
import '../domain/student_profile.dart';

/// "Profil" tab: shows the student most recently picked from search, with
/// their memorization progress and assessment history.
class AdminStudentProfileScreen extends ConsumerWidget {
  const AdminStudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = ref.watch(selectedProfileStudentIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Siswa')),
      body: studentId == null
          ? const _EmptyProfilePrompt()
          : _StudentProfileBody(studentId: studentId),
    );
  }
}

class _EmptyProfilePrompt extends StatelessWidget {
  const _EmptyProfilePrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada siswa dipilih',
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cari siswa terlebih dahulu di tab Pencarian, lalu pilih salah satu hasilnya.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentProfileBody extends ConsumerWidget {
  final String studentId;

  const _StudentProfileBody({required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(studentProfileProvider(studentId));

    return AsyncValueView(
      value: profile,
      onRetry: () => ref.invalidate(studentProfileProvider(studentId)),
      data: (context, result) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(student: result.student),
          const SizedBox(height: 16),
          _ProgressCard(progress: result.progress),
          const Divider(height: 32),
          Text(
            'Riwayat Setoran',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          AssessmentHistoryList(studentId: studentId),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Student student;

  const _ProfileHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.deepGreen.withValues(alpha: 0.1),
          child: const Icon(
            Icons.person,
            color: AppColors.deepGreen,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.fullName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                student.studentCode,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.open_in_new),
          tooltip: 'Lihat detail lengkap',
          onPressed: () => context.push('/students/${student.id}'),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final MemorizationProgress progress;

  const _ProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 20,
                  color: AppColors.deepGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Progress Hafalan',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PositionRow(
              label: 'Hafalan Baru Terakhir',
              position: progress.latestNewMemorization,
            ),
            const SizedBox(height: 8),
            _PositionRow(
              label: 'Murojaah Terakhir',
              position: progress.latestMurojaah,
            ),
            if (progress.distributionByGrade.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: progress.distributionByGrade.entries
                    .where((entry) => entry.value > 0)
                    .map(
                      (entry) => Chip(
                        label: Text('${entry.key}: ${entry.value}'),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PositionRow extends StatelessWidget {
  final String label;
  final AssessmentPosition? position;

  const _PositionRow({required this.label, required this.position});

  @override
  Widget build(BuildContext context) {
    final value = position == null
        ? 'Belum ada data'
        : 'Surah ${position!.startSurahNumber}:${position!.startVerseNumber} '
              '- ${position!.endSurahNumber}:${position!.endVerseNumber} '
              '(${position!.grade})';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
