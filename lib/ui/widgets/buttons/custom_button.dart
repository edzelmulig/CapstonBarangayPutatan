import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  // PARAMETERS
  final String buttonLabel;
  final VoidCallback onPressed;
  final Color buttonColor;
  final double buttonHeight;
  final FontWeight fontWeight;
  final double fontSize;
  final Color fontColor;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;

  // CONSTRUCTORS
  const CustomButton({
    super.key,
    required this.buttonLabel,
    required this.onPressed,
    required this.buttonColor,
    required this.buttonHeight,
    required this.fontWeight,
    required this.fontSize,
    required this.fontColor,
    required this.borderRadius,
    this.borderWidth = 1.0,
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        elevation: 0,
        foregroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.circular(borderRadius),
          side: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        minimumSize: Size(double.infinity, buttonHeight),
      ),
      child: Text(
        buttonLabel,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor,
        ),
      ),
    );
  }
}