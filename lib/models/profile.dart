class Profile {
  final String id;
  final String? fullName;
  final String? phone;
  final String? bloodType;
  final String role; // 'citizen', 'health_officer', 'admin'

  Profile({
    required this.id,
    this.fullName,
    this.phone,
    this.bloodType,
    required this.role,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'],
        fullName: json['full_name'],
        phone: json['phone'],
        bloodType: json['blood_type'],
        role: json['role'] ?? 'citizen',
      );

  bool get isStaff => role == 'health_officer' || role == 'admin';
  bool get isAdmin => role == 'admin';
}