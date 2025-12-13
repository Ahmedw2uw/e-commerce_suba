import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/home_appliances/home_appliances_cubit.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/home_appliances/home_appliances_state.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/products/products_cubit.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/products/products_state.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/view/home_widget/banner_home_screen.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/view/home_widget/categories_avatar.dart';
import 'package:e_commerce/features/products/presentation/widget/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsCubit>().loadFeaturedProducts();
      context.read<ProductsCubit>().loadAllProducts();
      context.read<HomeAppliancesCubit>().loadAppliances();
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
              const BannerHomeScreen(),
              const SizedBox(height: 25),

              // التصنيفات
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
              const CategoriesAvatars(),
              const SizedBox(height: 25),

              // المنتجات المميزة
              const Text(
                "Featured Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state.status == ProductsStatus.loading &&
                      state.featuredProducts.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                      heightFactor: 300,
                    );
                  }

                  if (state.featuredProducts.isEmpty) {
                    return _buildProductsGrid(state.allProducts);
                  }

                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.featuredProducts.length,
                      itemBuilder: (context, index) {
                        final product = state.featuredProducts[index];
                        return Container(
                          width: 400,
                          margin: EdgeInsets.only(
                            right: index == state.featuredProducts.length - 1
                                ? 0
                                : 12,
                          ),
                          child: ProductCard(
                            product: product,
                            onFavorite: () {},
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // الأجهزة المنزلية
              const Text(
                "Home Appliance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              BlocBuilder<HomeAppliancesCubit, HomeAppliancesState>(
                builder: (context, state) {
                  if (state.status == HomeAppliancesStatus.loading) {
                    return SizedBox(
                      height: 130,
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.darkBlue),
                      ),
                    );
                  } else if (state.appliances.isEmpty) {
                    return SizedBox(
                      height: 130,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_outlined, size: 50, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              'No home appliances',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.appliances.length,
                        separatorBuilder: (context, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return _buildHomeApplianceItem(state.appliances[index]);
                        },
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 25),

              // كل المنتجات
              const Text(
                "All Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state.status == ProductsStatus.loading &&
                      state.allProducts.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkBlue,
                      ),
                      heightFactor: 200,
                    );
                  }

                  if (state.allProducts.isEmpty) {
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
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(state.allProducts.length, (index) {
                          final product = state.allProducts[index];
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 44) / 2,
                            child: ProductCard(
                              product: product,
                              onFavorite: () {},
                            ),
                          );
                        }),
                      ),
                    ],
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
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.home_outlined, size: 50),
                      );
                    },
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

Widget _buildProductsGrid(List<Product> products) {
  if (products.isEmpty) {
    return const Center(
      child: Text('No products available'),
      heightFactor: 200,
    );
  }

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.75,
    ),
    itemCount: products.length,
    itemBuilder: (context, index) {
      final product = products[index];
      return ProductCard(
        product: product,
        onFavorite: () {
          print('Added ${product.name} to favorites');
        },
      );
    },
  );
}
