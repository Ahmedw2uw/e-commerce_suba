import 'dart:convert';
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/search/repositories/search_repository.dart';
import 'package:http/http.dart' as http;

class SearchRepositoryImpl implements SearchRepository {
  final String baseUrl;
  final http.Client client;

  SearchRepositoryImpl({
    required this.baseUrl,
    required this.client,
  });

  @override
  Future<List<Product>> searchProducts(String query) async {
    final response = await client.get(
      Uri.parse('$baseUrl/products/search?q=$query'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }
}