// lib/features/navigation_layout/tabs/categories/repositories/category_repository.dart

import 'package:e_commerce/features/auth/models/category_model.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/model/product_model.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';

class CategoryRepository {
  Future<List<Category>> fetchCategories() async {
    return await SupabaseService.getCategories();
  }

  Future<List<Product>> fetchProductsByCategory(int categoryId) async {
    return await SupabaseService.getProductsByCategoryDirect(categoryId);
  }
}