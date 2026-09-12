import '../../../core/network/api_client.dart';
import '../../../core/pagination/page_result.dart';
import '../domain/app_user_summary.dart';

class UserAdminRepository {
  final ApiClient _apiClient;

  UserAdminRepository({required this._apiClient});

  Future<PageResult<AppUserSummary>> list({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/users',
      query: {'page': page, 'pageSize': pageSize},
    );
    return PageResult.fromJson(response, AppUserSummary.fromJson);
  }

  Future<void> deactivate(String userId) async {
    await _apiClient.post('/users/$userId/deactivate');
  }

  Future<AppUserSummary> create({
    required String fullName,
    String? email,
    String? phone,
    required String password,
    required String role,
    List<String>? locationIds,
  }) async {
    final response = await _apiClient.post(
      '/users',
      data: {
        'fullName': fullName,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'password': password,
        'role': role,
        if (locationIds != null && locationIds.isNotEmpty)
          'locationIds': locationIds,
      },
    );
    return AppUserSummary.fromJson(response['data'] as Map<String, dynamic>);
  }
}
