import 'package:flutter/material.dart';

const MaterialColor customThemePrimary = MaterialColor(_customThemePrimaryValue, <int, Color>{
  50: Color(0xFFE0E6F7), // Lightest shade (10% opacity)
  100: Color(0xFFB3BFEA), // Lighter shade
  200: Color(0xFF8094DD), // Light shade
  300: Color(0xFF4D68D0), // Light-medium shade
  400: Color(0xFF2646C7), // Medium shade
  500: Color(_customThemePrimaryValue), // Primary color
  600: Color(0xFF001E83), // Slightly darker
  700: Color(0xFF00196E), // Darker
  800: Color(0xFF00145A), // Even darker
  900: Color(0xFF000D39), // Darkest shade
});
const int _customThemePrimaryValue = 0xFF002091;

const MaterialColor customThemeAccent = MaterialColor(_customThemeAccentValue, <int, Color>{
  100: Color(0xFFD6E0FF), // Light accent shade
  200: Color(_customThemeAccentValue), // Accent color
  400: Color(0xFF8094FF), // Stronger accent
  700: Color(0xFF4D68FF), // Boldest accent
});
const int _customThemeAccentValue = 0xFFB3C6FF;
