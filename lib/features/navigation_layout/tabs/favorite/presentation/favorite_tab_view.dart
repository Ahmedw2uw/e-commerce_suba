import 'package:e_commerce/core/utilits/app_lottie.dart';
import 'package:e_commerce/features/products/presentation/widget/product_details.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/features/products/presentation/widget/product_card.dart';

class FavoriteTabView extends StatefulWidget {
  const FavoriteTabView({super.key});

  @override
  State<FavoriteTabView> createState() => _FavoriteTabViewState();
}

class _FavoriteTabViewState extends State<FavoriteTabView> {
  List<Product> favoriteProducts = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final favoriteProductsList = await SupabaseService.getFavoriteProducts();
      if (!mounted) return;

      setState(() {
        favoriteProducts = favoriteProductsList;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _toggleFavorite(int productId) async {
    try {
      await SupabaseService.toggleFavorite(productId: productId);
      await _loadFavoriteProducts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling favorite: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: Lottie.asset(AppLottie.loading))
          : hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(AppLottie.offline, width: 180),
                  const SizedBox(height: 16),
                  const Text(
                    'No Internet Connection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please check your connection and try again',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadFavoriteProducts, // Retry button
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : favoriteProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite_border, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No products in favorites',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return ProductCard(
                  product: product,
                  isFavorite: true,
                  onFavorite: () => _toggleFavorite(product.id),
                  onAdd: () {},
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetails(productId: product.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
