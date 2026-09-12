import '../../../core/network/api_client.dart';
import '../../../core/pagination/page_result.dart';
import '../domain/angkatan.dart';

class AngkatanRepository {
  final ApiClient _apiClient;

  AngkatanRepository({required this._apiClient});

  Future<PageResult<Angkatan>> listForLocation(
    String locationId, {
    String? search,
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _apiClient.get(
      '/locations/$locationId/angkatan',
      query: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return PageResult.fromJson(response, Angkatan.fromJson);
  }

  Future<Angkatan> getById(String id) async {
    final response = await _apiClient.get('/angkatan/$id');
    return Angkatan.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Angkatan> create({
    required String locationId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _apiClient.post(
      '/locations/$locationId/angkatan',
      data: {
        'name': name,
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),
      },
    );
    return Angkatan.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Angkatan> update(
    String id, {
    String? name,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _apiClient.patch(
      '/angkatan/$id',
      data: {
        'name': ?name,
        'startDate': ?(startDate != null ? _formatDate(startDate) : null),
        'endDate': ?(endDate != null ? _formatDate(endDate) : null),
      },
    );
    return Angkatan.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('/angkatan/$id');
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
