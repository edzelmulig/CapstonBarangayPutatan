import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/navigation/navigation_utils.dart';
import 'package:putatanapk/services/user_profile_service.dart';
import 'package:putatanapk/ui/screens/login_screen.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_navigation_button.dart';
import 'package:putatanapk/ui/widgets/dialogs/custom_show_dialog.dart';
import 'package:putatanapk/ui/widgets/images/custom_user_profile.dart';
import 'package:putatanapk/ui/widgets/modals/custom_modals.dart';
import 'package:putatanapk/ui/widgets/texts/custom_text_description.dart';
import 'package:putatanapk/user_information/account_information.dart';
import 'package:putatanapk/user_information/email_address.dart';
import 'package:putatanapk/user_information/phone_number.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {

  // VARIABLE DECLARATIONS
  late Map<String, dynamic> userData = {};
  PlatformFile? selectedImage;
  String? imageURL;
  String? displayName;


  Future<void> _logout() async {
    try {
      // Sign out from FirebaseAuth
      await FirebaseAuth.instance.signOut();

      // Navigate back to the LandingPage
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  // // METHOD THAT WILL ADD imageURL FIELD ON EXISTING DOCUMENT IN FIRESTORE
  void updateProfileImage(String downloadURL) async {
    await UserProfileService.updateProfileImage(downloadURL);
    if (mounted) {
      // Use your existing method or Flutter's built-in methods to show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully.")),
      );
    }
  }

  // METHOD FOR SELECTING THE IMAGE
  Future handleFileSelection() async {
    final result = await UserProfileService.selectImage();
    if (result != null) {
      setState(() {
        selectedImage = result.files.first;
      });

      if (mounted) {
        showUploadDialog(
          context: context,
          uploadFile: uploadProfileImage,
          selectedImage: selectedImage,
        );
      }
    }
  }

  // METHOD FOR UPLOADING THE IMAGE TO DATABASE
  Future uploadProfileImage() async {
    final downloadURL =
    await UserProfileService.uploadFile(selectedImage, imageURL);

    if (downloadURL != null) {
      setState(() {
        imageURL = downloadURL;
      });
      updateProfileImage(downloadURL);
    }
  }

  @override
  Widget build(BuildContext context) {


    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        // BODY OF ACCOUNT INFORMATION PAGE
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30),
              StreamBuilder<Map<String, dynamic>>(
                stream: UserProfileService().getUserDataStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  // EXTRACT DATA FROM SNAPSHOT
                  userData = snapshot.data ?? {};
                  displayName = userData['displayName'] ?? 'No Name';
                  imageURL = userData['imageURL'];

                  return Column(
                    children: <Widget>[
                      const SizedBox(height: 30),

                      // USER IMAGE
                      CustomUpdateUserProfile(
                        imageURL: imageURL,
                        selectedImage: selectedImage,
                        imageWidth: 140,
                        imageHeight: 140,
                        onPressed: () {
                          handleFileSelection();
                        },
                      ),

                      // USER DISPLAY NAME
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(
                            top: 15,
                            left: 20,
                            right: 20,
                          ),
                          child: AutoSizeText(
                            displayName ?? 'No Name',
                            style: const TextStyle(
                              color: Color(0xFF3C3C40),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // SIZED BOX: SPACING
              const SizedBox(height: 60),

              // ACCOUNT INFORMATION TEXTS
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin:
                  const EdgeInsets.only(left: 25, right: 20, bottom: 10),
                  child: const Text(
                    "User Information",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8C8C8C),
                    ),
                  ),
                ),
              ),

              // ACCOUNT INFORMATION
              CustomNavigationButton(
                textButton: "Personal information",
                textColor: const Color(0xFF3C3C40),
                onPressed: () {
                  navigateWithSlideFromRight(
                    context,
                    const UserAccountInformation(
                      text: "Your data, like first name, and last name"
                          " will be used to improve residents discovery and more. ",
                    ),
                    1.0,
                    0.0,
                  );
                },
              ),

              // PHONE NUMBER
              CustomNavigationButton(
                textButton: "Phone number",
                textColor: const Color(0xFF3C3C40),
                onPressed: () {
                  navigateWithSlideFromRight(
                    context,
                    const UserPhoneNumber(
                      text: "Your phone number may be used to help"
                          " residents connect with you, improve ads, and more",
                    ),
                    1.0,
                    0.0,
                  );
                },
              ),

              // EMAIL ADDRESS
              CustomNavigationButton(
                textButton: "Email address",
                textColor: const Color(0xFF3C3C40),
                onPressed: () {
                  navigateWithSlideFromRight(
                    context,
                    const UserEmailAddress(
                      text:
                      "Your email address may be used to help residents "
                          "connect with you improve ads, and more. ",
                    ),
                    1.0,
                    0.0,
                  );
                },
              ),

              // LONG DESCRIPTIONS
              const CustomTextDescription(
                descriptionText:
                "Your data will be saved and display for residents "
                    "discovery purposes. Your data like name, email, phone number, "
                    "and address may be also be used to connect you to residents "
                    "that might looking for your services.",
                hasLearnMore: " Learn more",
              ),

              // SIZED BOX: SPACING
              const SizedBox(height: 10),

              // LOG OUT BUTTON
              CustomNavigationButton(
                textButton: "Sign out",
                textColor: const Color(0xFFe91b4f),
                onPressed: () {
                  showLogoutModal(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}