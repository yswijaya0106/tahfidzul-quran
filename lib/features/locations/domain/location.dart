enum LocationStatus { active, inactive }

LocationStatus locationStatusFromApi(String value) =>
    value == 'ACTIVE' ? LocationStatus.active : LocationStatus.inactive;

/// One member of a location's organizational structure (e.g. Ketua,
/// Sekretaris, Bendahara). Only present when a location is fetched by id
/// (`GET /locations/:id`) — the list endpoint omits it.
class LocationOrganizationMember {
  final String name;
  final String roleTitle;
  final String? phone;

  const LocationOrganizationMember({
    required this.name,
    required this.roleTitle,
    required this.phone,
  });

  factory LocationOrganizationMember.fromJson(Map<String, dynamic> json) =>
      LocationOrganizationMember(
        name: json['name'] as String,
        roleTitle: json['roleTitle'] as String,
        phone: json['phone'] as String?,
      );
}

class TahfidzLocation {
  final String id;
  final String name;
  final String address;
  final String? provinsi;
  final String? kabKota;
  final String? kecamatan;
  final String? kodePos;
  final int? provinceId;
  final int? cityId;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? description;
  final String? coverPhotoObjectKey;
  final String? coverPhotoUrl;
  final LocationStatus status;
  /// Empty for locations returned by the list endpoint; populated when
  /// fetched individually via [LocationRepository.getById].
  final List<LocationOrganizationMember> organizationMembers;

  const TahfidzLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.provinsi,
    required this.kabKota,
    required this.kecamatan,
    required this.kodePos,
    required this.provinceId,
    required this.cityId,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.description,
    required this.coverPhotoObjectKey,
    required this.coverPhotoUrl,
    required this.status,
    this.organizationMembers = const [],
  });

  /// "Jl. Contoh No. 1 · Kota Bandung" — falls back to just the address when
  /// the city isn't set.
  String get addressLine =>
      kabKota != null && kabKota!.isNotEmpty ? '$address · $kabKota' : address;

  factory TahfidzLocation.fromJson(Map<String, dynamic> json) =>
      TahfidzLocation(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        provinsi: json['provinsi'] as String?,
        kabKota: json['kabKota'] as String?,
        kecamatan: json['kecamatan'] as String?,
        kodePos: json['kodePos'] as String?,
        provinceId: json['provinceId'] as int?,
        cityId: json['cityId'] as int?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        phone: json['phone'] as String?,
        description: json['description'] as String?,
        coverPhotoObjectKey: json['coverPhotoObjectKey'] as String?,
        coverPhotoUrl: json['coverPhotoUrl'] as String?,
        status: locationStatusFromApi(json['status'] as String),
        organizationMembers:
            (json['organizationMembers'] as List<dynamic>?)
                ?.map(
                  (e) => LocationOrganizationMember.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            const [],
      );
}
