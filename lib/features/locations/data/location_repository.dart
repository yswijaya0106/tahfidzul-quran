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

  Future<TahfidzLocation> create({
    required String name,
    required String address,
    String? provinsi,
    String? kabKota,
    String? kecamatan,
    String? kodePos,
    int? provinceId,
    int? cityId,
    double? latitude,
    double? longitude,
    String? phone,
    String? description,
    String? coverPhotoObjectKey,
    List<LocationOrganizationMember>? organizationMembers,
  }) async {
    final response = await _apiClient.post(
      '/locations',
      data: {
        'name': name,
        'address': address,
        if (provinsi != null && provinsi.isNotEmpty) 'provinsi': provinsi,
        if (kabKota != null && kabKota.isNotEmpty) 'kabKota': kabKota,
        if (kecamatan != null && kecamatan.isNotEmpty) 'kecamatan': kecamatan,
        if (kodePos != null && kodePos.isNotEmpty) 'kodePos': kodePos,
        'provinceId': ?provinceId,
        'cityId': ?cityId,
        'latitude': ?latitude,
        'longitude': ?longitude,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (coverPhotoObjectKey != null) 'coverPhotoObjectKey': coverPhotoObjectKey,
        if (organizationMembers != null)
          'organizationMembers': organizationMembers
              .map(_memberToJson)
              .toList(),
      },
    );
    return TahfidzLocation.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<TahfidzLocation> update(
    String id, {
    String? name,
    String? address,
    String? provinsi,
    String? kabKota,
    String? kecamatan,
    String? kodePos,
    int? provinceId,
    int? cityId,
    double? latitude,
    double? longitude,
    String? phone,
    String? description,
    String? coverPhotoObjectKey,
    LocationStatus? status,
    List<LocationOrganizationMember>? organizationMembers,
  }) async {
    final response = await _apiClient.patch(
      '/locations/$id',
      data: {
        'name': ?name,
        'address': ?address,
        'provinsi': ?provinsi,
        'kabKota': ?kabKota,
        'kecamatan': ?kecamatan,
        'kodePos': ?kodePos,
        'provinceId': ?provinceId,
        'cityId': ?cityId,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'phone': ?phone,
        'description': ?description,
        'coverPhotoObjectKey': ?coverPhotoObjectKey,
        if (status != null)
          'status': status == LocationStatus.active ? 'ACTIVE' : 'INACTIVE',
        if (organizationMembers != null)
          'organizationMembers': organizationMembers
              .map(_memberToJson)
              .toList(),
      },
    );
    return TahfidzLocation.fromJson(response['data'] as Map<String, dynamic>);
  }

  Map<String, dynamic> _memberToJson(LocationOrganizationMember member) => {
    'name': member.name,
    'roleTitle': member.roleTitle,
    if (member.phone != null && member.phone!.isNotEmpty) 'phone': member.phone,
  };

  Future<void> archive(String id) async {
    await _apiClient.delete('/locations/$id');
  }
}
