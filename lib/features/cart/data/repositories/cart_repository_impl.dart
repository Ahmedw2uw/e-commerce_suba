// lib/features/cart/data/repositories/cart_repository_impl.dart
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:e_commerce/features/cart/data/models/cart_item_model.dart';
import 'package:e_commerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:e_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    try {
      final cartData = await SupabaseService.getCart();
      final cartList = cartData['cart'] as List;
      
      final remoteItems = cartList.map((item) {
        return CartItemModel(
          id: item['id'].toString(),
          product: Product.fromJson(item['product']),
          quantity: item['quantity'] as int,
          addedAt: DateTime.parse(item['created_at']),
        );
      }).toList();
      
      await localDataSource.saveCartItems(remoteItems);
      return remoteItems;
    } catch (e) {
      final localItems = await localDataSource.getCartItems();
      return localItems;
    }
  }

  @override
  Future<void> addToCart({
    required Product product,
    required int quantity,
  }) async {
    try {
      await SupabaseService.addToCart(
        productId: product.id,
        quantity: quantity,
      );
    } catch (e) {
      throw Exception('Please check your internet connection');
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await SupabaseService.removeFromCart(int.parse(cartItemId));
    } catch (e) {
      throw Exception('Failed to remove item');
    }
  }

  @override
  Future<void> updateQuantity({
    required String cartItemId,
    required int newQuantity,
  }) async {
    try {
      await SupabaseService.updateCartItem(
        cartItemId: int.parse(cartItemId),
        quantity: newQuantity,
      );
    } catch (e) {
      throw Exception('Failed to update quantity');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await SupabaseService.clearCart();
      await localDataSource.clearCart();
    } catch (e) {
      throw Exception('Failed to clear cart');
    }
  }

  @override
  Future<void> saveCartLocally(List<CartItemEntity> items) async {
    final models = items.map((item) {
      if (item is CartItemModel) {
        return item;
      }
      return CartItemModel(
        id: item.id,
        product: item.product,
        quantity: item.quantity,
        addedAt: item.addedAt,
      );
    }).toList();
    
    await localDataSource.saveCartItems(models);
  }

  @override
  Future<List<CartItemEntity>> loadCartLocally() async {
    return await localDataSource.getCartItems();
  }
}