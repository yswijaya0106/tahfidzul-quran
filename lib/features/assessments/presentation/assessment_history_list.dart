import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_value_view.dart';
import '../application/assessment_providers.dart';
import '../domain/assessment.dart';

/// Embeds the assessment history for a student; used on the student detail
/// screen so a teacher can see prior records inline before adding a new one.
class AssessmentHistoryList extends ConsumerWidget {
  final String studentId;

  const AssessmentHistoryList({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(assessmentHistoryProvider(studentId));

    return AsyncValueView(
      value: history,
      onRetry: () => ref.invalidate(assessmentHistoryProvider(studentId)),
      isEmpty: (result) => result.data.isEmpty,
      empty: (_) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No assessments recorded yet.')),
      ),
      data: (context, result) => Column(
        children: result.data
            .map((assessment) => _AssessmentTile(assessment: assessment))
            .toList(),
      ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  final MemorizationAssessment assessment;

  const _AssessmentTile({required this.assessment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Text(
          assessmentTypeLabel(assessment.assessmentType).substring(0, 1),
        ),
      ),
      title: Text(
        'Surah ${assessment.startSurahNumber}:${assessment.startVerseNumber} — '
        '${assessment.endSurahNumber}:${assessment.endVerseNumber}',
      ),
      subtitle: Text(
        '${assessmentTypeLabel(assessment.assessmentType)} · ${assessment.assessmentDate}'
        '${assessment.notes?.isNotEmpty == true ? '\n${assessment.notes}' : ''}',
      ),
      isThreeLine: assessment.notes?.isNotEmpty == true,
      trailing: Chip(label: Text(assessmentGradeLabel(assessment.grade))),
    );
  }
}
