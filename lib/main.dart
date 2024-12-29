import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/color_theme.dart';
import 'package:putatanapk/services/auth_gate.dart';
import 'firebase_options.dart';

// Main function of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// Handles the navigation to landing page.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: customThemePrimary,
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Color(0xFF002091),
              selectionColor: Color(0xFF002091),
              selectionHandleColor: Color(0xFF002091),
            )
        ),
        home: const AuthGate());
  }
}