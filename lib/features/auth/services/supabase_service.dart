import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce/features/auth/models/user_model.dart';
import 'package:e_commerce/features/auth/models/category_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Sign up a new account
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

  // Log in
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

  // Get Current User
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

  static bool isLoggedIn() => _client.auth.currentUser != null;

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
      await _client.auth.signOut();
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
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }
      // Update user profile
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

  static Future<void> changeEmail({required String newEmail}) async {
    try {
      final response = await _client.functions.invoke(
        'change_email',
        body: {
          'new_email': newEmail,
        },
      );
      if (response.status != 200) {
        throw Exception('Failed to change email: ${response.status}');
      }
      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to change email: $e');
    }
  }

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

  static Future<List<Product>> getAllProducts() async {
    final response = await Supabase.instance.client.functions.invoke(
      'get_all_products',
    );

    if (response.data['success'] == true) {
      final products = (response.data['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
      print('Loaded ${response.data['total']} products');
      return products;
    }
    throw Exception('Failed to fetch products');
  }

  // Using ID
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

  //Using Name
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
}
