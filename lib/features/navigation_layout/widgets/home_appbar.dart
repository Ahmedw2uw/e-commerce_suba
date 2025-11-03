import 'package:e_commerce/core/widgets/search_and_cart_widget.dart';
import 'package:flutter/material.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  final int tabIndex;
  const HomeAppbar({super.key, required this.tabIndex});

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
                child: const SearchAndCartWidget(),
              ),
    );
  }

  @override
  Size get preferredSize =>
      tabIndex == 3 ? const Size.fromHeight(56) : const Size.fromHeight(96);
}
