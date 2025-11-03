import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/presentation/category_banner.dart';
import 'package:flutter/material.dart';

class CategoriesTabView extends StatefulWidget {
  const CategoriesTabView({super.key});

  @override
  State<CategoriesTabView> createState() => _CategoriesTabViewState();
}

class _CategoriesTabViewState extends State<CategoriesTabView> {
  int selectedIndex = 0;

  final List<String> categories = [
    "Men's Fashion",
    "Women's Fashion",
    "Skincare",
    "Beauty",
    "Headphones",
    "Cameras",
    "Laptops & Electronics",
    "Baby & Toys",
  ];

  final Map<String, List<Map<String, String>>> products = {
    "Men's Fashion": [
      {"name": "T-shirts", "image": AppImages.t_shirts},
      {"name": "Shorts", "image": AppImages.shorts},
      {"name": "Jeans", "image": AppImages.jeans},
      {"name": "Pants", "image": AppImages.pants},
      {"name": "Footwear", "image": AppImages.footwear},
      {"name": "Suits", "image": AppImages.suits},
      {"name": "Watches", "image": AppImages.watches},
      {"name": "Bags", "image": AppImages.bags},
      {"name": "Eyewear", "image": AppImages.eyewears},
    ],
    "Women's Fashion": [
      {"name": "Dresses", "image": AppImages.dresses},
      {"name": "Jeans", "image": AppImages.w_jeans},
      {"name": "Skirts", "image": AppImages.skirts},
      {"name": "Pijamas", "image": AppImages.pijamas},
      {"name": "Bags", "image": AppImages.w_bags},
      {"name": "T-shirts", "image": AppImages.w_t_shirts},
      {"name": "Footwear", "image": AppImages.w_footwear},
      {"name": "Eyewear", "image": AppImages.eyewears},
      {"name": "Watches", "image": AppImages.watches},
    ],
  };

  @override
  Widget build(BuildContext context) {
    String selectedCategory = categories[selectedIndex];
    final items = products[selectedCategory] ?? [];

    return Row(
      children: [
        // القائمة الجانبية
        Container(
          width: 120,
          color: AppColors.litghGray,
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => selectedIndex = index),
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
                    categories[index],
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

        // المحتوى الرئيسي
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCategory,
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                // البنر
                CategoryBanner(
                  title: selectedCategory,
                  imageUrl: selectedIndex == 0
                      ? AppImages.men_banner
                      : AppImages.women_banner,
                ),

                const SizedBox(height: 20),

                // شبكة المنتجات
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              item["image"]!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item["name"]!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
