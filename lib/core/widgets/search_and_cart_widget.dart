import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/core/widgets/custom_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SearchAndCartWidget extends StatelessWidget {
  const SearchAndCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          const Expanded(child: CustomSearchField()),
          InkWell(
            onTap: () {
            },
            child: SvgPicture.asset(AppSvgs.cartIcon),
          ),
        ],
      ),
    );
  }
}
