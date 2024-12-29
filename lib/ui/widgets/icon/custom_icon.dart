import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final String? imagePath; // Image path (can be null)
  final bool isNetworkImage; // Flag to determine if the image is a network image
  final double size; // Icon size

  const CustomIcon({
    super.key,
    required this.imagePath,
    required this.isNetworkImage, // Default is asset image
    this.size = 24.0, // Default size
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3), // Rounded corners
        image: imagePath != null
            ? DecorationImage(
          image: isNetworkImage
              ? NetworkImage(imagePath!) // Network image
              : AssetImage(imagePath!) as ImageProvider, // Asset image
          fit: BoxFit.cover, // Cover the container
        )
            : null, // No image if imagePath is null
        color: Colors.grey[200], // Placeholder background color if no image
      ),
      child: imagePath == null
          ? const Icon(
        Icons.image, // Default icon if imagePath is null
        size: 16.0,
        color: Colors.grey,
      )
          : null,
    );
  }
}
