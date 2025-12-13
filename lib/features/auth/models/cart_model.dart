class Cart {
  final int? id;
  final int? customerId;
  final String? customerAuthId;
  final int itemId;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cart({
    this.id,
    this.customerId,
    this.customerAuthId,
    required this.itemId,
    this.quantity = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int?,
      customerAuthId: json['customer_auth_id'] as String?,
      itemId: json['item_id'] as int,
      quantity: json['quantity'] as int? ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_auth_id': customerAuthId,
      'item_id': itemId,
      'quantity': quantity,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}