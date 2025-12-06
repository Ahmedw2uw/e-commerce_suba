// lib/features/cart/data/datasources/cart_remote_data_source.dart

import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:e_commerce/features/cart/data/models/cart_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addToCart({required Product product, required int quantity});
  Future<void> removeFromCart(String cartItemId);
  Future<void> updateQuantity({
    required String cartItemId,
    required int newQuantity,
  });
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final SupabaseClient supabaseClient;

  CartRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await supabaseClient
          .from('cart')
          .select('''
              *,
              product:item_id(*)
          ''')
          .eq('customer_auth_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cart items: $e');
    }
  }

  @override
  Future<void> addToCart({
    required Product product,
    required int quantity,
  }) async {
    try {
      print('Adding to cart: Product ID=${product.id}, Quantity=$quantity');

      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final existingItem = await supabaseClient
          .from('cart')
          .select()
          .eq('customer_auth_id', user.id)
          .eq('item_id', product.id)
          .maybeSingle();

      if (existingItem != null) {
        final newQuantity = (existingItem['quantity'] as int) + quantity;

        await supabaseClient
            .from('cart')
            .update({'quantity': newQuantity})
            .eq('id', existingItem['id']);
      } else {
        await supabaseClient.from('cart').insert({
          'customer_auth_id': user.id,
          'item_id': product.id,
          'quantity': quantity,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final user = supabaseClient.auth.currentUser;

      if (user == null) throw Exception('User not logged in');

      await supabaseClient
          .from('cart')
          .delete()
          .eq('id', cartItemId)
          .eq('customer_auth_id', user.id);
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  @override
  Future<void> updateQuantity({
    required String cartItemId,
    required int newQuantity,
  }) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await supabaseClient
          .from('cart')
          .update({'quantity': newQuantity})
          .eq('id', cartItemId)
          .eq('customer_auth_id', user.id);
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await supabaseClient
          .from('cart')
          .delete()
          .eq('customer_auth_id', user.id);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}
