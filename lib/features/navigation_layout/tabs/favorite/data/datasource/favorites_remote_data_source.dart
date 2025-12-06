// lib/features/favorites/data/datasources/favorites_remote_data_source.dart
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<Product>> getFavoriteProducts();
  Future<void> addToFavorites(int productId);
  Future<void> removeFromFavorites(int productId);
  Future<bool> isProductFavorite(int productId);
}
class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final SupabaseClient _client;

  FavoritesRemoteDataSourceImpl() : _client = Supabase.instance.client;

  @override
  Future<List<Product>> getFavoriteProducts() async {
    try {
      print('🔄 [getFavoriteProducts] بدء جلب المفضلة');
      
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        print('❌ [getFavoriteProducts] لا يوجد مستخدم مسجل دخول');
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      print('👤 [getFavoriteProducts] المستخدم: ${authUser.id}');
      
      final response = await _client
          .from('favorites')
          .select('''
            product:product_id (*, category(*))
          ''')
          .eq('customer_auth_id', authUser.id)
          .order('created_at', ascending: false);

      print('📦 [getFavoriteProducts] عدد المنتجات: ${response.length}');
      print('📦 [getFavoriteProducts] البيانات: $response');

      final favorites = response as List;
      final products = favorites
          .map((fav) => Product.fromJson(fav['product']))
          .toList();
      
      print('✅ [getFavoriteProducts] تم التحويل: ${products.length} منتج');
      
      return products;
    } catch (e) {
      print('❌ [getFavoriteProducts] خطأ: $e');
      print('❌ [getFavoriteProducts] StackTrace: ${e.toString()}');
      throw Exception('فشل جلب المنتجات المفضلة: $e');
    }
  }

  @override
  Future<void> addToFavorites(int productId) async {
    try {
      print('➕ [addToFavorites] بدء إضافة المنتج $productId');
      
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        print('❌ [addToFavorites] لا يوجد مستخدم مسجل دخول');
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      print('👤 [addToFavorites] المستخدم: ${authUser.id}');
      print('🆔 [addToFavorites] المنتج: $productId');

      await _client.from('favorites').insert({
        'customer_auth_id': authUser.id,
        'product_id': productId,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ [addToFavorites] تم الإضافة بنجاح');
    } catch (e) {
      print('❌ [addToFavorites] خطأ: $e');
      print('❌ [addToFavorites] StackTrace: ${e.toString()}');
      throw Exception('فشل إضافة المنتج للمفضلة: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(int productId) async {
    try {
      print('➖ [removeFromFavorites] بدء إزالة المنتج $productId');
      
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        print('❌ [removeFromFavorites] لا يوجد مستخدم مسجل دخول');
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      print('👤 [removeFromFavorites] المستخدم: ${authUser.id}');
      print('🆔 [removeFromFavorites] المنتج: $productId');

      final result = await _client
          .from('favorites')
          .delete()
          .eq('customer_auth_id', authUser.id)
          .eq('product_id', productId);

      print('✅ [removeFromFavorites] تم الحذف: $result');
    } catch (e) {
      print('❌ [removeFromFavorites] خطأ: $e');
      print('❌ [removeFromFavorites] StackTrace: ${e.toString()}');
      throw Exception('فشل إزالة المنتج من المفضلة: $e');
    }
  }

  @override
  Future<bool> isProductFavorite(int productId) async {
    try {
      print('❓ [isProductFavorite] التحقق من المنتج $productId');
      
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        print('⚠️ [isProductFavorite] لا يوجد مستخدم مسجل دخول');
        return false;
      }

      final response = await _client
          .from('favorites')
          .select()
          .eq('customer_auth_id', authUser.id)
          .eq('product_id', productId);

      final isFavorite = response.isNotEmpty;
      print('✅ [isProductFavorite] النتيجة: $isFavorite');
      
      return isFavorite;
    } catch (e) {
      print('❌ [isProductFavorite] خطأ: $e');
      return false;
    }
  }
}