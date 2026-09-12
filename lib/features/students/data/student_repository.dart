import '../../../core/network/api_client.dart';
import '../../../core/pagination/page_result.dart';
import '../domain/student.dart';
import '../domain/student_profile.dart';

class StudentRepository {
  final ApiClient _apiClient;

  StudentRepository({required this._apiClient});

  /// [locationId] is optional so admins can search across every location
  /// (the backend only scopes by location for non-admin callers).
  Future<PageResult<Student>> list({
    String? locationId,
    String? name,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/students',
      query: {
        'locationId': ?locationId,
        'page': page,
        'pageSize': pageSize,
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );
    return PageResult.fromJson(response, Student.fromJson);
  }

  Future<Student> getById(String id) async {
    final response = await _apiClient.get('/students/$id');
    return Student.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<StudentProfile> getProfile(String id) async {
    final response = await _apiClient.get('/students/$id/profile');
    return StudentProfile.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Student> create({
    required String fullName,
    required String locationId,
    String? angkatanId,
    String? nik,
    String? guardianName,
    String? address,
    String? studentPhone,
    String? guardianPhone,
  }) async {
    final response = await _apiClient.post(
      '/students',
      data: {
        'fullName': fullName,
        'locationId': locationId,
        'angkatanId': ?angkatanId,
        'nik': ?nik,
        'guardianName': ?guardianName,
        'address': ?address,
        'studentPhone': ?studentPhone,
        'guardianPhone': ?guardianPhone,
      },
    );
    return Student.fromJson(response['data'] as Map<String, dynamic>);
  }
}
