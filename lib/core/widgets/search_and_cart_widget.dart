import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/features/cart/presentation/screens/cart_screen.dart';
import 'package:e_commerce/features/search/view/custom_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SearchAndCartWidget extends StatelessWidget {
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchSubmitted;
  final ValueChanged<String>? onSearchChanged;

  const SearchAndCartWidget({
    super.key,
    this.searchController,
    this.searchFocusNode,
    this.onSearchSubmitted,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: CustomSearchField(
              controller: searchController,
              focusNode: searchFocusNode,
              onSubmitted: onSearchSubmitted,
              onChanged: onSearchChanged,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, CartScreen.routeName);
            },
            child: SvgPicture.asset(AppSvgs.cartIcon),
          ),
        ],
      ),
    );
  }
}