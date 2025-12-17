// lib/features/favorites/data/datasources/favorites_remote_data_source.dart
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<Product>> getFavoriteProducts();
  Future<void> addToFavorites(int productId);
  Future<void> removeFromFavorites(int productId);
  Future<bool> isProductFavorite(int productId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final SupabaseClient _client;

  FavoritesRemoteDataSourceImpl() : _client = Supabase.instance.client;

  @override
  Future<List<Product>> getFavoriteProducts() async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('favorites')
          .select('''
            product:product_id (*, category(*))
          ''')
          .eq('customer_auth_id', authUser.id)
          .order('created_at', ascending: false);

      final favorites = response as List;
      final products = favorites
          .map((fav) => Product.fromJson(fav['product']))
          .toList();
      
      return products;
    } catch (e) {
      throw Exception('Failed to fetch favorite products: $e');
    }
  }

  @override
  Future<void> addToFavorites(int productId) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      await _client.from('favorites').insert({
        'customer_auth_id': authUser.id,
        'product_id': productId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add product to favorites: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(int productId) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from('favorites')
          .delete()
          .eq('customer_auth_id', authUser.id)
          .eq('product_id', productId);
    } catch (e) {
      throw Exception('Failed to remove product from favorites: $e');
    }
  }

  @override
  Future<bool> isProductFavorite(int productId) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        return false;
      }

      final response = await _client
          .from('favorites')
          .select()
          .eq('customer_auth_id', authUser.id)
          .eq('product_id', productId);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}