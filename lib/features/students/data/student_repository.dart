import '../../../core/network/api_client.dart';
import '../../../core/pagination/page_result.dart';
import '../domain/student.dart';

class StudentRepository {
  final ApiClient _apiClient;

  StudentRepository({required this._apiClient});

  Future<PageResult<Student>> list({
    required String locationId,
    String? name,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/students',
      query: {
        'locationId': locationId,
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

  Future<Student> create({
    required String fullName,
    required String locationId,
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
