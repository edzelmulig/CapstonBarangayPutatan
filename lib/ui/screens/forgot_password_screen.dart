import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/services/auth_service.dart';
import 'package:putatanapk/ui/screens/login_screen.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/images/custom_image_display.dart';
import 'package:putatanapk/ui/widgets/input_fields/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _forgotEmailController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _forgotEmailController.dispose();
    super.dispose();
  }

  void handleSubmit() {
    // CALL THE  _submitForm METHOD
    AuthService().passwordReset(
      context,
      formKey,
      _forgotEmailController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F5),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
          iconSize: 25,
        ),
        backgroundColor: const Color(0xFFF7F5F5),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 40),

                const Center(
                  child: CustomImageDisplay(
                    imageSource: "lib/ui/assets/desktop_icon.png",
                    imageHeight: 150,
                    imageWidth: 150,
                  ),
                ),
                // Forgot password text
                const Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 30),
                  child: Center(
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3C3C40),
                        ),
                      )),
                ),

                // Instruction Text
                _InstructionText(),

                const SizedBox(height: 10),

                // Email Text Field
                _EmailTextField(
                  controller: _forgotEmailController,
                  currentFocusNode: null,
                  nextFocusNode: null,
                ),

                const SizedBox(height: 12),

                // Reset Password Button
                _ResetPassswordButton(onPressed: handleSubmit),

                const SizedBox(height: 150),

                // Sign In Button
                const _SignInButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: RichText(
        text: const TextSpan(children: <TextSpan>[
          TextSpan(
            text: "Enter your email address and select ",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF3C3C40),
            ),
          ),
          TextSpan(
            text: "Reset Password.",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3C3C40),
            ),
          ),
        ]),
      ),
    );
  }
}

// Private Email Text Field Widget
class _EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? currentFocusNode;
  final FocusNode? nextFocusNode;

  const _EmailTextField({
    required this.controller,
    required this.currentFocusNode,
    required this.nextFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.07),
      child: CustomTextField(
        controller: controller,
        currentFocusNode: currentFocusNode,
        nextFocusNode: nextFocusNode,
        inputFormatters: null,
        validator: (forgotEmailController) {
          if (forgotEmailController!.isEmpty) {
            return "Email is required";
          } else if (!EmailValidator.validate(forgotEmailController)) {
            return "Invalid email format";
          }
          return null;
        },
        isPassword: false,
        hintText: "Enter your email",
        minLines: 1,
        maxLines: 1,
        prefixIcon: const Icon(Icons.email_rounded),
      ),
    );
  }
}

class _ResetPassswordButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ResetPassswordButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.07),
      child: CustomButton(
        buttonLabel: "Reset Password",
        onPressed: onPressed,
        buttonHeight: 52,
        buttonColor: const Color(0xFF002091),
        fontWeight: FontWeight.w500,
        fontSize: 14,
        fontColor: Colors.white,
        borderRadius: 50,
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Already have an account?",
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text(
              "Sign In",
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF002091),
              ),
            ),
          ),
        ],
      ),
    );
  }
}