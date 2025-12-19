import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/core/utilits/app_lottie.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/presentation/category_products_screen.dart';
import 'package:e_commerce/features/navigation_layout/tabs/favorite/cubit/favorites_cubit.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/products/products_cubit.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/presentation/home_widget/categories_avatar.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/presentation/home_widget/home_slider.dart';
import 'package:e_commerce/features/products/presentation/widget/product_card.dart';
import 'package:e_commerce/features/products/presentation/widget/product_details.dart';
import 'package:e_commerce/features/products/domain/repositories/products_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final List<Map<String, dynamic>> _homeAppliances = [];
  bool _isLoadingHomeAppliances = true;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsCubit = context.read<ProductsCubit>();
      productsCubit.loadFeaturedProducts();
      productsCubit.loadProducts();
      
      context.read<FavoritesCubit>().loadFavorites();
      
      _loadHomeAppliances();
    });
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
              const HomeSlider(),
              const SizedBox(height: 15),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              CategoriesAvatars(
                selectedCategoryId: selectedCategoryId,
                onCategorySelected: (id, name) {
                  setState(() {
                    selectedCategoryId = id as int?;
                  });

                  // Navigate to category products screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => ProductsCubit(
                          productsRepository: context.read<ProductsRepository>(),
                        ),
                        child: CategoryProductsScreen(
                          categoryId: id,
                          categoryName: '$name ',
                        ),
                      ),
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
              //-----------
              if (_isLoadingHomeAppliances)
                SizedBox(
                  height: 170,
                  child: Center(
                    child: Lottie.asset(AppLottie.loading),
                  ),
                )
              else if (_homeAppliances.isEmpty)
                SizedBox(
                  height: 170,
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
                  height: 170,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
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
              BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state.status == ProductsStatus.loading &&
                      state.products.isEmpty) {
                    return Center(
                      heightFactor: 200,
                      child: Lottie.asset(AppLottie.loading),
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
                              onAdd: () {
                                // Add to cart logic if needed here
                              },
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadHomeAppliances() async {
    setState(() => _isLoadingHomeAppliances = true);
    try {
      final products = await SupabaseService.getProductsByCategory(13);
      final appliances = products.take(4).map((p) {
        return {
          'id': p.id,
          'name': p.name,
          'image': p.images.isNotEmpty ? p.images[0] : null,
          'price': p.price,
        };
      }).toList();
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
    final name = item['name']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        if (item['id'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetails(productId: item['id'] as int),
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 150,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: image != null
                  ? isAsset || !image.startsWith('http')
                        ? Image.asset(
                            image,
                            width: 150,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            image,
                            width: 150,
                            height: 120,
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
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 150,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
