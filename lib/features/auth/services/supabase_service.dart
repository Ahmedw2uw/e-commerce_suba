import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce/features/auth/models/user_model.dart';
import 'package:e_commerce/features/auth/models/category_model.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Sign up a new account
  static Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await client.functions.invoke(
        'signup',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );
      print('SignUp Response Status: ${response.status}');
      print('SignUp Response Data: ${response.data}');
      if (response.status != 201) {
        final errorData = response.data;
        throw Exception(errorData['error'] ?? 'Sign up failed');
      }

      if (response.data == null) {
        throw Exception('No data received from server');
      }
      final userData = response.data['user'];

      return UserModel.fromJson(userData);
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      throw Exception(errorMessage);
    }
  }

  // Log in
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Login attempt for: $email');
      // final response = await _client.functions.invoke(
      //   'login',
      //   body: {'email': email, 'password': password},
      // );
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Login Response Status: ${response.user}');
      print('Login Response Data: ${response.session}');

      // if (response.status != 200) {
      //   final errorData = response.data;
      //   throw Exception(errorData['error'] ?? 'Login failed');
      // }

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      final userData = await client
          .from('customer')
          .select()
          .eq('auth_user_id', response.user!.id)
          .single();
      print('Customer data retrieved: $userData');

      // final sessionData = response.data['session'];
      // final userData = response.data['user'];
      // if (sessionData != null && sessionData['access_token'] != null) {
      //   try {
      //     await _client.auth.setSession(sessionData['access_token']);
      //     print('Session set successfully');
      //   } catch (e) {
      //     print('Error setting session: $e');
      //   }
      // }
      // print('Login successful for user: ${userData['name']}');
      return UserModel.fromJson(userData);
    } catch (e) {
      print('Login Error Details: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (e.toString().contains("Invalid login credentials")) {
        errorMessage = "Invalid email or password";
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = "Please confirm your email";
      }
      throw Exception(errorMessage);
    }
  }

  // Get Current User
  static Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = client.auth.currentUser;
      print('Current auth user: $authUser');
      if (authUser == null) {
        print('No authenticated user found');
        return null;
      }
      print('Fetching user data for auth ID: ${authUser.id}');
      final response = await client
          .from('customer')
          .select()
          .eq('auth_user_id', authUser.id)
          .single();
      print('User data fetched successfully: ${response['name']}');
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  static bool isLoggedIn() => client.auth.currentUser != null;

  static Future<String?> getUserRole() async {
    try {
      final user = await getCurrentUser();
      return user?.role;
    } catch (e) {
      return null;
    }
  }

  // Log out
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Failed to sign out');
    }
  }

  // Update User Profile
  static Future<UserModel> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }
      // Update user profile
      final response = await client
          .from('customer')
          .update({'name': name, 'phone': phone})
          .eq('auth_user_id', authUser.id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  static Future<void> changePassword({required String newPassword}) async {
    try {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  static Future<void> changeEmail({required String newEmail}) async {
    try {
      await client.auth.updateUser(UserAttributes(email: newEmail));
    } catch (e) {
      throw Exception('Failed to change email: $e');
    }
  }

  static Future<List<Category>> getCategories() async {
    try {
      final response = await client.functions.invoke('get_categories');
      print('Categories Response Status: ${response.status}');
      print('Categories Response Data: ${response.data}');
      if (response.status != 200) {
        throw Exception('Failed to load categories: ${response.status}');
      }
      final data = response.data;
      if (data['success'] == true) {
        final categoriesList = data['categories'] as List;
        return categoriesList
            .map((category) => Category.fromJson(category))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  static String? getCategoryImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    // إذا كان رابط كامل
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // إذا كان اسم ملف فقط، نبني الرابط الكامل
    // استبدل YOUR_PROJECT_ID بالمعرف الفعلي
    const baseStorageUrl =
        'https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/';
    const bucketName = 'products_images'; // ← هذا اسم bucket الذي رأيته

    return '$baseStorageUrl$bucketName/$imagePath';
  }

  // يمكنك إضافة هذا للتحقق
  static Future<void> testCategoryImage() async {
    try {
      final categories = await getCategories();
      if (categories.isNotEmpty) {
        final first = categories.first;
        print('Category: ${first.name}');
        print('Image field: ${first.image}');
        print('Full URL: ${getCategoryImageUrl(first.image)}');
      }
    } catch (e) {
      print('Test error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getHomeAppliances() async {
    try {
      // استخدم الـ Edge Function المباشر
      final response = await client
          .from('product')
          .select('id, name, images, price, category_id')
          .eq('category_id', 13) // فئة Home
          .limit(4)
          .order('created_at', ascending: false);

      print('📡 Home Appliances: ${response.length} items');

      // التحويل الصحيح
      final products = response as List<dynamic>;
      return products.map((item) {
        return {
          'id': item['id'],
          'name': item['name'],
          'image': item['images'] != null && item['images'].isNotEmpty
              ? item['images'][0]
              : null,
          'price': item['price'],
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting home appliances: $e');
      return [];
    }
  }

  // في SupabaseService أضف:
  //!------------------------------------------
  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await client.functions.invoke('get_all_products');

      print('All Products Response Status: ${response.status}');
      print('All Products Response Data: ${response.data}');

      if (response.status != 200) {
        throw Exception('Failed to load all products: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        final productsList = data['products'] as List;
        return productsList
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error fetching all products: $e');

      // بديل: جلب منتجات من كل التصنيفات
      final categories = await getCategories();
      List<Product> allProducts = [];

      for (var category in categories) {
        try {
          final products = await getProductsByCategory(category.id);
          allProducts.addAll(products);
        } catch (e) {
          print('Error fetching products for category ${category.id}: $e');
        }
      }

      return allProducts;
    }
  }

  // 2. جلب المنتجات المميزة (بدون Edge Function)
  static Future<List<Product>> getAllProductsDirect() async {
    try {
      print('📡 Direct: Getting all products');
      final response =
          await client // ← هنا كان فيه نقطتين زائد
              .from('product')
              .select('''
          *,
          category(*)
        ''')
              .order('created_at', ascending: false);

      // إصلاح التحويل
      return response.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      print('❌ getAllProductsDirect error: $e');
      return []; // أرجع قائمة فارغة بدلاً من throw
    }
  }

  static Future<List<Product>> getFeaturedProductsDirect() async {
    try {
      print('📡 Direct: Getting featured products');
      final response = await client
          .from('product')
          .select('''
      *,
      category(*)
    ''')
          .eq('featured', true);

      if (response.isEmpty) {
        print('⚠️ No featured products, returning first 3');
        final all = await getAllProductsDirect();
        return all.take(3).toList();
      }

      return (response as List).map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      print('❌ getFeaturedProductsDirect error: $e');
      return []; // أرجع قائمة فارغة
    }
  }

  static Future<List<Product>> getProductsByCategoryDirect(
    int categoryId,
  ) async {
    try {
      print('📡 Direct: Products for category $categoryId');
      final response = await client
          .from('product')
          .select('''
      *,
      category(*)
    ''')
          .eq('category_id', categoryId);

      return (response as List).map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      print('❌ getProductsByCategoryDirect error: $e');
      return []; // أرجع قائمة فارغة
    }
  }

  // Using ID
  static Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await client.functions.invoke(
        'get_products_by_category',
        body: {'category_id': categoryId},
      );

      print('Products Response Status: ${response.status}');
      print('Products Response Data: ${response.data}');

      if (response.status != 200) {
        throw Exception('Failed to load products: ${response.status}');
      }
      final data = response.data;
      if (data['success'] == true) {
        final productsList = data['products'] as List;
        return productsList
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  //Using Name
  static Future<List<Product>> getProductsByCategoryName(
    String categoryName,
  ) async {
    try {
      final response = await client.functions.invoke(
        'get_products_by_category',
        body: {'category_name': categoryName},
      );

      print('Products Response Status: ${response.status}');
      print('Products Response Data: ${response.data}');

      if (response.status != 200) {
        throw Exception('Failed to load products: ${response.status}');
      }
      final data = response.data;
      if (data['success'] == true) {
        final productsList = data['products'] as List;
        return productsList
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  static Future<List<Address>> getUserAddresses() async {
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }

      final response = await client
          .from('addresses')
          .select()
          .eq('customer_auth_id', authUser.id)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      final addressesList = response as List;
      return addressesList.map((address) => Address.fromJson(address)).toList();
    } catch (e) {
      print('Error getting user addresses: $e');
      throw Exception('Failed to get addresses: $e');
    }
  }

  static Future<Address> addAddress({
    required String street,
    required String city,
    required String state,
    required String zipCode,
    String country = 'Egypt',
    bool isDefault = false,
  }) async {
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }

      if (isDefault) {
        await client
            .from('addresses')
            .update({'is_default': false})
            .eq('customer_auth_id', authUser.id);
      }

      final response = await client
          .from('addresses')
          .insert({
            'customer_auth_id': authUser.id,
            'street': street,
            'city': city,
            'state': state,
            'zip_code': zipCode,
            'country': country,
            'is_default': isDefault,
          })
          .select()
          .single();

      return Address.fromJson(response);
    } catch (e) {
      print('Error adding address: $e');
      throw Exception('Failed to add address: $e');
    }
  }

  static Future<Address> updateAddress({
    required int addressId,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) async {
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }

      final updateData = <String, dynamic>{};
      if (street != null) updateData['street'] = street;
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (zipCode != null) updateData['zip_code'] = zipCode;
      if (country != null) updateData['country'] = country;
      if (isDefault != null) updateData['is_default'] = isDefault;

      if (isDefault == true) {
        await client
            .from('addresses')
            .update({'is_default': false})
            .eq('customer_auth_id', authUser.id)
            .neq('id', addressId);
      }

      final response = await client
          .from('addresses')
          .update(updateData)
          .eq('id', addressId)
          .eq('customer_auth_id', authUser.id)
          .select()
          .single();

      return Address.fromJson(response);
    } catch (e) {
      print('Error updating address: $e');
      throw Exception('Failed to update address: $e');
    }
  }

  static Future<void> deleteAddress(int addressId) async {
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }

      await client
          .from('addresses')
          .delete()
          .eq('id', addressId)
          .eq('customer_auth_id', authUser.id);
    } catch (e) {
      print('Error deleting address: $e');
      throw Exception('Failed to delete address: $e');
    }
  }

  static Future<Address> setDefaultAddress(int addressId) async {
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }

      await client
          .from('addresses')
          .update({'is_default': false})
          .eq('customer_auth_id', authUser.id);

      final response = await client
          .from('addresses')
          .update({'is_default': true})
          .eq('id', addressId)
          .eq('customer_auth_id', authUser.id)
          .select()
          .single();

      return Address.fromJson(response);
    } catch (e) {
      print('Error setting default address: $e');
      throw Exception('Failed to set default address: $e');
    }
  }
  // أضف هذه الدوال في نهاية ملف SupabaseService

// 1. إضافة/إزالة منتج من المفضلة
static Future<void> toggleFavorite(int productId) async {
  try {
    final authUser = client.auth.currentUser;
    if (authUser == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    // التحقق إذا المنتج موجود بالفعل في المفضلة
    final existing = await client
        .from('favorites')
        .select()
        .eq('customer_auth_id', authUser.id)
        .eq('product_id', productId);

    if (existing.isEmpty) {
      // إضافة إلى المفضلة
      await client.from('favorites').insert({
        'customer_auth_id': authUser.id,
        'product_id': productId,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('✅ تم إضافة المنتج $productId إلى المفضلة');
    } else {
      // إزالة من المفضلة
      await client
          .from('favorites')
          .delete()
          .eq('customer_auth_id', authUser.id)
          .eq('product_id', productId);
      print('❌ تم إزالة المنتج $productId من المفضلة');
    }
  } catch (e) {
    print('❌ خطأ في toggleFavorite: $e');
    throw Exception('فشل تحديث المفضلة: $e');
  }
}

// 2. جلب جميع المنتجات المفضلة للمستخدم
static Future<List<Product>> getFavoriteProducts() async {
  try {
    final authUser = client.auth.currentUser;
    if (authUser == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    final response = await client
        .from('favorites')
        .select('''
          product:product_id (*, category(*))
        ''')
        .eq('customer_auth_id', authUser.id)
        .order('created_at', ascending: false);

    // استخراج المنتجات من الاستجابة
    final favorites = response as List;
    return favorites
        .map((fav) => Product.fromJson(fav['product']))
        .toList();
  } catch (e) {
    print('❌ خطأ في getFavoriteProducts: $e');
    throw Exception('فشل جلب المنتجات المفضلة: $e');
  }
}

// 3. التحقق إذا منتج معين في المفضلة
static Future<bool> isProductFavorite(int productId) async {
  try {
    final authUser = client.auth.currentUser;
    if (authUser == null) return false;

    final response = await client
        .from('favorites')
        .select()
        .eq('customer_auth_id', authUser.id)
        .eq('product_id', productId);

    return response.isNotEmpty;
  } catch (e) {
    print('❌ خطأ في isProductFavorite: $e');
    return false;
  }
}
}
