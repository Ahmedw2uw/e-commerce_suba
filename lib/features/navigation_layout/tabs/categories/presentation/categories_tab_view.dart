// lib/features/navigation_layout/tabs/categories/presentation/categories_tab_view.dart

import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/core/utilits/app_lottie.dart';
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/presentation/category_banner.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/cubit/category_cubit.dart';
import 'package:e_commerce/core/models/category_model.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/cubit/category_state.dart';
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
      return Center(child: SizedBox(child: Lottie.asset(AppLottie.loading)));
    }

    if (state is CategoryError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}'),
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
      children: [
        // Sidebar categories list
        Container(
          width: 120,
          color: AppColors.litghGray,
          child: ListView.builder(
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final isSelected = state.selectedIndex == index;

              return GestureDetector(
                onTap: () =>
                    context.read<CategoryCubit>().changeCategory(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    border: isSelected
                        ? const Border(
                            left: BorderSide(color: Colors.blue, width: 3),
                          )
                        : null,
                  ),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Selected category content
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topLeft, // Ensures content is at top
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      state.categories[state.selectedIndex].name,
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Banner
                  CategoryBanner(
                    title: state.categories[state.selectedIndex].name,
                    imageUrl: _getBannerImage(state.categories[state.selectedIndex]),
                  ),

                  const SizedBox(height: 20),

                  // Products
                  if (state.products.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.8,
                          ),
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return _buildProductItem(product);
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

  Widget _buildProductItem(Product product) {
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
                  ? Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
