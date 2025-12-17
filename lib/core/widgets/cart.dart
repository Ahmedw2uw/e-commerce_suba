import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Cart extends StatelessWidget {
  final String image;
  final String title;
  final String colorName;
  final Color colorDot;
  final double price;
  final double oldPrice;
  final VoidCallback onDelete;
  final bool isDeleted;

  const Cart({
    super.key,
    this.image = 'assets/images/default.png',
    this.title = 'Unknown Product',
    this.colorName = 'Unknown color',
    this.colorDot = Colors.grey,
    this.price = 0.0,
    this.oldPrice = 0.0,
    this.onDelete = _defaultVoid,
    this.isDeleted = false,
  });

  static void _defaultVoid() {}

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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.pink[100],
              child: Image.asset(
                image,
                fit: BoxFit.cover,

              ),
            ),
          ),
          const SizedBox(width: 12),

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

          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: AppColors.red),
                onPressed: onDelete,
              ),
              _quantityBox(quantity: 1, onAdd: () => {}, onRemove: () => {}),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _quantityBox({
  required int quantity,
  required VoidCallback onAdd,
  required VoidCallback onRemove,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.blue,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
      
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.remove, color: Colors.white, size: 16),
            onPressed: onRemove,
          ),
        ),
    
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$quantity',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            onPressed: onAdd,
          ),
        ),
      ],
    ),
  );
}
