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
              buildCategory("Women's Fashion", "assets/images/women.jpg"),
              buildCategory("Men's Fashion", "assets/images/men.jpg"),
              buildCategory("Laptops", "assets/images/laptop.jpg"),
              buildCategory("Beauty", "assets/images/beauty.jpg"),
              buildCategory("Headphones", "assets/images/headphones.jpg"),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              buildCategory("Women's Fashion", "assets/images/women.jpg"),
              buildCategory("Men's Fashion", "assets/images/men.jpg"),
              buildCategory("Laptops", "assets/images/laptop.jpg"),
              buildCategory("Beauty", "assets/images/beauty.jpg"),
              buildCategory("Headphones", "assets/images/headphones.jpg"),
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
