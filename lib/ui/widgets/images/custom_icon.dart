import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final String imagePath;
  final double size;

  const CustomIcon({
    super.key,
    required this.imagePath,
    this.size = 24.0, // Default size
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        image: DecorationImage(
          image: AssetImage(imagePath),
        ),
      ),
    );
  }
}