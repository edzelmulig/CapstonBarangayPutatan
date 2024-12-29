import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/ui/screens/login_screen.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/images/custom_icon.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  void _logout() async {
    try {
      // Sign out the user
      await FirebaseAuth.instance.signOut();

      // Navigate to the LoginScreen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Handle logout errors
      debugPrint("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pending Account Validation",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF002091),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CustomIcon(
              imagePath: "lib/ui/assets/pending_icon.png",
              size: 100,
            ),
            const SizedBox(height: 15),
            const Text(
              "We're working diligently to validate your account. Please allow up to 24 hours. We appreciate your patience.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.0,
                color: Color(0xFF002091),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: CustomButton(
                buttonLabel: "Close Session",
                onPressed: _logout,
                buttonColor: const Color(0xFFe91b4f),
                buttonHeight: 50,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                fontColor: Colors.white,
                borderRadius: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
