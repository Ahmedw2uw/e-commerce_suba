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

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    setState(() => isLoading = true);
    try {
      final favoriteProductsList = await SupabaseService.getFavoriteProducts();

      setState(() {
        favoriteProducts = favoriteProductsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorite products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(int productId) async {
    try {
      // The new toggleFavorite function handles adding/removing in the database
      await SupabaseService.toggleFavorite(productId: productId);
      
      // Reload the list to reflect the change
      await _loadFavoriteProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error toggling favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          ?  Center(child:Lottie.asset(AppLottie.loading),)
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
                  onFavorite: () => _toggleFavorite(product.id), onAdd: () {  }, onTap: () { // Add onTap here
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
