enum UserRole { admin, locationOperator }

UserRole userRoleFromApi(String value) {
  switch (value) {
    case 'ADMIN':
      return UserRole.admin;
    case 'LOCATION_OPERATOR':
      return UserRole.locationOperator;
    default:
      throw ArgumentError('Unknown role: $value');
  }
}

class AppUser {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final UserRole role;
  final bool isActive;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    role: userRoleFromApi(json['role'] as String),
    isActive: json['isActive'] as bool,
  );
}
