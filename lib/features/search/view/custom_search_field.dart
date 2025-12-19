import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSearchField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted; // Add this line
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const CustomSearchField({
    super.key, 
    this.onChanged,
    this.onSubmitted, // Add this line
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted, // Use it here
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon:
            SvgPicture.asset(AppSvgs.searchIcon, fit: BoxFit.scaleDown),
        hintText: "what do you search for?",
        hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000),
          borderSide: const BorderSide(color: AppColors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000),
          borderSide: const BorderSide(color: AppColors.blue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000),
          borderSide: const BorderSide(color: AppColors.blue),
        ),
      ),
    );
  }
}