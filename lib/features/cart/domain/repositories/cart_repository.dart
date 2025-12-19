// lib/features/cart/domain/repositories/cart_repository.dart
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/cart/domain/entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems();
  Future<void> addToCart({
    required Product product, // Change ProductEntity to Product
    required int quantity,
  });
  Future<void> removeFromCart(String cartItemId);
  Future<void> updateQuantity({
    required String cartItemId,
    required int newQuantity,
  });
  Future<void> clearCart();
  Future<void> saveCartLocally(List<CartItemEntity> items);
  Future<List<CartItemEntity>> loadCartLocally();
}