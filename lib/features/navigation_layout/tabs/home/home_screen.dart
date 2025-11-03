import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/home_widget/banner_home_screen.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/home_widget/categories_avatar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerHomeScreen(),
              const SizedBox(height: 25),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("View all", style: TextStyle(color: Colors.blueAccent)),
                ],
              ),
              const SizedBox(height: 15),
              const CategoriesAvatars(),
              const SizedBox(height: 25),

              const Text(
                "Home Appliance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (context, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return homeApplianceImage(AppImages.laptop);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget homeApplianceImage(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        image,
        width: 150,
        height: 130,
        fit: BoxFit.cover,
        cacheWidth: 300, 
      ),
    );
  }
}
