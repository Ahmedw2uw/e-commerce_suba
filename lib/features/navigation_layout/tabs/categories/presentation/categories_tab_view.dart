// lib/features/navigation_layout/tabs/categories/presentation/categories_tab_view.dart

import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/core/utilits/app_lottie.dart';
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/presentation/category_banner.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/cubit/category_cubit.dart';
import 'package:e_commerce/core/models/category_model.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/cubit/category_state.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/presentation/category_products_screen.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/products/products_cubit.dart';
import 'package:e_commerce/features/products/domain/repositories/products_repository.dart';
import 'package:e_commerce/features/products/presentation/widget/product_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class CategoriesTabView extends StatefulWidget {
  const CategoriesTabView({super.key});

  @override
  State<CategoriesTabView> createState() => _CategoriesTabViewState();
}

class _CategoriesTabViewState extends State<CategoriesTabView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryCubit>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        return _buildContent(state);
      },
    );
  }

  Widget _buildContent(CategoryState state) {
    if (state is CategoryLoading) {
      return Center(child: SizedBox(child: const CircularProgressIndicator()));
    }

    if (state is CategoryError) {
      return Center(
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
              onPressed: () => context.read<CategoryCubit>().loadCategories(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is CategoryLoaded) {
      return _buildCategoriesView(state);
    }

    return const Center(child: Text('Select a category to view products'));
  }

  Widget _buildCategoriesView(CategoryLoaded state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar categories list
        Container(
          width: 130,
          margin: const EdgeInsets.only(left: 8, top: 16, bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.litghGray,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.blue, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                final isSelected = state.selectedIndex == index;

                return GestureDetector(
                  onTap: () =>
                      context.read<CategoryCubit>().changeCategory(index),
                  child: Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        if (isSelected)
                          Container(
                            width: 6,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.darkBlue
                                  : AppColors.darkBlue,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Selected category content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.categories[state.selectedIndex].name,
                    style: const TextStyle(
                      color: AppColors.darkBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Banner
                  CategoryBanner(
                    title: state.categories[state.selectedIndex].name,
                    imageUrl: _getBannerImage(
                      state.categories[state.selectedIndex],
                    ),
                    onTap: () {
                      final category = state.categories[state.selectedIndex];

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => ProductsCubit(
                              productsRepository: context
                                  .read<ProductsRepository>(),
                            ),
                            child: CategoryProductsScreen(
                              categoryId: category.id,
                              categoryName: category.name,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Products / Subcategories Grid
                  if (state.products.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return _buildSubCategoryItem(product);
                      },
                    )
                  else
                    const Center(child: Text('No products in this category')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(productId: product.id),
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: product.images.isNotEmpty
                  ? (product.images.first.startsWith('http')
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildErrorPlaceholder(),
                          )
                        : Image.asset(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildErrorPlaceholder(),
                          ))
                  : _buildErrorPlaceholder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  String _getBannerImage(Category category) {
    if (category.image != null && category.image!.isNotEmpty) {
      return category.image!;
    }
    // Fallback images based on category name
    final name = category.name.toLowerCase();
    if (name.contains('men')) {
      return AppImages.menBanner;
    } else if (name.contains('women')) {
      return AppImages.womenBanner;
    }
    return AppImages.menBanner;
  }
}
