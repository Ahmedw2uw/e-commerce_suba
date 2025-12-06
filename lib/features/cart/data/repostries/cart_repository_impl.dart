// lib/features/cart/data/repositories/cart_repository_impl.dart
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:e_commerce/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:e_commerce/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:e_commerce/features/cart/data/models/cart_item_model.dart';
import 'package:e_commerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:e_commerce/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    try {
      final remoteItems = await remoteDataSource.getCartItems();
      await localDataSource.saveCartItems(remoteItems);
      return remoteItems;
    } catch (e) {
      print('Failed to fetch cart from server: $e');
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
      await remoteDataSource.addToCart(
        product: product,
        quantity: quantity,
      );
    } catch (e) {
      print('Failed to add to cart on server: $e');
      throw Exception('Please check your internet connection');
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await remoteDataSource.removeFromCart(cartItemId);
    } catch (e) {
      print('Failed to remove from cart on server: $e');
      throw Exception('Failed to remove item');
    }
  }

  @override
  Future<void> updateQuantity({
    required String cartItemId,
    required int newQuantity,
  }) async {
    try {
      await remoteDataSource.updateQuantity(
        cartItemId: cartItemId,
        newQuantity: newQuantity,
      );
    } catch (e) {
      print('Failed to update quantity on server: $e');
      throw Exception('Failed to update quantity');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await remoteDataSource.clearCart();
      await localDataSource.clearCart();
    } catch (e) {
      print('Failed to clear cart: $e');
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