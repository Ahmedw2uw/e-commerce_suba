import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/core/models/product_model.dart';
abstract class FavoritesRemoteDataSource {
  Future<List<Product>> getFavoriteProducts();
  Future<void> addToFavorites(int productId);
  Future<void> removeFromFavorites(int productId);
  Future<bool> isProductFavorite(int productId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  FavoritesRemoteDataSourceImpl();

  @override
  Future<List<Product>> getFavoriteProducts() async {
    return await SupabaseService.getFavoriteProducts();
  }

  @override
  Future<void> addToFavorites(int productId) async {
    await SupabaseService.addToFavorites(productId);
  }

  @override
  Future<void> removeFromFavorites(int productId) async {
    await SupabaseService.removeFromFavorites(productId);
  }

  @override
  Future<bool> isProductFavorite(int productId) async {
    return await SupabaseService.isProductFavorite(productId);
  }
}