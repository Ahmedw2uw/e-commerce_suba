// lib/features/products/data/datasources/products_remote_data_source.dart
import 'package:e_commerce/features/navigation_layout/tabs/home/model/product_model.dart';
import 'package:e_commerce/features/cart/data/models/cart_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProductsRemoteDataSource {
  Future<List<Product>> getProducts();
  Future<List<Product>> getProductsByCategory(int categoryId);
  Future<List<Product>> getFeaturedProducts();
  Future<Product> getProductById(int id);
  Future<List<Product>> searchProducts(String query);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProductsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await supabaseClient
          .from('product')
          .select('''
            *,
            category:category(*)
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await supabaseClient
          .from('product')
          .select('''
            *,
            category:category(*)
          ''')
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }
// في cart_remote_data_source.dart
@override
Future<List<CartItemModel>> getCartItems() async {
  try {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await supabaseClient
        .from('cart') // ← غير من cart_items إلى cart
        .select('''
          *,
          product:product(*)
        ''')
        .eq('customer_auth_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => CartItemModel.fromJson(item))
        .toList();
  } catch (e) {
    throw Exception('Failed to get cart items: $e');
  }
}

@override
Future<void> addToCart({
  required Product product,
  required int quantity,
}) async {
  try {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // تحقق إذا المنتج موجود بالفعل في السلة
    final existingItem = await supabaseClient
        .from('cart')
        .select()
        .eq('customer_auth_id', user.id)
        .eq('item_id', product.id)
        .maybeSingle();

    if (existingItem != null) {
      // تحديث الكمية إذا موجود
      final newQuantity = (existingItem['quantity'] as int) + quantity;
      await supabaseClient
          .from('cart')
          .update({'quantity': newQuantity})
          .eq('id', existingItem['id']);
    } else {
      // إضافة جديد
      await supabaseClient.from('cart').insert({
        'customer_auth_id': user.id,
        'item_id': product.id,
        'quantity': quantity,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  } catch (e) {
    throw Exception('Failed to add to cart: $e');
  }
}
  @override
Future<List<Product>> getFeaturedProducts() async {
  try {
    final response = await supabaseClient
        .from('product')
        .select('''
          *,
          category:category(*)
        ''')
        // استبدل is_featured بـ ORDER BY rating أو created_at
        .order('created_at', ascending: false)
        .limit(8); // ← جلب آخر 8 منتجات كمميزة

    return (response as List)
        .map((item) => Product.fromJson(item))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch featured products: $e');
  }
}
  @override
  Future<Product> getProductById(int id) async {
    try {
      final response = await supabaseClient
          .from('product')
          .select('''
            *,
            category:category(*)
          ''')
          .eq('id', id)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch product by id: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await supabaseClient
          .from('product')
          .select('''
            *,
            category:category(*)
          ''')
          .ilike('name', '%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}