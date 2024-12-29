import 'package:flutter/material.dart';
import 'package:putatanapk/services/auth_service.dart';
import 'package:putatanapk/ui/screens/forgot_password_screen.dart';
import 'package:putatanapk/ui/screens/sign_up_screen.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/images/custom_image_display.dart';
import 'package:putatanapk/ui/widgets/input_fields/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers and Focus Nodes
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  // Form Key
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }


  // FUNCTION TO AUTHENTICATE LOGIN
  Future<void> _login() async {
    // CONTROLLER
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // AUTHENTICATE ADMIN ACCOUNT
    await AuthService.signIn(
      context: context,
      email: email,
      password: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 15),
            // App Logo
            Center(
              child: CustomImageDisplay(
                imageSource: "lib/ui/assets/barangay_putatan_icon.png",
                imageHeight: screenHeight * 0.45,
                imageWidth: screenWidth * 0.45,
              ),
            ),

            // Form
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Email Text Field
                  _EmailTextField(
                    controller: emailController,
                    currentFocusNode: emailFocusNode,
                    nextFocusNode: passwordFocusNode,
                  ),

                  const SizedBox(height: 8),

                  // Password Text Field
                  _PasswordTextField(
                    controller: passwordController,
                    currentFocusNode: passwordFocusNode,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Login Button
            _LoginButton(onPressed: _login),

            const SizedBox(height: 5),

            // Forgot Password Button
            const _ForgotPasswordButton(),

            const SizedBox(height: 100),

            // Sign Up Button
            const _SignUpButton(),
          ],
        ),
      ),
    );
  }
}

// Private Email Text Field Widget
class _EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode currentFocusNode;
  final FocusNode nextFocusNode;

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
        validator: (value) {
          if (value!.isEmpty) {
            return "Email or Phone number cannot be empty";
          }
          return null;
        },
        isPassword: false,
        hintText: "Email or Phone number",
        minLines: 1,
        maxLines: 1,
        prefixIcon: const Icon(Icons.email_rounded),
      ),
    );
  }
}

// Private Password Text Field Widget
class _PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode currentFocusNode;

  const _PasswordTextField({
    required this.controller,
    required this.currentFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.07),
      child: CustomTextField(
        controller: controller,
        currentFocusNode: currentFocusNode,
        nextFocusNode: null,
        inputFormatters: null,
        validator: (value) {
          if (value!.isEmpty) {
            return "Password is required";
          }
          return null;
        },
        isPassword: true,
        hintText: "Password",
        minLines: 1,
        maxLines: 1,
        prefixIcon: const Icon(Icons.lock_rounded),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LoginButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.07),
      child: CustomButton(
        buttonLabel: "Sign In",
        onPressed: onPressed,
        buttonColor: const Color(0xFF002091),
        buttonHeight: 55.0,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        fontColor: Colors.white,
        borderRadius: 50,
      ),
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
        ),
        onPressed: () {
          // Navigate to forgot password page
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ForgotPasswordScreen()),
          );
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 13.0,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Don't have an account?",
            style: TextStyle(
              fontSize: 15.0,
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
                  builder: (context) => const SignUpScreen(),
                ),
              );
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002091),
              ),
            ),
          ),
        ],
      ),
    );
  }
}