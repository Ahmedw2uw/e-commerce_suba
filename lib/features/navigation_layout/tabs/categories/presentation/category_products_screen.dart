import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/products/presentation/bloc/products_bloc.dart';
import 'package:e_commerce/features/products/presentation/widget/product_card.dart';
import 'package:e_commerce/features/products/presentation/widget/product_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  List<int> favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    // تحميل منتجات الـcategory
    context.read<ProductsBloc>().add(
      LoadProductsByCategoryEvent(categoryId: widget.categoryId),
    );
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString('favorites') ?? '[]';
      final List<dynamic> ids = json.decode(favoritesString);
      setState(() {
        favoriteIds = ids.cast<int>();
      });
    } catch (e) {
      print(' Error loading favorites: $e');
    }
  }

  Future<void> _toggleFavorite(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteIds.contains(productId)) {
        favoriteIds.remove(productId);
      } else {
        favoriteIds.add(productId);
      }
    });
    await prefs.setString('favorites', json.encode(favoriteIds));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} Products'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: ()  {
            Navigator.pop(context);
            
            },
        ),
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          // استخدم state.products لأن الـhandler بيخزن فيها
          final products = state.products;

          if (state.status == ProductsStatus.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (products.isEmpty) {
            return Center(child: Text('No products in this category'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isFav = favoriteIds.contains(product.id);

              return ProductCard(
                product: product,
                onFavorite: () => _toggleFavorite(product.id),
                isFavorite: isFav,
                onAdd: () {}, // إضافة للسلة - ممكن تتعامل معها بعدين
                onTap: () {
                  // هنا الـonTap اللي هتوديك لـProductDetails
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
          );
        },
      ),
    );
  }
}
