class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? authUserId;
  final String role;
  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.authUserId,
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      authUserId: json['auth_user_id'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'auth_user_id': authUserId,
    };
  }
}

