import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({super.key});

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  @override
  final myItems = [
    BannerLeftText(
      imagePath: AppImages.homeBanner1,
      text: "For all Headphones \n& AirPods",
      persentage: "25",
    ),
    BannerRightText(
      imagePath: AppImages.homeBanner2,
      text: "For all Makeup \n& Skincare",
      persentage: "30",
    ),
    BannerLeftText(
      imagePath: AppImages.homeBanner3,
      text: "For Laptops \n& Mobiles",
      persentage: "20",
    ),
  ];

  int currentIndex = 0;

  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 4),
              autoPlayAnimationDuration: Duration(milliseconds: 1600),
              pauseAutoPlayOnTouch: true,
              pauseAutoPlayOnManualNavigate: true,
              pauseAutoPlayInFiniteScroll: false,
              viewportFraction: 1, // عرض العنصر فقط واخفاء الباقي
              enlargeCenterPage: true, // تكبير العنصر المركزي
              height: 200,
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            items: myItems,
          ),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 15, left: 0, right: 0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSmoothIndicator(
                activeIndex: currentIndex,
                count: myItems.length,
                effect: const WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  spacing: 5,
                  dotColor: Colors.white,
                  activeDotColor: Color(0xff004182),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BannerLeftText extends StatelessWidget {
  BannerLeftText({
    super.key,
    required this.imagePath,
    required this.text,
    required this.persentage,
  });

  Color mainColor = Color(0xff004182);
  String imagePath;
  String text;
  String persentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(imagePath),
        Positioned(
          left: 40,
          top: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "UP TO",
                style: TextStyle(
                  color: mainColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    "25%",
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "OFF",
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "For all Headphones \n& AirPods",
                style: TextStyle(color: mainColor, fontSize: 14),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  backgroundColor: mainColor, // 🔥 لون الزر
                  foregroundColor: Colors.white, // 🔥 لون النص والأيقونات
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // 👈 هنا تغيّر الـ radius
                  ),
                ),
                child: Text("Get Started"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BannerRightText extends StatelessWidget {
  BannerRightText({
    super.key,
    required this.imagePath,
    required this.text,
    required this.persentage,
  });

  Color mainColor = Color(0xffffffff);
  String imagePath;
  String text;
  String persentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(imagePath),
        Positioned(
          right: 40,
          top: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "UP TO",
                style: TextStyle(
                  color: mainColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    "$persentage%",
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "OFF",
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text("$text", style: TextStyle(color: mainColor, fontSize: 14)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  backgroundColor: mainColor, // 🔥 لون الزر
                  foregroundColor: Color(0xff004182), // 🔥 لون النص والأيقونات
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // 👈 هنا تغيّر الـ radius
                  ),
                ),
                child: Text("Shop Now"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
