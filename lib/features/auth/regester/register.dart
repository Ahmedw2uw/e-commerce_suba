// ignore_for_file: must_be_immutable

import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/features/auth/auth_text_feald.dart';
import 'package:e_commerce/features/auth/login/login.dart';
import 'package:e_commerce/features/navigation_layout/navigation_view.dart';
import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  static const String routeName = '/register';
  SignUp({super.key});

  var fullNameController = TextEditingController();
  var mobileNumberController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Form(
        key: formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        title: "Full Name",
                        hintText: "enter your full name",
                        controller: fullNameController,
                      ),
                      const SizedBox(height: 10),
                      AuthTextField(
                        title: "Mobile Number",
                        hintText: "enter your mobile no.",
                        controller: mobileNumberController,
                      ),
                      const SizedBox(height: 10),
                      AuthTextField(
                        title: "Email Address",
                        hintText: "enter your server email",
                        controller: emailController,
                      ),
                      const SizedBox(height: 10),
                      AuthTextField(
                        title: "Password",
                        hintText: "enter your password",
                        obscureText: true,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pushNamed(
                              context,
                              NavigationView.routeName,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF001F3F),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Login.routeName);
                      },
                      child: Text(
                        "signIn",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
