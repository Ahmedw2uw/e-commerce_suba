import 'package:e_commerce/core/models/product_model.dart';

abstract class SearchRepository {
  Future<List<Product>> searchProducts(String query); // ⬅️ Product
}