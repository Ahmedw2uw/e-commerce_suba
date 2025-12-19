import 'package:e_commerce/core/models/address_model.dart';
import 'package:e_commerce/core/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce/core/models/user_model.dart' hide Address;
import 'package:e_commerce/core/models/category_model.dart';
import 'package:e_commerce/core/models/order_model.dart';
import 'package:e_commerce/core/models/reviews_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ==================== AUTHENTICATION ====================
  
  /// Register new user
  static Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'signup',
        method: HttpMethod.post,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );
      
      if (response.status != 201) {
        throw Exception(response.data['error'] ?? 'Registration failed');
      }
      
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// User login
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Login failed');
      }
      
      final userData = await _client
          .from('customer')
          .select()
          .eq('auth_user_id', response.user!.id)
          .single();
      
      return UserModel.fromJson(userData);
    } catch (e) {
      String error = e.toString().replaceAll('Exception: ', '');
      if (e.toString().contains("Invalid login credentials")) {
        error = "Invalid email or password";
      } else if (e.toString().contains('Email not confirmed')) {
        error = "Please confirm your email";
      }
      throw Exception(error);
    }
  }

  /// Get current user
  static Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) return null;
      
      final response = await _client
          .from('customer')
          .select()
          .eq('auth_user_id', authUser.id)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  static bool isLoggedIn() => _client.auth.currentUser != null;

  /// Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Update profile
  static Future<UserModel> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        throw Exception('User not logged in');
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
        method: HttpMethod.post,
        body: {'new_password': newPassword},
      );
      
      if (response.status != 200) {
        throw Exception('Failed to change password');
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
      final response = await _client.functions.invoke(
        'change_email',
        method: HttpMethod.post,
        body: {
          'new_email': newEmail.trim(),
          'current_password': currentPassword,
        },
      );
      
      if (response.status != 200) {
        final data = response.data;
        String errorMsg = data['error'] ?? 'Failed to change email';
        throw Exception(errorMsg);
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      throw Exception(errorMessage);
    }
  }

  // ==================== CATEGORIES ====================
  
  /// Get all categories
  static Future<List<Category>> getCategories() async {
    try {
      final response = await _client.functions.invoke(
        'get_categories',
        method: HttpMethod.get,
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load categories');
      }
      
      return (response.data['categories'] as List)
          .map((c) => Category.fromJson(c))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // ==================== PRODUCTS ====================
  
  /// Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await _client.functions.invoke(
        'get_all_products',
        method: HttpMethod.get,
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load products');
      }
      
      return (response.data['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Get featured products
  static Future<List<Product>> getFeaturedProducts({int limit = 8}) async {
    try {
      // For now, we fetch products ordered by created_at as featured
      final response = await _client
          .from('product')
          .select('*, category:category(*)')
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((p) => Product.fromJson(p))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  /// Get product by ID
  static Future<Product> getProductById(int productId) async {
    try {
      final response = await _client.functions.invoke(
        'get_product_by_id',
        method: HttpMethod.post,
        body: {'product_id': productId},
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load product');
      }
      
      return Product.fromJson(response.data['product']);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  /// Get products with filters
  static Future<Map<String, dynamic>> getProducts({
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
        method: HttpMethod.post,
        body: {
          if (categoryId != null) 'category_id': categoryId,
          if (categoryName != null) 'category_name': categoryName,
          if (search != null) 'search': search,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
          'limit': limit,
          'offset': offset,
        },
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load products');
      }
      
      return {
        'products': (response.data['products'] as List)
            .map((p) => Product.fromJson(p))
            .toList(),
        'total': response.data['total'],
        'limit': response.data['limit'],
        'offset': response.data['offset'],
      };
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Get products by category ID
  static Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _client.functions.invoke(
        'get_products_by_category',
        method: HttpMethod.post,
        body: {'category_id': categoryId},
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load products');
      }
      
      return (response.data['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Get products by category name
  static Future<List<Product>> getProductsByCategoryName(String categoryName) async {
    try {
      final response = await _client.functions.invoke(
        'get_products_by_category',
        method: HttpMethod.post,
        body: {'category_name': categoryName},
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load products');
      }
      
      return (response.data['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // ==================== REVIEWS ====================
  
  /// Get product reviews
  static Future<Map<String, dynamic>> getProductReviews(int productId) async {
    try {
      final response = await _client.functions.invoke(
        'get_product_reviews',
        method: HttpMethod.post,
        body: {'product_id': productId},
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load reviews');
      }
      
      final reviewsList = response.data['reviews'] as List;
      final reviews = reviewsList.map((r) => Review.fromJson(r)).toList();
      
      return {
        'reviews': reviews,
        'average_rating': double.tryParse(response.data['average_rating'].toString()) ?? 0.0,
        'total_reviews': response.data['total_reviews'],
      };
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  /// Add product review
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
        method: HttpMethod.post,
        body: {
          'product_id': productId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      
      if (response.status != 201) {
        throw Exception('Failed to add review');
      }
      
      return Review.fromJson(response.data['review']);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // ==================== CART ====================
  
  /// Add product to cart
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
        method: HttpMethod.post,
        body: {
          'product_id': productId,
          'quantity': quantity,
        },
      );
      
      if (response.status != 200) {
        throw Exception('Failed to add to cart');
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  /// Get cart contents
  static Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _client.functions.invoke(
        'get_cart',
        method: HttpMethod.get,
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load cart');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  /// Update cart item quantity
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
        method: HttpMethod.put,
        body: {
          'cart_item_id': cartItemId,
          'quantity': quantity,
        },
      );
      
      if (response.status != 200) {
        throw Exception('Failed to update cart');
      }
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  /// Remove item from cart
  static Future<void> removeFromCart(int cartItemId) async {
    await updateCartItem(cartItemId: cartItemId, quantity: 0);
  }

  /// Clear cart
  static Future<void> clearCart() async {
    try {
      final cartData = await getCart();
      final cart = cartData['cart'] as List?;
      if (cart == null) return;
      
      for (var item in cart) {
        if (item is Map) {
          final id = item['id'];
          if (id != null) {
            final intId = id is int ? id : int.tryParse(id.toString());
            if (intId != null) {
              await removeFromCart(intId);
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // ==================== ORDERS ====================
  
  /// Create new order
  static Future<Order> createOrder({required int addressId}) async {
    try {
      final response = await _client.functions.invoke(
        'create_order',
        method: HttpMethod.post,
        body: {'address_id': addressId},
      );
      
      if (response.status != 201) {
        throw Exception('Failed to create order');
      }
      
      return Order.fromJson(response.data['order']);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get user orders
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final response = await _client.functions.invoke(
        'get_user_orders',
        method: HttpMethod.get,
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load orders');
      }
      
      final ordersList = response.data['orders'] as List;
      return ordersList.map((order) {
        return {
          'order': Order.fromJson(order),
          'address': order['address'] != null ? Address.fromJson(order['address']) : null,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Get order details
  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final response = await _client.functions.invoke(
        'get_order_details',
        method: HttpMethod.post,
        body: {'order_id': orderId},
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load order details');
      }
      
      final orderData = response.data['order'];
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
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  // ==================== ADDRESSES ====================
  
  /// Get user addresses
  static Future<List<Address>> getUserAddresses() async {
    try {
      final response = await _client.functions.invoke(
        'get_user_addresses',
        method: HttpMethod.get,
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load addresses');
      }
      
      return (response.data['addresses'] as List)
          .map((address) => Address.fromJson(address))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
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
        method: HttpMethod.post,
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
        throw Exception('Failed to add address');
      }
      
      return Address.fromJson(response.data['address']);
    } catch (e) {
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
      final body = <String, dynamic>{'address_id': addressId};
      if (street != null) body['street'] = street;
      if (city != null) body['city'] = city;
      if (state != null) body['state'] = state;
      if (zipCode != null) body['zip_code'] = zipCode;
      if (country != null) body['country'] = country;
      if (isDefault != null) body['is_default'] = isDefault;

      final response = await _client.functions.invoke(
        'update_address',
        method: HttpMethod.put,
        body: body,
      );
      
      if (response.status != 200) {
        throw Exception('Failed to update address');
      }
      
      return Address.fromJson(response.data['address']);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  /// Delete address
  static Future<void> deleteAddress(int addressId) async {
    try {
      final response = await _client.functions.invoke(
        'delete_address',
        method: HttpMethod.delete,
        body: {'address_id': addressId},
      );
      
      if (response.status != 200) {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  /// Set default address
  static Future<Address> setDefaultAddress(int addressId) async {
    try {
      final response = await _client.functions.invoke(
        'set_default_address',
        method: HttpMethod.post,
        body: {'address_id': addressId},
      );
      
      if (response.status != 200) {
        throw Exception('Failed to set default address');
      }
      
      return Address.fromJson(response.data['address']);
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }

  // ==================== WISHLIST ====================
  
  /// Get favorite products
  static Future<List<Product>> getFavoriteProducts() async {
    try {
      final response = await _client.functions.invoke(
        'get_favorite_products',
        method: HttpMethod.get,
      );
      
      if (response.status != 200) {
        throw Exception('Failed to load favorite products');
      }
      
      return (response.data['products'] as List)
          .map((product) => Product.fromJson(product))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite products: $e');
    }
  }

  /// Toggle favorite status
  static Future<Map<String, dynamic>> toggleFavorite({
    required int productId,
    String? action,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'toggle_favorite',
        method: HttpMethod.post,
        body: {
          'product_id': productId,
          if (action != null) 'action': action,
        },
      );
      
      if (response.status != 200) {
        throw Exception('Failed to toggle favorite');
      }
      
      return {
        'success': true,
        'is_favorite': response.data['is_favorite'],
        'message': response.data['message'],
      };
    } catch (e) {
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
      return false;
    }
  }

  /// Add product to favorites
  static Future<void> addToFavorites(int productId) async {
    await toggleFavorite(productId: productId, action: 'add');
  }

  /// Remove product from favorites
  static Future<void> removeFromFavorites(int productId) async {
    await toggleFavorite(productId: productId, action: 'remove');
  }

  // ==================== HELPER FUNCTIONS ====================
  
  /// Get user role
  static Future<String?> getUserRole() async {
    try {
      final user = await getCurrentUser();
      return user?.role;
    } catch (e) {
      return null;
    }
  }

  /// Update product stock (admin)
  static Future<void> updateProductStock(int productId, int newStock) async {
    try {
      await _client
          .from('product')
          .update({'stock_quantity': newStock})
          .eq('id', productId);
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  /// Get cart item count
  static Future<int> getCartItemCount() async {
    try {
      if (!isLoggedIn()) return 0;
      
      final cartData = await getCart();
      final cart = cartData['cart'] as List;
      return cart.length;
    } catch (e) {
      return 0;
    }
  }

  /// Calculate cart total
  static Future<double> calculateCartTotal() async {
    try {
      final cartData = await getCart();
      return (cartData['total'] as num).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  /// Check product availability
  static Future<bool> checkProductAvailability(int productId, int quantity) async {
    try {
      final response = await getProductById(productId);
      return response.stockQuantity >= quantity;
    } catch (e) {
      return false;
    }
  }
}
