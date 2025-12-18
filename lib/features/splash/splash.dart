import 'dart:async';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/features/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/'; // route name for splash
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, Login.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Center(
        child: SizedBox(
          child: Lottie.asset("assets/lottie/add to cart (1).json"),
        ),
      ),
    );
  }
}
