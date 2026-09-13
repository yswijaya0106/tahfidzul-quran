import 'package:dio/dio.dart';

/// One geocoded address suggestion from OpenStreetMap Nominatim.
class NominatimAddressResult {
  final String displayName;
  final double latitude;
  final double longitude;
  final String? provinsi;
  final String? kabKota;
  final String? kecamatan;
  final String? kodePos;

  const NominatimAddressResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.provinsi,
    required this.kabKota,
    required this.kecamatan,
    required this.kodePos,
  });

  factory NominatimAddressResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? const {};
    return NominatimAddressResult(
      displayName: json['display_name'] as String,
      latitude: double.parse(json['lat'] as String),
      longitude: double.parse(json['lon'] as String),
      provinsi: address['state'] as String?,
      kabKota:
          (address['city'] ?? address['county'] ?? address['regency'] ?? address['town'])
              as String?,
      kecamatan: (address['suburb'] ?? address['city_district'] ?? address['subdistrict'])
          as String?,
      kodePos: address['postcode'] as String?,
    );
  }
}

/// Address search backed by the public OpenStreetMap Nominatim API — no
/// account/API key needed. Uses a bare Dio instance (not the app's
/// authenticated ApiClient) since this hits a third-party host, not our own
/// backend, and sends a descriptive User-Agent per Nominatim's usage policy
/// (https://operations.osmfoundation.org/policies/nominatim/).
class NominatimAddressService {
  final Dio _dio;

  NominatimAddressService({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<NominatimAddressResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];

    final response = await _dio.get<List<dynamic>>(
      'https://nominatim.openstreetmap.org/search',
      queryParameters: {
        'q': trimmed,
        'format': 'jsonv2',
        'addressdetails': 1,
        'limit': 5,
        'countrycodes': 'id',
      },
      options: Options(headers: {'User-Agent': 'TahfidzQuranApp/1.0'}),
    );

    final results = response.data ?? const [];
    return results
        .map((e) => NominatimAddressResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
