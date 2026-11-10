import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/constants/constant.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool useTheme;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool centerTitle;
  final VoidCallback? onRefresh;
  final bool showRefresh;

  const CustomAppBar({
    super.key,
    required this.title,
    this.useTheme = false,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.centerTitle = true,
    this.onRefresh,
    this.showRefresh = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: useTheme
          ? Theme.of(context).colorScheme.surface
          : titleColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,

      // showBack fully controls the back button; without this the AppBar
      // would imply its own BackButton whenever the route can pop.
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              tooltip: 'Back'.tr,
              icon: Icon(
                CupertinoIcons.back,
                color: useTheme
                    ? Theme.of(context).colorScheme.onSurface
                    : darkColor,
              ),
              onPressed: onBack ?? () => Get.back(),
            )
          : null,

      title: Text(
        title.tr,
        style: TextStyle(
          color: useTheme ? Theme.of(context).colorScheme.onSurface : darkColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (showRefresh)
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(
              Icons.refresh,
              color: useTheme
                  ? Theme.of(context).colorScheme.onSurface
                  : darkColor,
            ),
            onPressed: onRefresh,
          ),

        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
