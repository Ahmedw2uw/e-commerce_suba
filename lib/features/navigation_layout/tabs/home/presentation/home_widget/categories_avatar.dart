import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/core/models/category_model.dart';
import 'package:e_commerce/core/utilits/app_lottie.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CategoriesAvatars extends StatefulWidget {
  final int? selectedCategoryId;
  final Function(int, String)? onCategorySelected;

  const CategoriesAvatars({
    super.key,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  State<CategoriesAvatars> createState() => _CategoriesAvatarsState();
}

class _CategoriesAvatarsState extends State<CategoriesAvatars> {
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await SupabaseService.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Error loading categories: $e');
    }
  }

  String? _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    if (imagePath.startsWith('http')) return imagePath;
    return null;
  }

  String _getDefaultImage(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('women') || lowerName.contains('female')) {
      return AppImages.women;
    } else if (lowerName.contains('men') || lowerName.contains('male')) {
      return AppImages.men;
    } else if (lowerName.contains('laptop') || lowerName.contains('computer')) {
      return AppImages.laptop;
    } else if (lowerName.contains('beauty') || lowerName.contains('cosmetic')) {
      return AppImages.beauty;
    } else if (lowerName.contains('headphone') || lowerName.contains('audio')) {
      return AppImages.headphones;
    }
    return AppImages.laptop;
  }

  Widget _buildCategory(
    String name,
    String image, {
    int? categoryId,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: categoryId != null && widget.onCategorySelected != null
          ? () => widget.onCategorySelected!(categoryId, name)
          : null,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
                image: DecorationImage(
                  image: image.startsWith('http')
                      ? NetworkImage(image)
                      : AssetImage(image) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 260,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
        ),
        itemCount: 6,
        itemBuilder: (_, __) {
          return Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 70,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDynamicCategories() {
    return SizedBox(
      height: 260,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
        ),
        itemCount: _categories.length,
        itemBuilder: (_, index) {
          final category = _categories[index];
          final image =
              _getImageUrl(category.image) ?? _getDefaultImage(category.name);

          return _buildCategory(
            category.name,
            image,
            categoryId: category.id,
            isSelected: category.id == widget.selectedCategoryId,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingState();

    if (_error != null) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(AppLottie.offline, width: 180),
            const Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _buildDynamicCategories();
  }
}
