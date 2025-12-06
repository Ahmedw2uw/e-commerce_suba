// lib/features/cart/data/models/cart_item_model.dart

import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:e_commerce/features/cart/domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.product,
    required super.quantity,
    required super.addedAt,
  });

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      product: entity.product,
      quantity: entity.quantity,
      addedAt: entity.addedAt,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'].toString(),
      product: json['product'] != null && json['product'] is Map
          ? Product.fromJson(json['product'])
          : Product(
              id: 0,
              name: '',
              description: '',
              price: 0,
              stockQuantity: 0,
              categoryId: 0,
              images: [],
            ),
      quantity: json['quantity'] ?? 1,
      addedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
