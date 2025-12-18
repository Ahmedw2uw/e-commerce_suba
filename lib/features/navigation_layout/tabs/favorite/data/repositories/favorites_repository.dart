// lib/features/favorites/data/repositories/favorites_repository.dart
import 'package:e_commerce/features/navigation_layout/tabs/home/model/product_model.dart';
import 'package:e_commerce/features/navigation_layout/tabs/favorite/data/datasource/favorites_remote_data_source.dart';

abstract class FavoritesRepository {
  Future<List<Product>> getFavoriteProducts();
  Future<void> addToFavorites(int productId);
  Future<void> removeFromFavorites(int productId);
  Future<bool> isProductFavorite(int productId);
  Future<void> toggleFavorite(int productId);
}

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _remoteDataSource;

  FavoritesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Product>> getFavoriteProducts() {
    return _remoteDataSource.getFavoriteProducts();
  }

  @override
  Future<void> addToFavorites(int productId) {
    return _remoteDataSource.addToFavorites(productId);
  }

  @override
  Future<void> removeFromFavorites(int productId) {
    return _remoteDataSource.removeFromFavorites(productId);
  }

  @override
  Future<bool> isProductFavorite(int productId) {
    return _remoteDataSource.isProductFavorite(productId);
  }

  @override
  Future<void> toggleFavorite(int productId) async {
    final isFavorite = await isProductFavorite(productId);
    
    if (isFavorite) {
      await removeFromFavorites(productId);
    } else {
      await addToFavorites(productId);
    }
  }
}