import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:putatanapk/services/user_profile_service.dart';
import 'package:putatanapk/ui/screens/admin/admin_profile.dart';
import 'package:putatanapk/ui/widgets/app_bar/custom_app_bar.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/input_fields/custom_text_field.dart';
import 'package:putatanapk/ui/widgets/loading_indicator/custom_loading_indicator_v2.dart';
import 'package:putatanapk/ui/widgets/modals/custom_modal_information.dart';
import 'package:putatanapk/ui/widgets/snackbar/custom_snackbar.dart';

class UserEmailAddress extends StatefulWidget {
  final String text;

  const UserEmailAddress({
    super.key,
    required this.text,
  });

  @override
  State<UserEmailAddress> createState() => _UserEmailAddress();
}

class _UserEmailAddress extends State<UserEmailAddress> {
  final String? userID = FirebaseAuth.instance.currentUser!.uid;

  // TEXT EDITING CONTROLLER DECLARATION
  late TextEditingController _emailController;

  // FORM KEY DECLARATION
  final formKey = GlobalKey<FormState>();

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _getUserData();
    _emailController = TextEditingController();
  }

  // DISPOSE
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // METHOD THAT WILL GET THE USER DATA
  Future _getUserData() async {
    final data = await UserProfileService()
        .getUserData(userID!, 'personal_information', 'info');
    if (mounted) {
      setState(() {
        // ASSIGN THE INITIAL VALUE TO THE CONTROLLERS
        _emailController.text = data['email'] ?? '';
      });
    }
  }

  // ENCAPSULATES THE CLOSING KEYBOARD AND CALLING SUBMISSION HELPER
  void handleSubmit() {
    // CALL THE  _submitForm METHOD
    UserProfileService.updateProfileData(
      context,
      formKey,
      emailController: _emailController,
    );
    Navigator.pop(context);
    showFloatingSnackBar(
      context,
      'Data updated successfully.',
      const Color(0xFF193147),
    );
  }

  @override
  Widget build(BuildContext context) {


    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        showConfirmationModal(
          context,
          'You are about to discard this update.',
          'Discard',
          const AdminProfile(),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppBar().preferredSize.height),
          child: CustomAppBar(
            backgroundColor: Colors.white,
            titleText: "",
            onLeadingPressed: () => showConfirmationModal(
              context,
              'You are about to discard this update.',
              'Discard',
              const AdminProfile(),
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            // FORM
            Form(
              key: formKey,
              child: FutureBuilder(
                future: UserProfileService().getUserData(
                    userID!, 'personal_information', 'info'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // DISPLAY CUSTOM LOADING INDICATOR
                    return const CustomLoadingIndicator();
                  } else if (snapshot.hasError) {
                    // HANDLE ERROR IF FETCHING DATA FAILS
                    return Center(
                        child: Text('Error: ${snapshot.hasError.toString()}'));
                  } else {
                    // DISPLAY USER DATA ONCE FETCHED
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // SCREEN TITLE
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                              bottom: 5,
                            ),
                            child: const Text(
                              "Update email address",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                          ),

                          // DESCRIPTION
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 30,
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "${widget.text} ",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF8C8C8C),
                                    ),
                                  ),
                                  const TextSpan(
                                    text: "Learn more",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8C8C8C),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // LABEL: PHONE NUMBER
                          const Text(
                            "Email Address",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF242424),
                            ),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // TEXT FIELD: EMAIL ADDRESS
                          CustomTextField(
                            controller: _emailController,
                            currentFocusNode: null,
                            nextFocusNode: null,
                            keyBoardType: null,
                            inputFormatters: null,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Email is required";
                              } else if (!EmailValidator.validate(value)) {
                                return "Invalid email format";
                              }
                              return null;
                            },
                            hintText: "Enter email address",
                            minLines: 1,
                            maxLines: 1,
                            isPassword: false,
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 20),

                          // BUTTON: SAVE PHONE NUMBER
                          CustomButton(
                            buttonLabel: "Save",
                            onPressed: () {
                              if (_emailController.text.isEmpty) {
                                showFloatingSnackBar(
                                  context,
                                  'Personal information is required.',
                                  const Color(0xFFe91b4f),
                                );
                              } else {
                                handleSubmit();
                              }
                            },
                            buttonHeight: 55,
                            buttonColor: const Color(0xFF002091),
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            fontColor: Colors.white,
                            borderRadius: 10,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}