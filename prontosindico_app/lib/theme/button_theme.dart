import 'package:flutter/material.dart';

import '../constants.dart';

ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding * 1.2),
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 56),
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadious)),
    ),
  ),
);

OutlinedButtonThemeData outlinedButtonTheme(
    {Color borderColor = blackColor10}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding * 1.2),
      minimumSize: const Size(double.infinity, 56),
      side: BorderSide(width: 1.5, color: borderColor),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadious)),
      ),
    ),
  );
}

final textButtonThemeData = TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: primaryColor,
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  ),
);
