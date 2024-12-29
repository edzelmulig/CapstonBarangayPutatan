import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  // PARAMETERS NEEDED
  final Color backgroundColor;
  final String titleText;
  final VoidCallback onLeadingPressed;

  // CONSTRUCTORS FOR CREATING NEW INSTANCE/OBJECT
  const CustomAppBar({
    super.key,
    required this.backgroundColor,
    this.titleText = "",
    required this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0.0,
      leading: IconButton(
        onPressed: onLeadingPressed,
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 25,
        ),
      ),
      centerTitle: true,
      title: Text(titleText,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: Color(0xFF3C3C40),
        ),
      ),
    );
  }
}