import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double elevation;
  final Color? backgroundColor;
  final bool centerTitle;
  final Widget? leading;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.elevation = 0,
    this.backgroundColor,
    this.centerTitle = true,
    this.leading,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      leading:
          showBackButton
              ? leading ??
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/svg/arrow-left.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                  )
              : null,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      titleSpacing: 0,
      toolbarHeight: height,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color iconColor;
  final double height;

  const TransparentAppBar({
    super.key,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.iconColor = Colors.white,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading:
          showBackButton
              ? IconButton(
                icon: SvgPicture.asset(
                  'assets/svg/arrow-left.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
              : null,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      toolbarHeight: height,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
