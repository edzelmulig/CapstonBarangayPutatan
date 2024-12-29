import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/navigation/admin_navigation.dart';
import 'package:putatanapk/navigation/user_navigation.dart';
import 'package:putatanapk/services/admin_services.dart';
import 'package:putatanapk/ui/screens/client/client_homescreen.dart';
import 'package:putatanapk/ui/screens/client/pending_screen.dart';
import 'package:putatanapk/ui/screens/login_screen.dart';
import 'package:putatanapk/ui/widgets/dialogs/custom_alert_dialog.dart';
import 'package:putatanapk/ui/widgets/loading_indicator/custom_loading_indicator.dart';
import 'package:putatanapk/ui/widgets/snackbar/custom_snackbar.dart';

class AuthService {
  // SIGN IN

  static Future signIn({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("✅ Attempting to sign in...");
      debugPrint("Email: ${email.trim()}");
      debugPrint("Password: ${password.trim()}");

      // Show loading indicator
      showLoadingIndicator(context);

      // Sign in using Firebase Authentication
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Get the user's UID
      String userId = userCredential.user!.uid;

      // Fetch userType from the root document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception("User data not found in Firestore.");
      }

      // Retrieve userType
      String userType = userDoc.get('userType');

      // Fetch status from the subcollection
      DocumentSnapshot personalInfoDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('personal_information')
          .doc('info')
          .get();

      // Check if the document exists
      String? status = personalInfoDoc.exists &&
          personalInfoDoc.data().toString().contains('status')
          ? personalInfoDoc.get('status')
          : null;

      // Dismiss loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate based on userType and status
      if (userType == 'client' && status == 'pending') {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const PendingScreen(),
            ),
          );
        }
      } else if (userType == 'admin' || status == null) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const AdminNavigation(),
            ),
          );
        }
      } else if (userType == 'client' && status == 'approved') {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const UserNavigation(),
            ),
          );
        }
      } else {
        throw Exception("Invalid userType or status.");
      }

      debugPrint("✅ Sign-in successful.");
      return true; // Login successful
    } on FirebaseAuthException catch (error) {
      debugPrint("❌ FirebaseAuthException occurred: ${error.code}");

      // Handle Firebase Authentication-specific errors
      String errorMessage;
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An error occurred: ${error.message}';
      }

      // Display error message to the user
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading indicator
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
      }

      return false; // Login failed
    } catch (error) {
      // Handle other unexpected errors
      debugPrint("❌ Unexpected error occurred: $error");

      // Display generic error message
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading indicator
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
        ));
      }

      return false; // Login failed
    }
  }

  // SIGN UP
  static Future signUp({
    required BuildContext context,
    required String email,
    required String phoneNumber,
    required String firstName,
    required String middleName,
    required String lastName,
    required double age,
    required String gender,
    required String password,
    required PlatformFile? idPicture,
  }) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        debugPrint("SUCCESS HERE*****");

        // SHOW LOADING INDICATOR
        showLoadingIndicator(context);

        // Create user with Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        final String? idURL = await ProviderServices.uploadFile(idPicture);

        // Save user information with userId to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid) // Use the UID of the created user
            .set({
          'userId': userCredential.user!.uid, // Save the userId in the root document
          'userType': 'client', // Add userType at the root level
        });

        // SAVE PERSONAL INFORMATION AS SUBCOLLECTION
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection('personal_information')
            .doc('info')
            .set({
          'email': email,
          'phoneNumber': phoneNumber,
          'firstName': firstName,
          'middleName': middleName,
          'lastName': lastName,
          'age': age,
          'gender': gender,
          'createdAt': FieldValue.serverTimestamp(),
          'idPicture': idURL,
          'status': 'pending',
          'userId': userCredential.user!.uid, // Store userId in the personal information subcollection
        });

        // DISMISS LOADING DIALOG
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // SHOW SUCCESS SNACKBAR
        if (context.mounted) {
          showFloatingSnackBar(
            context,
            'Account created successfully.',
            const Color(0xFF002091),
          );
        }

        // NAVIGATE TO LOGIN SCREEN
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      } catch (error) {
        // HANDLE ERRORS
        if (context.mounted) {
          Navigator.of(context).pop(); // Dismiss loading dialog
          showFloatingSnackBar(
            context,
            "Error signing up: ${error.toString()}",
            const Color(0xFFe91b4f),
          );
        }
      }
    } else {
      // VALIDATE EMPTY FIELDS
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'Please fill in all required fields.',
          const Color(0xFFe91b4f),
        );
      }
    }
  }


  // FORGOT PASSWORD
  Future passwordReset(BuildContext context, GlobalKey<FormState> formKey,
      TextEditingController forgotEmailController) async {
    if (formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: forgotEmailController.text.trim(),
        );

        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return CustomAlertDialog(
              message:
                  "A password reset email has been sent to your e-mail address.",
              backGroundColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginScreen();
                    },
                  ),
                );
              },
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        debugPrint('Error: ${e.message}');
      }
    }
  }
}
