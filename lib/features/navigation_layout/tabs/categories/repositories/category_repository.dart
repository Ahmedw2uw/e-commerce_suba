// lib/features/navigation_layout/tabs/categories/repositories/category_repository.dart

import 'package:e_commerce/core/models/category_model.dart';
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';

class CategoryRepository {
  Future<List<Category>> fetchCategories() async {
    return await SupabaseService.getCategories();
  }

  Future<List<Product>> fetchProductsByCategory(int categoryId) async {
    return await SupabaseService.getProductsByCategory(categoryId);
  }
}