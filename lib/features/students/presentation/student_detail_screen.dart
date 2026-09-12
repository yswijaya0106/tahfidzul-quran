import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_view.dart';
import '../../angkatan/application/angkatan_providers.dart';
import '../../assessments/presentation/assessment_history_list.dart';
import '../application/student_providers.dart';
import '../domain/student.dart';

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
            const Divider(height: 32),
            Text(
              'Riwayat Setoran',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
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
        Text(
          student.fullName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          student.studentCode,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        if (angkatan != null) _InfoRow(label: 'Angkatan', value: angkatan.name),
        if (student.guardianName != null)
          _InfoRow(label: 'Wali', value: student.guardianName!),
        if (student.studentPhone != null)
          _InfoRow(label: 'Telepon siswa', value: student.studentPhone!),
        if (student.guardianPhone != null)
          _InfoRow(label: 'Telepon wali', value: student.guardianPhone!),
        if (student.address != null)
          _InfoRow(label: 'Alamat', value: student.address!),
        if (student.nikMasked != null)
          _InfoRow(label: 'NIK', value: student.nikMasked!),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
