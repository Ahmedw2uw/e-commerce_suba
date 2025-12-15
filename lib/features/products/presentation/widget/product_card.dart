import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/models/product_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavorite;
  final bool isFavorite;
   final VoidCallback? onTap;
  

  const ProductCard({
    super.key,
    required this.product,
    required this.onFavorite,
    this.isFavorite = false, required Null Function() onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 150,
                height: 150,
                color: Colors.grey.shade200,
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ فشل تحميل صورة المنتج: $error');
                          return const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
      
            // تفاصيل المنتج
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
      
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  //    لو اللون موجود هيعرضه
                  if (product.color != null) ...[
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getColorFromString(product.color!),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          product.color!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'EGP ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
            ),
      
            // الأزرار - المعدل
            Container(
              width: 70, // ← عرض ثابت بدل Flexible
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: isFavorite ? AppColors.red : AppColors.blue,
                      size: 20,
                    ),
                    onPressed: () async {
                      print('❤️ Added ${product.name} to favorites');
      
                      // حفظ في SharedPreferences
                      _saveFavorite(product.id);
      
                      // عمل الـ callback القديم
                      onFavorite();
      
                      // إظهار رسالة للمستخدم
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'تمت إزالة ${product.name} من المفضلة'
                                : 'تمت إضافة ${product.name} إلى المفضلة',
                          ),
                          duration: Duration(seconds: 1),
                          backgroundColor: isFavorite ? Colors.grey : Colors.pink,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      _addToCartWithDebug(context, product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 12), // ← اختصر النص
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveFavorite(int productId) async {
    try {
      // استخدم SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // جيب الـ favorites الحالية
      final favoritesString = prefs.getString('favorites') ?? '[]';
      final List<dynamic> favorites = json.decode(favoritesString);

      // تحقق إذا المنتج موجود
      if (favorites.contains(productId)) {
        // أمسحه لو موجود
        favorites.remove(productId);
      } else {
        // أضيفه لو مش موجود
        favorites.add(productId);
      }

      // حفظ التحديث
      await prefs.setString('favorites', json.encode(favorites));

      print('✅ Saved favorite: $productId, All favorites: $favorites');
    } catch (e) {
      print('❌ Error saving favorite: $e');
    }
  }

  void _addToCartWithDebug(BuildContext context, Product product) {
    print('🛒 === بدء إضافة المنتج للسلة ===');
    print('   المنتج: ${product.name}');
    print('   السعر: ${product.price}');
    print('   الـ ID: ${product.id}');
    print('   الصور: ${product.images.length}');

    try {
      if (!context.mounted) {
        print('❌ Context غير متاح');
        return;
      }

      final cartBloc = context.read<CartBloc>();
      print('✅ CartBloc موجود');

      cartBloc.add(AddToCartEvent(product: product, quantity: 1));

      print('✅ تم إرسال AddToCartEvent بنجاح');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة ${product.name} إلى السلة'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );

      print('✅ تم عرض رسالة النجاح');
      print('🛒 === انتهاء إضافة المنتج ===');
    } catch (e) {
      print('❌ === خطأ في إضافة المنتج ===');
      print('   الخطأ: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الإضافة: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
