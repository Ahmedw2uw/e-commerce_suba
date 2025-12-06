// lib/features/products/data/repositories/products_repository_impl.dart
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/features/products/data/datasource/products_remote_data_source.dart';
import 'package:e_commerce/features/products/domain/repositories/products_repository.dart';
class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts() async {
    return await remoteDataSource.getProducts();
  }

  @override
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    return await remoteDataSource.getProductsByCategory(categoryId);
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    return await remoteDataSource.getFeaturedProducts();
  }

  @override
  Future<Product> getProductById(int id) async {
    return await remoteDataSource.getProductById(id);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return await remoteDataSource.searchProducts(query);
  }
}
