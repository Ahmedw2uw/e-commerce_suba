// lib/features/favorites/data/repositories/favorites_repository.dart
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';

abstract class FavoritesRepository {
  Future<List<Product>> getFavoriteProducts();
  Future<void> addToFavorites(int productId);
  Future<void> removeFromFavorites(int productId);
  Future<bool> isProductFavorite(int productId);
  Future<void> toggleFavorite(int productId);
}

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl();

  @override
  Future<List<Product>> getFavoriteProducts() {
    return SupabaseService.getFavoriteProducts();
  }

  @override
  Future<void> addToFavorites(int productId) {
    return SupabaseService.addToFavorites(productId);
  }

  @override
  Future<void> removeFromFavorites(int productId) {
    return SupabaseService.removeFromFavorites(productId);
  }

  @override
  Future<bool> isProductFavorite(int productId) {
    return SupabaseService.isProductFavorite(productId);
  }

  @override
  Future<void> toggleFavorite(int productId) async {
    await SupabaseService.toggleFavorite(productId: productId);
  }
}