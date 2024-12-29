import 'package:flutter/material.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/images/custom_image_display.dart';

// ALERT DIALOG CUSTOM CLASS
class CustomAlertDialog extends StatelessWidget {
  final String message;
  final Color backGroundColor;
  final VoidCallback onPressed;

  const CustomAlertDialog({
    super.key,
    required this.message,
    required this.backGroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: backGroundColor,
      elevation: 10.0,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: CustomImageDisplay(
              imageSource: "lib/ui/assets/barangay_putatan_icon.png",
              imageHeight: 100,
              imageWidth: 100,
            ),
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF002091),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        CustomButton(
          buttonLabel: "OK",
          onPressed: onPressed,
          buttonHeight: 55,
          buttonColor: const Color(0xFF002091),
          fontWeight: FontWeight.normal,
          fontSize: 13,
          fontColor: Colors.white,
          borderRadius: 10,
        ),
      ],
    );
  }
}