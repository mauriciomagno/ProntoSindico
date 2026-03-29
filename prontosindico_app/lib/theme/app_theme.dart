import 'package:flutter/material.dart';
import 'package:prontosindico/theme/button_theme.dart';
import 'package:prontosindico/theme/input_decoration_theme.dart';

import '../constants.dart';
import 'checkbox_themedata.dart';
import 'theme_data.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: "Plus Jakarta",
      colorSchemeSeed: primaryColor,
      scaffoldBackgroundColor: backgroundLightColor,
      iconTheme: const IconThemeData(color: blackColor),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: blackColor60),
        bodyLarge: TextStyle(color: blackColor),
        displayLarge: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: lightInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarLightTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableLightThemeData,
      cardTheme: const CardTheme(
        elevation: 2, // Subtle elevation
        shadowColor: Color(0x1A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadious)),
          side:
              BorderSide.none, // Remove border for cleaner look with elevation
        ),
        color: whiteColor,
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: "Plus Jakarta",
      colorSchemeSeed: primaryColor,
      scaffoldBackgroundColor: backgroundDarkColor,
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: blackColor20),
        bodyLarge: TextStyle(color: Colors.white),
        displayLarge:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(borderColor: blackColor80),
      inputDecorationTheme: darkInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarDarkTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableDarkThemeData,
      cardTheme: const CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadious)),
          side: BorderSide(color: blackColor80),
        ),
        color: blackColor,
      ),
    );
  }
}
