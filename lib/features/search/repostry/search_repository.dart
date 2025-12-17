import 'package:e_commerce/features/auth/models/product_model.dart'; // ⬅️ صح

abstract class SearchRepository {
  Future<List<Product>> searchProducts(String query); // ⬅️ Product
}