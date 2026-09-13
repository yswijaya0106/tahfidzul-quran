import '../../../core/network/api_client.dart';
import '../domain/ref_data.dart';

class RefDataRepository {
  final ApiClient _apiClient;

  RefDataRepository({required this._apiClient});

  Future<List<RefProvince>> listProvinces() async {
    final response = await _apiClient.get('/ref/provinces');
    return (response['data'] as List<dynamic>)
        .map((e) => RefProvince.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RefCity>> listCities({int? provinceId}) async {
    final response = await _apiClient.get(
      '/ref/cities',
      query: provinceId == null ? null : {'provinceId': provinceId},
    );
    return (response['data'] as List<dynamic>)
        .map((e) => RefCity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
