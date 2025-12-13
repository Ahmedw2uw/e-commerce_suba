class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final double pricePerUnit;
  final int quantity;
  final DateTime? createdAt;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.pricePerUnit,
    required this.quantity,
    this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int?,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      pricePerUnit: (json['price_per_unit'] as num).toDouble(),
      quantity: json['quantity'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'price_per_unit': pricePerUnit,
      'quantity': quantity,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}