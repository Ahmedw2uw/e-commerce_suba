import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:flutter/material.dart';

class CategoriesAvatars extends StatelessWidget {
  const CategoriesAvatars({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              buildCategory("Women's Fashion", AppImages.women),
              buildCategory("Men's Fashion", AppImages.men),
              buildCategory("Laptops", AppImages.laptop),
              buildCategory("Beauty", AppImages.beauty),
              buildCategory("Headphones", AppImages.headphones),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              buildCategory("Women's Fashion", AppImages.women),
              buildCategory("Men's Fashion", AppImages.men),
              buildCategory("Laptops", AppImages.laptop),
              buildCategory("Beauty", AppImages.beauty),
              buildCategory("Headphones", AppImages.headphones),
            ],
          ),
        ),
      ],
    );
  }
}

Widget buildCategory(String name, String image) {
  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: Column(
      children: [
        CircleAvatar(radius: 35, backgroundImage: AssetImage(image)),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}
