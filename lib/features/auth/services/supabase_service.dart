import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce/features/auth/models/user_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Sign up a new account
  static Future<Map<String, dynamic>> signUp({
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

      return response.data;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Log in
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'login',
        body: {'email': email, 'password': password},
      );

      return response.data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Log out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
