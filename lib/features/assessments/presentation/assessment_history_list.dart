import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
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
        child: Center(child: Text('Belum ada setoran yang tercatat.')),
      ),
      data: (context, result) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            for (var i = 0; i < result.data.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 68),
              _AssessmentTile(assessment: result.data[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// Grade -> accent color, matching the mapping used for the grade
/// distribution chart on the location dashboard, so the same grade always
/// reads as the same color across the app.
const Map<Grade, Color> _gradeColors = {
  Grade.mumtaz: AppColors.deepGreen,
  Grade.jayyidJiddan: AppColors.gold,
  Grade.jayyid: AppColors.goldLight,
  Grade.maqbul: AppColors.navy,
  Grade.rasib: AppColors.maroon,
};

class _AssessmentTile extends StatelessWidget {
  final MemorizationAssessment assessment;

  const _AssessmentTile({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final dayLabel = assessment.dayNumber != null
        ? ' · Hari ke-${assessment.dayNumber}'
        : '';
    final showTargetBadge =
        assessment.assessmentType == AssessmentType.newMemorization &&
        assessment.dayNumber != null;
    final gradeColor = _gradeColors[assessment.grade] ?? AppColors.ink;

    // A plain Row instead of ListTile: ListTile enforces a fixed tile height
    // based on title/subtitle line count, which doesn't leave room for the
    // trailing grade chip + target badge stacking to two lines.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                assessmentTypeLabel(assessment.assessmentType).substring(0, 1),
                style: TextStyle(fontWeight: FontWeight.w800, color: gradeColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Surah ${assessment.startSurahNumber}:${assessment.startVerseNumber} — '
                  '${assessment.endSurahNumber}:${assessment.endVerseNumber}',
                ),
                const SizedBox(height: 4),
                Text(
                  '${assessmentTypeLabel(assessment.assessmentType)} · ${assessment.assessmentDate}$dayLabel',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (assessment.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    assessment.notes!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Chip(
                label: Text(assessmentGradeLabel(assessment.grade)),
                backgroundColor: gradeColor.withValues(alpha: 0.14),
                labelStyle: TextStyle(
                  color: gradeColor,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide.none,
              ),
              if (showTargetBadge) ...[
                const SizedBox(height: 4),
                _TargetStatusBadge(status: assessment.targetStatus),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetStatusBadge extends StatelessWidget {
  final TargetStatus status;

  const _TargetStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (status) {
      TargetStatus.reached => (
        Icons.check_circle_rounded,
        AppColors.deepGreen,
        'Target tercapai',
      ),
      TargetStatus.notReached => (
        Icons.error_rounded,
        AppColors.maroon,
        'Belum tercapai',
      ),
      TargetStatus.noTargetData => (
        Icons.help_rounded,
        Theme.of(context).colorScheme.outline,
        'Tanpa target',
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
