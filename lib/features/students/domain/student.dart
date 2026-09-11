enum StudentStatus { active, archived }

StudentStatus studentStatusFromApi(String value) =>
    value == 'ACTIVE' ? StudentStatus.active : StudentStatus.archived;

class Student {
  final String id;
  final String studentCode;
  final String fullName;
  final String locationId;
  final String? nikMasked;
  final String? guardianName;
  final String? address;
  final String? studentPhone;
  final String? guardianPhone;
  final StudentStatus status;

  const Student({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.locationId,
    required this.nikMasked,
    required this.guardianName,
    required this.address,
    required this.studentPhone,
    required this.guardianPhone,
    required this.status,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] as String,
    studentCode: json['studentCode'] as String,
    fullName: json['fullName'] as String,
    locationId: json['locationId'] as String,
    nikMasked: json['nikMasked'] as String?,
    guardianName: json['guardianName'] as String?,
    address: json['address'] as String?,
    studentPhone: json['studentPhone'] as String?,
    guardianPhone: json['guardianPhone'] as String?,
    status: studentStatusFromApi(json['status'] as String),
  );
}
