enum LocationStatus { active, inactive }

LocationStatus locationStatusFromApi(String value) =>
    value == 'ACTIVE' ? LocationStatus.active : LocationStatus.inactive;

class TahfidzLocation {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? description;
  final LocationStatus status;

  const TahfidzLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.description,
    required this.status,
  });

  factory TahfidzLocation.fromJson(Map<String, dynamic> json) =>
      TahfidzLocation(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        phone: json['phone'] as String?,
        description: json['description'] as String?,
        status: locationStatusFromApi(json['status'] as String),
      );
}
