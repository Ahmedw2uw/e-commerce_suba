class Order {
  final int? id;
  final int? customerId;
  final String? customerAuthId;
  final int? addressId;
  final String status;
  final DateTime? orderDate;
  final double totalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    this.customerId,
    this.customerAuthId,
    this.addressId,
    this.status = 'pending',
    this.orderDate,
    required this.totalAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int?,
      customerAuthId: json['customer_auth_id'] as String?,
      addressId: json['address_id'] as int?,
      status: json['status'] as String? ?? 'pending',
      orderDate: json['order_date'] != null
          ? DateTime.parse(json['order_date'] as String)
          : null,
      totalAmount: (json['total_amount'] as num).toDouble(),
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
      'address_id': addressId,
      'status': status,
      'order_date': orderDate?.toIso8601String(),
      'total_amount': totalAmount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}