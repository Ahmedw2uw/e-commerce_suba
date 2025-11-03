import 'package:e_commerce/features/navigation_layout/tabs/profile/text_feald.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/core/theme/app_colors.dart';

class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: 'ahmed ashraf');
    final emailController = TextEditingController(
      text: 'ahmedashraf@gmail.com',
    );
    final passwordController = TextEditingController(text: '**********');
    final phoneController = TextEditingController(text: '01002239104');
    final addressController = TextEditingController(
      text: 'etay elbaroud, beheira, egypt',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Welcome ${nameController.text}',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.blue,
                  ),
                ),
                Text(
                  emailController.text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 30),

                TextFeald(
                  title: "Your Name",
                  hintText: 'Name',
                  controller: nameController,
                ),
                const SizedBox(height: 24),

                // الإيميل
                TextFeald(
                  title: 'Your E-mail',
                  hintText: 'Email',
                  controller: emailController,
                ),
                const SizedBox(height: 24),

                // الباسورد
                TextFeald(
                  title: 'Your password',
                  hintText: '',
                  controller: passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // الموبايل
                TextFeald(
                  title: 'Your mobile number',
                  hintText: 'Mobile number',
                  controller: phoneController,
                ),
                const SizedBox(height: 24),

                // العنوان
                TextFeald(
                  title: 'Your Address',
                  hintText: 'Address',
                  controller: addressController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
