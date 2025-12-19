// lib/features/products/data/repositories/products_repository_impl.dart
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/features/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl();

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
    final allProducts = await SupabaseService.getAllProducts();
    return allProducts.take(8).toList();
  }

  @override
  Future<Product> getProductById(int id) async {
    return await SupabaseService.getProductById(id);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final result = await SupabaseService.getProducts(search: query);
    return result['products'] as List<Product>;
  }
}
