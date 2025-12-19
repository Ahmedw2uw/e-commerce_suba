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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              viewportFraction: 1, // Show only one item and hide others
              enlargeCenterPage: true, // Enlarge center page
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
                  dotColor: Colors.grey,
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

// ignore: must_be_immutable
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
          top: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "UP TO",
                style: TextStyle(
                  color: mainColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    "25%",
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 28,
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
                style: TextStyle(color: mainColor, fontSize: 12),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  backgroundColor: mainColor, // Button color
                  foregroundColor: Colors.white, // Text and icon color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // Change radius here
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

// ignore: must_be_immutable
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
          top: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "UP TO",
                style: TextStyle(
                  color: mainColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    "$persentage%",
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 28,
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
              Text(text, style: TextStyle(color: mainColor, fontSize: 12)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  backgroundColor: mainColor, // Button color
                  foregroundColor: Color(0xff004182), // Text and icon color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
