import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/constants.dart';

class CustomGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;

  const CustomGradientAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
         gradient: LinearGradient(
                colors: [MyColor.blueColor, MyColor.purpleColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: elevation,
        title: title,
        // centerTitle: centerTitle,
        leading: leading,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
