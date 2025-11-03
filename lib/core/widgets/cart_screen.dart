import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/core/widgets/cart.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const String routeName = '/cart_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Column(
        children: [
          Cart(
            image: AppImages.nike,
            title: 'Black Nike',
            colorName: 'Black',
            colorDot: Colors.black,
            price: 49.99,
            oldPrice: 69.99,
          ),
        ],
      ),
    );
  }
}
