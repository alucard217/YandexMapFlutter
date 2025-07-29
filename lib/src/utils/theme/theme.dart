import 'package:flutter/material.dart';

class AppThemes {

static final ThemeData lightThemeDefault = ThemeData.light();
static final ThemeData darkThemeDefault = ThemeData.dark();

ThemeData customLightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    secondary: Colors.grey.shade100,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
  ),
);

ThemeData customDarkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    secondary: Colors.grey.shade700,
    tertiary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade300,
  ),
);
}
