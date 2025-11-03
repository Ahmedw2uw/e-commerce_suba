
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TextField extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Color titleColor;
  final Color fillColor;
  final Color borderColor;
  final double titleFontSize;
  final IconData? suffixIcon;
  final VoidCallback? onIconPressed;

  const TextField({
    super.key,
    required this.title,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.titleColor = AppColors.blue,
    this.fillColor = Colors.white,
    this.borderColor = AppColors.grey,
    this.titleFontSize = 18,
    this.suffixIcon = Icons.edit,
    this.onIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: fillColor,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    onPressed: onIconPressed,
                    icon: Icon(suffixIcon, color: borderColor),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    );
  }
}
