// lib/features/products/data/datasources/products_remote_data_source.dart
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';

abstract class ProductsRemoteDataSource {
  Future<List<Product>> getProducts();
  Future<List<Product>> getProductsByCategory(int categoryId);
  Future<List<Product>> getFeaturedProducts();
  Future<Product> getProductById(int id);
  Future<List<Product>> searchProducts(String query);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImpl();

  @override
  Future<List<Product>> getProducts() async {
    return await SupabaseService.getAllProducts();
  }

  @override
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    return await SupabaseService.getProductsByCategory(categoryId);
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    return await SupabaseService.getFeaturedProducts();
  }

  @override
  Future<Product> getProductById(int id) async {
    return await SupabaseService.getProductById(id);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final result = await SupabaseService.getProducts(search: query);
      return result['products'] as List<Product>;
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}