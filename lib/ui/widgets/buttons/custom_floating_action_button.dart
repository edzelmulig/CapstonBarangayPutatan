import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  // PARAMETERS NEEDED
  final String textLabel;
  final VoidCallback onPressed;
  final Color color;

  // CONSTRUCTORS FOR CREATING NEW INSTANCE/OBJECT
  const CustomFloatingActionButton({
    super.key,
    required this.textLabel,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      icon: const Icon(
        Icons.add,
        color: Color(0xFFF5F5F5),
        size: 25,
      ),
      label: Container(
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: Text(
          textLabel,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: color,
      // backgroundColor: const Color(0xFF002091),
    );
  }
}