import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/constant.dart';
import 'package:putatanapk/services/auth_service.dart';
import 'package:putatanapk/services/image_service.dart';
import 'package:putatanapk/services/user_profile_service.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/input_fields/custom_text_field.dart';
import 'package:putatanapk/ui/widgets/snackbar/custom_snackbar.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers and FocusNode
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final phoneNumberFocusNode = FocusNode();
  final firstNameFocusNode = FocusNode();
  final middleNameFocusNode = FocusNode();
  final lastNameFocusNode = FocusNode();
  final ageFocusNode = FocusNode();
  final genderFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordNode = FocusNode();

  PlatformFile? selectedID;
  String? selectedValue;

  // LIST FOR SERVICE TYPE
  final List<String> genderOption = [
    'Male',
    'Female',
  ];

  final formKey = GlobalKey<FormState>();

  late final String phoneNumber;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPhoneNumber();
  }

  void fetchPhoneNumber() async {
    setState(() {
      isLoading = true;
    });

    try {
      final adminInfo = await UserProfileService().getUserData(
          "S8MzJ63zKrXni5rcrXSJ5pyoqvQ2", "personal_information", "info");

      if (mounted) {
        setState(() {
          String phone = adminInfo['phoneNumber'] ?? '';

          // Remove the leading '0' (if present) and prefix with '63'
          if (phone.startsWith('0')) {
            phone = phone.substring(1); // Remove the leading '0'
          }

          // Now format it with '63' country code
          phoneNumber = '63$phone';

          debugPrint("==== $phoneNumber");
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user services: $e');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneNumberController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    genderController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailFocusNode.dispose();
    phoneNumberFocusNode.dispose();
    firstNameFocusNode.dispose();
    middleNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    ageFocusNode.dispose();
    genderFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordNode.dispose();
    super.dispose();
  }

  // Front picture ID
  Future<void> imageIDSelection() async {
    final selected = await ImageService.selectImage();
    if (selected != null) {
      setState(() {
        selectedID = selected;
      });
    }
  }

  // Create Account
  Future<void> createAccount() async {
    try {
      debugPrint(emailController.text);
      debugPrint(firstNameController.text);
      debugPrint(middleNameController.text);
      debugPrint(lastNameController.text);
      debugPrint(ageController.text);
      debugPrint(genderController.text);
      debugPrint(selectedID.toString());

      if (selectedID == null) {
        showFloatingSnackBar(
          context,
          "Please upload a valid ID picture",
          const Color(0xFFe91b4f),
        );
        return;
      }

      await AuthService.signUp(
        context: context,
        email: emailController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        firstName: firstNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        age: double.tryParse(ageController.text) ?? 0,
        gender: genderController.text.trim(),
        password: passwordController.text.trim(),
        idPicture: selectedID,
      );

      // SEND MESSAGE TO THE SERVICE PROVIDER
      final Map<String, dynamic> requestData = {
        'recipient': phoneNumber,
        'sender_id': 'PhilSMS',
        'type': 'plain',
        'message': "New user account created: \n\n ${firstNameController.text.toUpperCase()} ${middleNameController.text.toUpperCase()} ${lastNameController.text.toUpperCase()} \n\n"
            'Kindly refer for your Barangay Putatan Application for further details. Thank you.',
      };

      const String apiUrl = 'https://app.philsms.com/api/v3/sms/send';

      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': smsAPI,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(requestData),
      );



    } catch (error) {
      debugPrint("Error during sign up: ${error.toString()}");
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error creating account: ${error.toString()}",
          const Color(0xFFe91b4f),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: _AppBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 15),

            // Instruction Text
            _InstructionText(),

            const SizedBox(height: 15),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFFEFF0F3),
                  foregroundColor: const Color(0xFFBDBDC7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(
                    color: Color(0xFFBDBDC7),
                    width: 1.5,
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 110),
                ),
                onPressed: () {
                  if (selectedID == null) {
                    imageIDSelection();
                  }
                },
                child: selectedID != null
                    ? Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(selectedID!.path!),
                              width: double.infinity,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedID = null;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                child: const Icon(
                                  Icons.clear_rounded,
                                  color: Color(0xFFF5F5F5),
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.add_a_photo_rounded,
                              color: Colors.grey,
                            ),
                            Text(
                              "Front ID Picture",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: CustomTextField(
                controller: emailController,
                currentFocusNode: emailFocusNode,
                nextFocusNode: phoneNumberFocusNode,
                keyBoardType: null,
                inputFormatters: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Email is required";
                  }
                  return null;
                },
                hintText: "Email",
                minLines: 1,
                maxLines: 1,
                isPassword: false,
                prefixIcon: null,
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: CustomTextField(
                controller: phoneNumberController,
                currentFocusNode: phoneNumberFocusNode,
                nextFocusNode: firstNameFocusNode,
                keyBoardType: null,
                inputFormatters: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Contact No. is required";
                  }
                  return null;
                },
                hintText: "Phone Number",
                minLines: 1,
                maxLines: 1,
                isPassword: false,
                prefixIcon: null,
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: CustomTextField(
                controller: firstNameController,
                currentFocusNode: firstNameFocusNode,
                nextFocusNode: middleNameFocusNode,
                keyBoardType: null,
                inputFormatters: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "First name is required";
                  }
                  return null;
                },
                hintText: "First Name",
                minLines: 1,
                maxLines: 1,
                isPassword: false,
                prefixIcon: null,
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: CustomTextField(
                controller: middleNameController,
                currentFocusNode: middleNameFocusNode,
                nextFocusNode: lastNameFocusNode,
                keyBoardType: null,
                inputFormatters: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Middle name is required";
                  }
                  return null;
                },
                hintText: "Middle Name",
                minLines: 1,
                maxLines: 1,
                isPassword: false,
                prefixIcon: null,
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: CustomTextField(
                controller: lastNameController,
                currentFocusNode: lastNameFocusNode,
                nextFocusNode: ageFocusNode,
                keyBoardType: null,
                inputFormatters: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Last name is required";
                  }
                  return null;
                },
                hintText: "Last Name",
                minLines: 1,
                maxLines: 1,
                isPassword: false,
                prefixIcon: null,
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: CustomTextField(
                controller: ageController,
                currentFocusNode: ageFocusNode,
                nextFocusNode: genderFocusNode,
                keyBoardType: TextInputType.number,
                inputFormatters: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Age is required";
                  }
                  return null;
                },
                hintText: "Age",
                minLines: 1,
                maxLines: 1,
                isPassword: false,
                prefixIcon: null,
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: DropdownButtonFormField2<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF002091),
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFe91b4f),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFe91b4f),
                      width: 2.0,
                    ),
                  ),
                  fillColor: const Color(0xFFEFF0F3),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFBDBDC7),
                      // Set color for enabled state
                      width: 1.5, // Set width for enabled state
                    ),
                  ),
                ),
                hint: const Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF6c7687),
                  ),
                ),
                items: genderOption
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF3C3C40),
                            ),
                          ),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select gender.';
                  }
                  return null;
                },
                onChanged: (value) {
                  // //Do something when selected item is changed.
                  setState(() {
                    selectedValue = value.toString();
                    genderController.text = value.toString();
                  });
                },
                onSaved: (value) {
                  genderController.text = value.toString();
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.only(right: 15),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF3C3C40),
                  ),
                  iconSize: 26,
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 17),
                ),
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: CustomTextField(
                controller: passwordController,
                currentFocusNode: passwordFocusNode,
                nextFocusNode: confirmPasswordNode,
                keyBoardType: null,
                inputFormatters: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Password is required";
                  }
                  return null;
                },
                hintText: "Password",
                minLines: 1,
                maxLines: 1,
                isPassword: false,
                prefixIcon: null,
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07),
              child: CustomTextField(
                controller: confirmPasswordController,
                currentFocusNode: confirmPasswordNode,
                nextFocusNode: null,
                keyBoardType: null,
                inputFormatters: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Confirm Password is required";
                  }
                  return null;
                },
                hintText: "Confirm Password",
                minLines: 1,
                maxLines: 1,
                isPassword: false,
                prefixIcon: null,
              ),
            ),

            const SizedBox(height: 20),

            _CreateAccountButton(onPressed: createAccount),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios_new),
        iconSize: 25,
      ),
      title: const Text(
        "Create Account",
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: Color(0xFF222227),
          letterSpacing: 1.0,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
    );
  }
}

class _InstructionText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      child: Align(
        alignment: Alignment.center,
        child: RichText(
          text: const TextSpan(children: <TextSpan>[
            TextSpan(
              text:
                  "To be eligible for approval, you must be a registered resident of ",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF3C3C40),
              ),
            ),
            TextSpan(
              text: "Barangay Putatan.",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3C3C40),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateAccountButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.07),
      child: CustomButton(
        buttonLabel: "Create Account",
        onPressed: onPressed,
        buttonHeight: 55,
        buttonColor: const Color(0xFF002091),
        fontWeight: FontWeight.w500,
        fontSize: 14,
        fontColor: Colors.white,
        borderRadius: 50,
      ),
    );
  }
}
