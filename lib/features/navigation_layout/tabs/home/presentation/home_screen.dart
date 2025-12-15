import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/presentation/home_widget/banner_home_screen.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/presentation/home_widget/categories_avatar.dart';
import 'package:e_commerce/features/products/presentation/bloc/products_bloc.dart';
import 'package:e_commerce/features/products/presentation/widget/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _homeAppliances = [];
  bool _isLoadingHomeAppliances = true;
  List<int> favoriteIds = [];
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsBloc>().add(LoadFeaturedProductsEvent());
      context.read<ProductsBloc>().add(LoadProductsEvent());
      _loadHomeAppliances();
    });
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
      print('❌ Error loading favorites: $e');
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerHomeScreen(),
              const SizedBox(height: 25),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("View all", style: TextStyle(color: Colors.blueAccent)),
                ],
              ),
              const SizedBox(height: 15),
              CategoriesAvatars(
                selectedCategoryId: selectedCategoryId,
                onCategorySelected: (id) {
                  setState(() {
                    selectedCategoryId = id as int?;
                  });

                  print('Category selected: $id');
                 //هنتقل لصفحه لعرض المنتجات الخاصه بال category
                },
              ),
              const SizedBox(height: 25),
              const Text(
                "Featured Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Featured Products
              BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state.status == ProductsStatus.loading &&
                      state.featuredProducts.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                      heightFactor: 300,
                    );
                  }

                  if (state.featuredProducts.isEmpty) {
                    return const SizedBox(); // لو مفيش featured products
                  }

                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.featuredProducts.length,
                      itemBuilder: (context, index) {
                        final product = state.featuredProducts[index];
                        final isFav = favoriteIds.contains(product.id);
                        return Container(
                          width: 400,
                          margin: EdgeInsets.only(
                            right: index == state.featuredProducts.length - 1
                                ? 0
                                : 12,
                          ),
                          child: ProductCard(
                            product: product,
                            onFavorite: () => _toggleFavorite(product.id),
                            isFavorite: isFav, onAdd: () {  },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),

              const Text(
                "Home Appliance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (_isLoadingHomeAppliances)
                SizedBox(
                  height: 130,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.darkBlue),
                  ),
                )
              else if (_homeAppliances.isEmpty)
                SizedBox(
                  height: 130,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No home appliances',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _homeAppliances.length,
                    separatorBuilder: (context, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return _buildHomeApplianceItem(_homeAppliances[index]);
                    },
                  ),
                ),
              const SizedBox(height: 25),

              const Text(
                "All Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // All Products as vertical list
              BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state.status == ProductsStatus.loading &&
                      state.products.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkBlue,
                      ),
                      heightFactor: 200,
                    );
                  }

                  if (state.products.isEmpty) {
                    return Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No products available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: state.products.map((product) {
                      final isFav = favoriteIds.contains(product.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProductCard(
                          product: product,
                          onFavorite: () => _toggleFavorite(product.id),
                          isFavorite: isFav, onAdd: () {  },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadHomeAppliances() async {
    setState(() => _isLoadingHomeAppliances = true);
    try {
      final appliances = await SupabaseService.getHomeAppliances();
      setState(() {
        _homeAppliances.clear();
        if (appliances.isNotEmpty) {
          _homeAppliances.addAll(appliances);
        } else {
          _homeAppliances.addAll([
            {'image': AppImages.laptop, 'isAsset': true},
            {'image': AppImages.headphones, 'isAsset': true},
            {'image': AppImages.beauty, 'isAsset': true},
            {'image': AppImages.men, 'isAsset': true},
          ]);
        }
        _isLoadingHomeAppliances = false;
      });
    } catch (e) {
      setState(() => _isLoadingHomeAppliances = false);
    }
  }

  Widget _buildHomeApplianceItem(Map<String, dynamic> item) {
    final image = item['image']?.toString();
    final isAsset = item['isAsset'] == true;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 150,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: image != null
            ? isAsset || !image.startsWith('http')
                  ? Image.asset(
                      image,
                      width: 150,
                      height: 130,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      image,
                      width: 150,
                      height: 130,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.home_outlined, size: 50),
                      ),
                    )
            : Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.home_outlined,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }
}
