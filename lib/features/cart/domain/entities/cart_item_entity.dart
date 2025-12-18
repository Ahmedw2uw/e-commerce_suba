// lib/features/cart/domain/entities/cart_item_entity.dart
import 'package:e_commerce/features/navigation_layout/tabs/home/model/product_model.dart';
import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final Product product; // ← استخدم Product بدلاً من ProductEntity
  final int quantity;
  final DateTime addedAt;

  const CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  double get totalPrice => product.price * quantity;

  CartItemEntity copyWith({
    String? id,
    Product? product, // ← Product هنا أيضاً
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [id, product.id, quantity, addedAt];
}