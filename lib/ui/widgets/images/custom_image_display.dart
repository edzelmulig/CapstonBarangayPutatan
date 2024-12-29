import 'package:flutter/material.dart';

class CustomImageDisplay extends StatelessWidget {
  // PARAMETERS
  final String imageSource;
  final double imageHeight;
  final double imageWidth;

  // CONSTRUCTORS
  const CustomImageDisplay({
    super.key,
    required this.imageSource,
    required this.imageHeight,
    required this.imageWidth,
  });

  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage(imageSource);
    Image image = Image(image: assetImage);
    return SizedBox(
      height: imageHeight,
      width: imageWidth,
      child: image,
    );
  }
}