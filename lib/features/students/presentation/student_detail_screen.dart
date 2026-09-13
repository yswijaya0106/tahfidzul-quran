import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../angkatan/application/angkatan_providers.dart';
import '../../assessments/presentation/achievement_chart.dart';
import '../../assessments/presentation/assessment_history_list.dart';
import '../application/student_providers.dart';
import '../domain/student.dart';
import 'student_photo_field.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentDetailProvider(studentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Siswa')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>(
            '/students/$studentId/assessments/new',
          );
          if (created == true) {
            ref.invalidate(studentDetailProvider(studentId));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Setoran baru'),
      ),
      body: AsyncValueView(
        value: student,
        onRetry: () => ref.invalidate(studentDetailProvider(studentId)),
        data: (context, data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StudentHeader(student: data),
            const SizedBox(height: 24),
            const SectionHeader(
              icon: Icons.show_chart_rounded,
              title: 'Grafik Pencapaian',
              color: AppColors.gold,
            ),
            const SizedBox(height: 12),
            AchievementChart(studentId: studentId),
            const SizedBox(height: 24),
            const SectionHeader(
              icon: Icons.history_edu_rounded,
              title: 'Riwayat Setoran',
              color: AppColors.maroon,
            ),
            const SizedBox(height: 12),
            AssessmentHistoryList(studentId: studentId),
          ],
        ),
      ),
    );
  }
}

class _StudentHeader extends ConsumerWidget {
  final Student student;

  const _StudentHeader({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final angkatan = student.angkatanId == null
        ? null
        : ref.watch(angkatanDetailProvider(student.angkatanId!)).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudentPhotoField(
          photoUrl: student.studentPhotoUrl,
          onUploaded: (uploaded) async {
            try {
              await ref
                  .read(studentRepositoryProvider)
                  .updatePhoto(
                    id: student.id,
                    studentPhotoObjectKey: uploaded.objectKey,
                  );
              ref.invalidate(studentDetailProvider(student.id));
            } on AppException catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.message)));
              }
            }
          },
        ),
        const SizedBox(height: 12),
        Text(
          student.fullName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          student.studentCode,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            final rows = <_InfoRow>[
              if (angkatan != null)
                _InfoRow(
                  icon: Icons.groups_2_rounded,
                  iconColor: AppColors.navy,
                  label: 'Angkatan',
                  value: angkatan.name,
                ),
              if (student.guardianName != null)
                _InfoRow(
                  icon: Icons.family_restroom_rounded,
                  iconColor: AppColors.deepGreen,
                  label: 'Wali',
                  value: student.guardianName!,
                ),
              if (student.studentPhone != null)
                _InfoRow(
                  icon: Icons.phone_iphone_rounded,
                  iconColor: AppColors.gold,
                  label: 'Telepon siswa',
                  value: student.studentPhone!,
                ),
              if (student.guardianPhone != null)
                _InfoRow(
                  icon: Icons.phone_rounded,
                  iconColor: AppColors.gold,
                  label: 'Telepon wali',
                  value: student.guardianPhone!,
                ),
              if (student.address != null)
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.maroon,
                  label: 'Alamat',
                  value: student.address!,
                ),
              if (student.nikMasked != null)
                _InfoRow(
                  icon: Icons.credit_card_rounded,
                  iconColor: AppColors.navy,
                  label: 'NIK',
                  value: student.nikMasked!,
                ),
            ];
            if (rows.isEmpty) return const SizedBox.shrink();
            return AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    rows[i],
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
