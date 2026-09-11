class AppUserSummary {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final bool isActive;

  const AppUserSummary({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
  });

  factory AppUserSummary.fromJson(Map<String, dynamic> json) => AppUserSummary(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    role: json['role'] as String,
    isActive: json['isActive'] as bool,
  );
}
