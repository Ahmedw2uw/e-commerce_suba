class Wishlist {
  final int? id;
  final int? customerId;
  final String? customerAuthId;
  final int productId;
  final DateTime? createdAt;

  Wishlist({
    this.id,
    this.customerId,
    this.customerAuthId,
    required this.productId,
    this.createdAt,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int?,
      customerAuthId: json['customer_auth_id'] as String?,
      productId: json['product_id'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_auth_id': customerAuthId,
      'product_id': productId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}