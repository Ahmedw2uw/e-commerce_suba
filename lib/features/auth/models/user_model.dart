class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String authUserId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.authUserId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      authUserId: json['auth_user_id'] ?? '',
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

class Address {
  final int id;
  final int? customerId;
  final String? customerAuthId;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;
  final DateTime createdAt;
  Address({
    required this.id,
    this.customerId,
    this.customerAuthId,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'Egypt',
    this.isDefault = false,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      customerId: json['customer_id'],
      customerAuthId: json['customer_auth_id'],
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zip_code'] ?? '',
      country: json['country'] ?? 'Egypt',
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_auth_id': customerAuthId,
      'street': street,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullAddress {
    return '$street, $city, $state, $zipCode, $country';
  }
}
