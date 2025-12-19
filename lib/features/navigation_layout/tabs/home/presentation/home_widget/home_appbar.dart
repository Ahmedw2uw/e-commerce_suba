import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/core/widgets/search_and_cart_widget.dart';
import 'package:flutter/material.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  final int tabIndex;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchSubmitted;
  final ValueChanged<String>? onSearchChanged;

  const HomeAppbar({
    super.key, 
    required this.tabIndex,
    this.searchController,
    this.searchFocusNode,
    this.onSearchSubmitted,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: tabIndex == 3
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Image.asset(
                AppImages.logo,
                width: 66,
                height: 22,
              ),
            ),
      bottom:
          tabIndex == 3
              ? PreferredSize(
                  preferredSize: preferredSize,
                  child: const SizedBox(),
                )
              : PreferredSize(
                  preferredSize: preferredSize,
                  child: SearchAndCartWidget(
                    searchController: searchController,
                    searchFocusNode: searchFocusNode,
                    onSearchSubmitted: onSearchSubmitted,
                    onSearchChanged: onSearchChanged,
                  ),
                ),
    );
  }

  @override
  Size get preferredSize =>
      tabIndex == 3 ? const Size.fromHeight(56) : const Size.fromHeight(96);
}