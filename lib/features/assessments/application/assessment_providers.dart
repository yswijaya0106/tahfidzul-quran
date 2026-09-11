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
