/// An intake cohort/batch of students (e.g. "Angkatan 2024") admitted at a
/// specific Rumah Tahfidz, spanning a start and end date.
class Angkatan {
  final String id;
  final String locationId;
  final String name;
  final String startDate;
  final String endDate;

  const Angkatan({
    required this.id,
    required this.locationId,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  factory Angkatan.fromJson(Map<String, dynamic> json) => Angkatan(
    id: json['id'] as String,
    locationId: json['locationId'] as String,
    name: json['name'] as String,
    startDate: json['startDate'] as String,
    endDate: json['endDate'] as String,
  );
}
