/// Indonesian province reference data (id, not a UUID — matches the
/// pre-existing `ref_province` table this project reuses).
class RefProvince {
  final int id;
  final String? provinceName;

  const RefProvince({required this.id, required this.provinceName});

  factory RefProvince.fromJson(Map<String, dynamic> json) => RefProvince(
    id: json['id'] as int,
    provinceName: json['provinceName'] as String?,
  );
}

/// Indonesian regency/city (kabupaten/kota) reference data, each belonging
/// to a province.
class RefCity {
  final int id;
  final String? cityName;
  final int? provinceId;

  const RefCity({required this.id, required this.cityName, required this.provinceId});

  factory RefCity.fromJson(Map<String, dynamic> json) => RefCity(
    id: json['id'] as int,
    cityName: json['cityName'] as String?,
    provinceId: json['provinceId'] as int?,
  );
}
