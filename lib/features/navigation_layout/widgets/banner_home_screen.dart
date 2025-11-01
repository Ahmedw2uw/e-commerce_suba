import 'package:flutter/material.dart';

class BannerHomeScreen extends StatelessWidget {
  const BannerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160, // نحدد الارتفاع العام للـ ListView
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          bannerImage('assets/images/banner1.png'),
          const SizedBox(width: 10),
          bannerImage('assets/images/banner2.png'),
          const SizedBox(width: 10),
          bannerImage('assets/images/banner3.png'),
        ],
      ),
    );
  }

  Widget bannerImage(String image) {
    return Container(
      width: 305,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover, 
        ),
      ),
    );
  }
}
