import 'package:e_commerce/features/navigation_layout/tabs/home/model/product_model.dart'; // ⬅️ صح

abstract class SearchRepository {
  Future<List<Product>> searchProducts(String query); // ⬅️ Product
}