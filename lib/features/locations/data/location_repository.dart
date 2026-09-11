import '../../../core/network/api_client.dart';
import '../../../core/pagination/page_result.dart';
import '../domain/location.dart';

class LocationRepository {
  final ApiClient _apiClient;

  LocationRepository({required this._apiClient});

  Future<PageResult<TahfidzLocation>> list({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/locations',
      query: {'page': page, 'pageSize': pageSize},
    );
    return PageResult.fromJson(response, TahfidzLocation.fromJson);
  }

  Future<TahfidzLocation> getById(String id) async {
    final response = await _apiClient.get('/locations/$id');
    return TahfidzLocation.fromJson(response['data'] as Map<String, dynamic>);
  }
}
