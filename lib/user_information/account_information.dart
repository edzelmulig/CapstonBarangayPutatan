import 'dart:async';

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

class UserAccountInformation extends StatefulWidget {
  final String text;

  const UserAccountInformation({
    super.key,
    required this.text,
  });

  @override
  State<UserAccountInformation> createState() => _UserAccountInformation();
}

class _UserAccountInformation extends State<UserAccountInformation> {
  final String? userID = FirebaseAuth.instance.currentUser!.uid;

  // TEXT EDITING CONTROLLER DECLARATION
  late TextEditingController _displayNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _accountNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _creditCardNumberController;

  // FORM KEY DECLARATION
  final formKey = GlobalKey<FormState>();

  // FOCUS NODE DECLARATION
  final _displayNameFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _accountNameFocusNode = FocusNode();
  final _accountNumberFocusNode = FocusNode();
  final _creditCardFocusNode = FocusNode();

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _getUserData();
    _displayNameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _accountNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _creditCardNumberController = TextEditingController();
  }

  // DISPOSE
  @override
  void dispose() {
    _displayNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _accountNameFocusNode.dispose();
    _accountNumberFocusNode.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _creditCardNumberController.dispose();
    _creditCardFocusNode.dispose();
    super.dispose();
  }

  // METHOD THAT WILL GET THE USER DATA
  Future _getUserData() async {
    final data = await UserProfileService()
        .getUserData(userID!, 'personal_information', 'info');
    if (mounted) {
      setState(() {
        // ASSIGN THE INITIAL VALUE TO THE CONTROLLERS
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _displayNameController.text = data['displayName'] ?? '';
        _accountNameController.text = data['accountName'] ?? '';
        _accountNumberController.text = data['accountNumber'] ?? '';
        _creditCardNumberController.text = data['creditCardNumber'] ?? '';
      });
    }
  }

  // ENCAPSULATES THE CLOSING KEYBOARD AND CALLING SUBMISSION HELPER
  void handleSubmit() {
    // CLOSE THE KEYBOARD
    FocusScope.of(context).unfocus();

    // CALL THE  _submitForm METHOD
    UserProfileService.updateProfileData(
      context,
      formKey,
      displayNameController: _displayNameController,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      accountNameController: _accountNameController,
      accountNumberController: _accountNumberController,
      creditCardNumberController: _creditCardNumberController,
    );
    Navigator.pop(context);
    showFloatingSnackBar(
      context,
      'Data updated successfully.',
      const Color(0xFF002091),
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
            titleText: "Account information",
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
                future: UserProfileService()
                    .getUserData(userID!, 'personal_information', 'info'),
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
                              "Personal Information",
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
                              bottom: 25,
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

                          // ACCOUNT INFORMATION
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // LABEL: DISPLAY NAME
                              const Text(
                                "Display Name",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF242424),
                                ),
                              ),

                              // SIZED BOX: SPACING
                              const SizedBox(height: 2),

                              // TEXT FIELD: DISPLAY NAME
                              CustomTextField(
                                controller: _displayNameController,
                                currentFocusNode: _displayNameFocusNode,
                                nextFocusNode: _firstNameFocusNode,
                                keyBoardType: null,
                                inputFormatters: null,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Display name is required";
                                  }
                                  return null;
                                },
                                hintText: "Enter display name",
                                minLines: 1,
                                maxLines: 1,
                                isPassword: false,
                              ),

                              // SIZED BOX: SPACING
                              const SizedBox(height: 10),

                              // LABEL: FIRST NAME
                              const Text(
                                "First Name",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF242424),
                                ),
                              ),

                              // SIZED BOX: SPACING
                              const SizedBox(height: 2),

                              // TEXT FIELD: FIRST NAME
                              CustomTextField(
                                controller: _firstNameController,
                                currentFocusNode: _firstNameFocusNode,
                                nextFocusNode: _lastNameFocusNode,
                                keyBoardType: null,
                                inputFormatters: null,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "First name is required";
                                  }
                                  return null;
                                },
                                hintText: "Enter your first name",
                                minLines: 1,
                                maxLines: 1,
                                isPassword: false,
                              ),

                              // SIZED BOX: SPACING
                              const SizedBox(height: 10),

                              // LABEL: LAST NAME
                              const Text("Last Name",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF242424),
                                ),
                              ),
                              // SIZED BOX: SPACING
                              const SizedBox(height: 2),

                              // TEXT FIELD: LAST NAME
                              CustomTextField(
                                controller: _lastNameController,
                                currentFocusNode: _lastNameFocusNode,
                                nextFocusNode: null,
                                keyBoardType: null,
                                inputFormatters: null,
                                validator: (value) {
                                  if (value!.isEmpty && value == '') {
                                    return "Last name is required";
                                  }
                                  return null;
                                },
                                hintText: "Enter your last name",
                                minLines: 1,
                                maxLines: 1,
                                isPassword: false,
                              ),
                            ],
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: ACCOUNT NAME
                          const Text(
                            "GCash Account Name",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF242424),
                            ),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // TEXT FIELD: GCASH ACCOUNT NAME
                          CustomTextField(
                            controller: _accountNameController,
                            currentFocusNode: _accountNameFocusNode,
                            nextFocusNode: _accountNumberFocusNode,
                            keyBoardType: null,
                            inputFormatters: null,
                            validator: (value) {
                              if (value!.isEmpty && value == '') {
                                return "GCash account name is required";
                              }
                              return null;
                            },
                            hintText: "e.g Juan Dela Cruz",
                            minLines: 1,
                            maxLines: 1,
                            isPassword: false,
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: ACCOUNT NAME
                          const Text(
                            "GCash Account No.",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF242424),
                            ),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // TEXT FIELD: GCASH ACCOUNT NUMBER
                          CustomTextField(
                            controller: _accountNumberController,
                            currentFocusNode: _accountNumberFocusNode,
                            nextFocusNode: _creditCardFocusNode,
                            keyBoardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9]+$')),
                            ],
                            validator: (value) {
                              if (value!.isEmpty && value == '') {
                                return "GCash account number is required";
                              }
                              return null;
                            },
                            hintText: "e.g 09123456789",
                            minLines: 1,
                            maxLines: 1,
                            isPassword: false,
                          ),

                          const SizedBox(height: 10),

                          // LABEL: ACCOUNT NAME
                          const Text(
                            "Credit Card Account No.",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF242424),
                            ),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // TEXT FIELD: GCASH ACCOUNT NUMBER
                          CustomTextField(
                            controller: _creditCardNumberController,
                            currentFocusNode: _creditCardFocusNode,
                            nextFocusNode: null,
                            keyBoardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9]+$')),
                            ],
                            validator: (value) {
                              if (value!.isEmpty && value == '') {
                                return "Credit Card number is required";
                              }
                              return null;
                            },
                            hintText: "xxx xxx xxx",
                            minLines: 1,
                            maxLines: 1,
                            isPassword: false,
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 20),

                          // BUTTON: SAVE INFORMATION
                          CustomButton(
                            buttonLabel: "Save",
                            onPressed: () {
                              if (_displayNameController.text.isEmpty ||
                                  _firstNameController.text.isEmpty ||
                                  _lastNameController.text.isEmpty ||
                                  _accountNameController.text.isEmpty ||
                                  _accountNumberController.text.isEmpty) {
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
