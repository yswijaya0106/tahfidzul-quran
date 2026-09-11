import '../../../core/network/api_client.dart';
import '../../../core/pagination/page_result.dart';
import '../domain/assessment.dart';

class AssessmentRepository {
  final ApiClient _apiClient;

  AssessmentRepository({required this._apiClient});

  Future<PageResult<MemorizationAssessment>> listForStudent(
    String studentId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/students/$studentId/assessments',
      query: {'page': page, 'pageSize': pageSize},
    );
    return PageResult.fromJson(response, MemorizationAssessment.fromJson);
  }

  Future<MemorizationAssessment> create({
    required String studentId,
    required DateTime assessmentDate,
    required AssessmentType assessmentType,
    required int startSurahNumber,
    required int startVerseNumber,
    required int endSurahNumber,
    required int endVerseNumber,
    required Grade grade,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '/students/$studentId/assessments',
      data: {
        'assessmentDate': assessmentDate.toUtc().toIso8601String(),
        'assessmentType': assessmentTypeToApi(assessmentType),
        'startSurahNumber': startSurahNumber,
        'startVerseNumber': startVerseNumber,
        'endSurahNumber': endSurahNumber,
        'endVerseNumber': endVerseNumber,
        'grade': assessmentGradeToApi(grade),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return MemorizationAssessment.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  Future<void> archive(String assessmentId) async {
    await _apiClient.delete('/assessments/$assessmentId');
  }
}
