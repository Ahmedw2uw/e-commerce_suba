import 'package:e_commerce/features/products/presentation/widget/product_details.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/features/products/presentation/widget/product_card.dart';

class FavoriteTabView extends StatefulWidget {
  const FavoriteTabView({super.key});

  @override
  State<FavoriteTabView> createState() => _FavoriteTabViewState();
}

class _FavoriteTabViewState extends State<FavoriteTabView> {
  List<int> favoriteIds = [];
  List<Product> favoriteProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString('favorites') ?? '[]';
      final List<dynamic> ids = json.decode(favoritesString);

      setState(() {
        favoriteIds = ids.cast<int>();
        isLoading = false;
      });

      // جلب تفاصيل المنتجات
      _loadFavoriteProducts();
    } catch (e) {
      print('❌ Error loading favorites: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadFavoriteProducts() async {
    try {
      final allProducts = await SupabaseService.getAllProductsDirect();
      final favoriteProductsList = allProducts
          .where((product) => favoriteIds.contains(product.id))
          .toList();

      setState(() {
        favoriteProducts = favoriteProductsList;
      });
    } catch (e) {
      print('❌ Error loading favorite products: $e');
    }
  }

  Future<void> _toggleFavorite(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteIds.contains(productId)) {
        favoriteIds.remove(productId);
        favoriteProducts.removeWhere((p) => p.id == productId);
      } else {
        favoriteIds.add(productId);
        _loadFavoriteProducts(); // لإعادة جلب المنتج وإضافته للقائمة
      }
    });
    await prefs.setString('favorites', json.encode(favoriteIds));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite_border, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'لا توجد منتجات في المفضلة',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return ProductCard(
                  product: product,
                  isFavorite: true,
                  onFavorite: () => _toggleFavorite(product.id), onAdd: () {  }, onTap: () { // <--- إضافة onTap هنا
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetails(
                                      productId: product.id,
                                    ),
                                  ),
                                );
                              },
                );
              },
            ),
    );
  }
}
