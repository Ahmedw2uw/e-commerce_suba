import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/core/models/category_model.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:flutter/material.dart';

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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await SupabaseService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
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
    return AppImages.laptop; // Default general image
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticCategories() {
    return SizedBox(
      height: 260, // Height enough for two rows
      child: GridView.count(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        scrollDirection: Axis.horizontal,
        crossAxisCount: 2, // two rows
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1, 
        children: [
          _buildCategory("Women's Fashion", AppImages.women),
          _buildCategory("Men's Fashion", AppImages.men),
          _buildCategory("Laptops", AppImages.laptop),
          _buildCategory("Beauty", AppImages.beauty),
          _buildCategory("Headphones", AppImages.headphones),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 260,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
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
    if (_categories.isEmpty) {
      return _buildStaticCategories();
    }

    return SizedBox(
      height: 260,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final imageUrl = _getImageUrl(category.image);
          final image = imageUrl ?? _getDefaultImage(category.name);
          final isSelected = category.id == widget.selectedCategoryId;

          return _buildCategory(
            category.name,
            image,
            categoryId: category.id,
            isSelected: isSelected,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStaticCategories(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Failed to load categories',
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _buildDynamicCategories();
  }
}
