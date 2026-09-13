import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/page_result.dart';
import '../../../core/providers.dart';
import '../data/assessment_repository.dart';
import '../domain/assessment.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return AssessmentRepository(apiClient: ref.watch(apiClientProvider));
});

final assessmentHistoryProvider = FutureProvider.autoDispose
    .family<PageResult<MemorizationAssessment>, String>(
      (ref, studentId) =>
          ref.watch(assessmentRepositoryProvider).listForStudent(studentId),
    );

/// Full new-memorization history for a student's achievement chart, oldest
/// first. Fetches the max page size in one request rather than paginating —
/// the 300-day program bounds how much history there can ever be.
final assessmentChartHistoryProvider = FutureProvider.autoDispose
    .family<List<MemorizationAssessment>, String>((ref, studentId) async {
      final page = await ref
          .watch(assessmentRepositoryProvider)
          .listForStudent(
            studentId,
            pageSize: 100,
            assessmentType: AssessmentType.newMemorization,
          );
      return page.data.reversed.toList();
    });
