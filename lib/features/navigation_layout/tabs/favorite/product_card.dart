import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final String colorName;
  final Color colorDot;
  final double price;
  final double oldPrice;
  final VoidCallback onAddToCart;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    this.image = 'assets/images/default.png', // default image
    this.title = 'Unknown Product', // default title
    this.colorName = 'Unknown color', // default color name
    this.colorDot = Colors.grey, // default color dot
    this.price = 0.0, // default price
    this.oldPrice = 0.0, // default old price
    this.onAddToCart = _defaultVoid, // default empty function
    this.onFavorite = _defaultVoid,
    this.isFavorite = false, // default empty function
  });

  static void _defaultVoid() {} // default empty callback

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.pink[100],
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: colorDot),
                    const SizedBox(width: 6),
                    Text(colorName),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'EGP ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'EGP ${oldPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Favorite + Add to cart
          Column(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.favorite_outlined,
                  color: AppColors.blue,
                ),
                onPressed: onFavorite,
              ),
              ElevatedButton(
                onPressed: onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add to Cart'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
