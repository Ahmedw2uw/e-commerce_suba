// lib/features/products/domain/repositories/products_repository.dart
import 'package:e_commerce/core/models/product_model.dart';

abstract class ProductsRepository {
  Future<List<Product>> getProducts();
  Future<List<Product>> getProductsByCategory(int categoryId);
  Future<List<Product>> getFeaturedProducts();
  Future<Product> getProductById(int id);
  Future<List<Product>> searchProducts(String query);
}