class AdminUserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String? level;

  AdminUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.level,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      role: json['role'],
      level: json['level'],
    );
  }
}