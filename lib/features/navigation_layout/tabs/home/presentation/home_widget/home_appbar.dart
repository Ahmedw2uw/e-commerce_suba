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