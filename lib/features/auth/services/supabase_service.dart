import 'package:e_commerce/features/auth/models/address_model.dart';
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce/features/auth/models/user_model.dart';
import 'package:e_commerce/features/auth/models/category_model.dart';
import 'package:e_commerce/features/auth/models/cart_model.dart';
import 'package:e_commerce/features/auth/models/order_model.dart';
import 'package:e_commerce/features/auth/models/order_item_model.dart';
import 'package:e_commerce/features/auth/models/reviews_model.dart';
import 'package:e_commerce/features/auth/models/wishlist_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // =================================================================================================
  // AUTHENTICATION & USER MANAGEMENT
  // =================================================================================================

  /// Sign up a new account
  static Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _client.functions.invoke(
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

  /// Log in
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Login attempt for: $email');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Login Response Status: ${response.user}');
      print('Login Response Data: ${response.session}');

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      final userData = await _client
          .from('customer')
          .select()
          .eq('auth_user_id', response.user!.id)
          .single();
      print('Customer data retrieved: $userData');

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

  /// Get Current User
  static Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = _client.auth.currentUser;
      print('Current auth user: $authUser');
      if (authUser == null) {
        print('No authenticated user found');
        return null;
      }
      print('Fetching user data for auth ID: ${authUser.id}');
      final response = await _client
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

  /// Check if user is logged in
  static bool isLoggedIn() => _client.auth.currentUser != null;

  /// Get user role
  static Future<String?> getUserRole() async {
    try {
      final user = await getCurrentUser();
      return user?.role;
    } catch (e) {
      return null;
    }
  }

  /// Log out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Failed to sign out');
    }
  }

  /// Update User Profile
  static Future<UserModel> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }
      final response = await _client
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

  /// Change password
  static Future<void> changePassword({required String newPassword}) async {
    try {
      final response = await _client.functions.invoke(
        'change_password',
        body: {
          'new_password': newPassword,
        },
      );
      if (response.status != 200) {
        throw Exception('Failed to change password: ${response.status}');
      }
      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  /// Change email
  static Future<void> changeEmail({
  required String newEmail,
  required String currentPassword,
}) async {
  try {
    if (newEmail.trim().isEmpty) {
      throw Exception('New email is required');
    }
    if (currentPassword.isEmpty) {
      throw Exception('Current password is required for verification');
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+');
    if (!emailRegex.hasMatch(newEmail.trim())) {
      throw Exception('Please enter a valid email address');
    }
    final response = await _client.functions.invoke(
      'change_email',
      body: {
        'new_email': newEmail.trim(),
        'current_password': currentPassword,
      },
    );
    print('Change Email Response Status: ${response.status}');
    print('Change Email Response Data: ${response.data}');
    if (response.status != 200) {
      final data = response.data;
      String errorMsg = data['error'] ?? 'Failed to change email';
      throw Exception(errorMsg);
    }
    final data = response.data;
    if (data['success'] != true) {
      String errorMsg = data['error'] ?? 'Unknown error occurred';
      throw Exception(errorMsg);
    }
    print('Email change successful: ${data['message']}');
  } catch (e) {
    // Clean up error message for user display
    String errorMessage = e.toString().replaceAll('Exception: ', '');
    throw Exception(errorMessage);
  }
}
  // =================================================================================================
  // CATEGORIES
  // =================================================================================================

  /// Get all categories
  static Future<List<Category>> getCategories() async {
    try {
      final response = await _client.functions.invoke('get_categories');
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

  // =================================================================================================
  // PRODUCTS
  // =================================================================================================

  /// Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await _client.functions.invoke('get_all_products');

      if (response.data['success'] == true) {
        final products = (response.data['products'] as List)
            .map((p) => Product.fromJson(p))
            .toList();
        print('Loaded ${response.data['total']} products');
        return products;
      }
      throw Exception('Failed to fetch products');
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Get product by ID with full details
  static Future<Product> getProductById(int productId) async {
    try {
      final response = await _client.functions.invoke(
        'get_product_by_id',
        body: {'product_id': productId},
      );

      if (response.status != 200) {
        throw Exception('Failed to load product: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        return Product.fromJson(data['product']);
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  /// Get products with filters
  static Future<List<Product>> getProducts({
    int? categoryId,
    String? categoryName,
    String? search,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'get-products',
        body: {
          if (categoryId != null) "category_id": categoryId,
          if (categoryName != null) "category_name": categoryName,
          if (search != null) "search": search,
          if (minPrice != null) "min_price": minPrice,
          if (maxPrice != null) "max_price": maxPrice,
          "limit": limit,
          "offset": offset,
        },
      );

      final data = response.data;

      if (data == null || data['success'] != true) {
        throw Exception(data?['error'] ?? 'Failed to fetch products');
      }
      final List productsJson = data['products'] ?? [];
      return productsJson.map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      throw Exception('Get products error: $e');
    }
  }

  /// Get products by category ID
  static Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _client.functions.invoke(
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

  /// Get products by category name
  static Future<List<Product>> getProductsByCategoryName(
    String categoryName,
  ) async {
    try {
      final response = await _client.functions.invoke(
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

  // =================================================================================================
  // REVIEWS
  // =================================================================================================

  /// Get product reviews with average rating
  static Future<Map<String, dynamic>> getProductReviews(int productId) async {
    try {
      final response = await _client.functions.invoke(
        'get_product_reviews',
        body: {'product_id': productId},
      );

      if (response.status != 200) {
        throw Exception('Failed to load reviews: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        final reviewsList = data['reviews'] as List;
        final reviews = reviewsList.map((r) => Review.fromJson(r)).toList();
        return {
          'reviews': reviews,
          'average_rating': double.tryParse(data['average_rating'].toString()) ?? 0.0,
          'total_reviews': data['total_reviews'] as int,
        };
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  /// Add a review for a product
  static Future<Review> addReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      final response = await _client.functions.invoke(
        'add_review',
        body: {
          'product_id': productId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );

      if (response.status != 201) {
        throw Exception('Failed to add review: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        return Review.fromJson(data['review']);
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // =================================================================================================
  // CART MANAGEMENT
  // =================================================================================================

  /// Add product to cart or update quantity if exists
  static Future<void> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      if (quantity <= 0) {
        throw Exception('Quantity must be greater than 0');
      }

      final response = await _client.functions.invoke(
        'add_to_cart',
        body: {
          'product_id': productId,
          'quantity': quantity,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to add to cart: ${response.status}');
      }

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  /// Get user's cart with product details and total
  static Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _client.functions.invoke('get_cart');

      if (response.status != 200) {
        throw Exception('Failed to load cart: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        final cartList = data['cart'] as List;
        final cartItems = <Map<String, dynamic>>[];
        
        for (var item in cartList) {
          cartItems.add({
            'id': item['id'],
            'quantity': item['quantity'],
            'item_total': item['item_total'],
            'created_at': item['created_at'],
            'updated_at': item['updated_at'],
            'product': Product.fromJson(item['product']),
          });
        }
        
        return {
          'cart': cartItems,
          'total': (data['total'] as num).toDouble(),
        };
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  /// Update cart item quantity (set to 0 to remove)
  static Future<void> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity < 0) {
        throw Exception('Quantity cannot be negative');
      }

      final response = await _client.functions.invoke(
        'update_cart_item',
        body: {
          'cart_item_id': cartItemId,
          'quantity': quantity,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to update cart: ${response.status}');
      }

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  /// Remove item from cart (alias for updateCartItem with quantity 0)
  static Future<void> removeFromCart(int cartItemId) async {
    return updateCartItem(cartItemId: cartItemId, quantity: 0);
  }

  /// Clear entire cart
  static Future<void> clearCart() async {
    try {
      final cartData = await getCart();
      final cart = cartData['cart'] as List<Map<String, dynamic>>;
      
      for (var item in cart) {
        await removeFromCart(item['id'] as int);
      }
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // =================================================================================================
  // ORDERS & CHECKOUT
  // =================================================================================================

  /// Create order from cart items
  static Future<Order> createOrder({
    required int addressId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'create_order',
        body: {
          'address_id': addressId,
        },
      );

      if (response.status != 201) {
        throw Exception('Failed to create order: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        return Order.fromJson(data['order']);
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get all user orders
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final response = await _client.functions.invoke('get_user_orders');

      if (response.status != 200) {
        throw Exception('Failed to load orders: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        final ordersList = data['orders'] as List;
        return ordersList.map((order) {
          return {
            'order': Order.fromJson(order),
            'address': order['address'] != null ? Address.fromJson(order['address']) : null,
          };
        }).toList();
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Get detailed order information with items
  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final response = await _client.functions.invoke(
        'get_order_details',
        body: {'order_id': orderId},
      );

      if (response.status != 200) {
        throw Exception('Failed to load order details: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        final orderData = data['order'];
        
        // Parse order items with product details
        final itemsList = orderData['items'] as List;
        final items = itemsList.map((item) {
          return {
            'quantity': item['quantity'],
            'price_per_unit': (item['price_per_unit'] as num).toDouble(),
            'product': Product.fromJson(item['product']),
          };
        }).toList();

        return {
          'order': Order.fromJson(orderData),
          'address': orderData['address'] != null 
              ? Address.fromJson(orderData['address']) 
              : null,
          'items': items,
        };
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  // =================================================================================================
  // ADDRESSES
  // =================================================================================================

  /// Get all user addresses
  static Future<List<Address>> getUserAddresses() async {
    try {
      final response = await _client.functions.invoke('get_user_addresses');

      if (response.status != 200) {
        throw Exception('Failed to get addresses: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        final addressesList = data['addresses'] as List;
        return addressesList.map((address) => Address.fromJson(address)).toList();
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error getting user addresses: $e');
      throw Exception('Failed to get addresses: $e');
    }
  }

  /// Add new address
  static Future<Address> addAddress({
    required String street,
    required String city,
    required String state,
    required String zipCode,
    String country = 'Egypt',
    bool isDefault = false,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'add_address',
        body: {
          'street': street,
          'city': city,
          'state': state,
          'zip_code': zipCode,
          'country': country,
          'is_default': isDefault,
        },
      );

      if (response.status != 201) {
        throw Exception('Failed to add address: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        return Address.fromJson(data['address']);
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error adding address: $e');
      throw Exception('Failed to add address: $e');
    }
  }

  /// Update existing address
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
      final body = <String, dynamic>{
        'address_id': addressId,
      };
      if (street != null) body['street'] = street;
      if (city != null) body['city'] = city;
      if (state != null) body['state'] = state;
      if (zipCode != null) body['zip_code'] = zipCode;
      if (country != null) body['country'] = country;
      if (isDefault != null) body['is_default'] = isDefault;

      final response = await _client.functions.invoke('update_address', body: body);

      if (response.status != 200) {
        throw Exception('Failed to update address: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        return Address.fromJson(data['address']);
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error updating address: $e');
      throw Exception('Failed to update address: $e');
    }
  }

  /// Delete address
  static Future<void> deleteAddress(int addressId) async {
    try {
      final response = await _client.functions.invoke(
        'delete_address',
        body: {
          'address_id': addressId,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to delete address: ${response.status}');
      }

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error deleting address: $e');
      throw Exception('Failed to delete address: $e');
    }
  }

  /// Set default address
  static Future<Address> setDefaultAddress(int addressId) async {
    try {
      final response = await _client.functions.invoke(
        'set_default_address',
        body: {
          'address_id': addressId,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to set default address: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        return Address.fromJson(data['address']);
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error setting default address: $e');
      throw Exception('Failed to set default address: $e');
    }
  }

  // =================================================================================================
  // WISHLIST / FAVORITES
  // =================================================================================================

  /// Get all favorite products
  static Future<List<Product>> getFavoriteProducts() async {
    try {
      final response = await _client.functions.invoke('get_favorite_products');

      if (response.status != 200) {
        throw Exception('Failed to get favorite products: ${response.status}');
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
      print('Error getting favorite products: $e');
      throw Exception('Failed to get favorite products: $e');
    }
  }

  /// Toggle product favorite status (add/remove)
  static Future<Map<String, dynamic>> toggleFavorite({
    required int productId,
    String? action,
  }) async {
    try {
      final response = await _client.functions.invoke('toggle_favorite', 
      body: {
        'product_id': productId,
        if (action != null) 'action': action,
      });

      if (response.status != 200) {
        throw Exception('Failed to toggle favorite: ${response.status}');
      }

      final data = response.data;
      if (data['success'] == true) {
        return {
          'success': true,
          'is_favorite': data['is_favorite'],
          'message': data['message'],
        };
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Check if product is in favorites
  static Future<bool> isProductFavorite(int productId) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) return false;

      final response = await _client
          .from('wishlist')
          .select('id')
          .eq('customer_auth_id', authUser.id)
          .eq('product_id', productId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  /// Add product to favorites
  static Future<void> addToFavorites(int productId) async {
    return toggleFavorite(productId: productId, action: 'add').then((_) {});
  }

  /// Remove product from favorites
  static Future<void> removeFromFavorites(int productId) async {
    return toggleFavorite(productId: productId, action: 'remove').then((_) {});
  }
}