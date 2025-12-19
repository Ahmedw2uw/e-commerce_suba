import 'package:e_commerce/core/models/product_model.dart';
import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final Product product; 
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
    Product? product, // Product here as well
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