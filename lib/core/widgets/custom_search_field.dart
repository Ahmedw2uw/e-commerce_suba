import 'package:e_commerce/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return TextField(
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: SvgPicture.asset(AppSvgs.searchIcon, fit: BoxFit.scaleDown),
        hintText: "search",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
    );
  }
}
