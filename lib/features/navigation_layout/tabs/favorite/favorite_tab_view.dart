import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/features/navigation_layout/tabs/favorite/product_card.dart';
import 'package:flutter/material.dart';

class FavoriteTabView extends StatelessWidget {
  const FavoriteTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ProductCard(
            image: AppImages.nike,
            title: 'Black Nike',
            colorName: 'Black',
            colorDot: Colors.black,
            price: 49.99,
            oldPrice: 69.99,
            onAddToCart: () {},
            onFavorite: () {},
          ),
          ProductCard(
            image: AppImages.dress,
            title: 'orange Dress',
            colorName: 'Orange',
            colorDot: Colors.orange,
            price: 49.99,
            oldPrice: 69.99,
            onAddToCart: () {},
            onFavorite: () {},
          ),
          ProductCard(
            image: AppImages.watch,
            title: 'Gold Watch',
            colorName: 'Gold',
            colorDot: Colors.yellow,
            price: 49.99,
            oldPrice: 69.99,
            onAddToCart: () {},
            onFavorite: () {},
          ),
        ],
      ),
    );
  }
}
