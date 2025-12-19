import 'package:e_commerce/core/utilits/app_lottie.dart';
import 'package:e_commerce/features/navigation_layout/tabs/favorite/cubit/favorites_cubit.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/products/products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/products/presentation/widget/product_card.dart';
import 'package:e_commerce/features/products/presentation/widget/product_details.dart';
import 'package:lottie/lottie.dart';

class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Load category products
    context.read<ProductsCubit>().loadProductsByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: Text(
          widget.categoryName.trim(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          final products = state.products;

          if (state.status == ProductsStatus.loading) {
             return Center(child: Lottie.asset(AppLottie.loading));
          }

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text(
                     'No products found in ${widget.categoryName}',
                     style: TextStyle(color: Colors.grey[600], fontSize: 16),
                   ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(), // Bouncing physics
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, favoritesState) {
                    final isFav = favoritesState.ids.contains(product.id);
                    return ProductCard(
                      product: product,
                      onFavorite: () {
                        context.read<FavoritesCubit>().toggleFavorite(product.id);
                      },
                      isFavorite: isFav,
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
            },
          );
        },
      ),
    );
  }
}
