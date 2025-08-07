import 'package:flutter/material.dart';
import 'package:workie/values/color.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: const Color(0xFFF8F9FB),
    primary: AppColors.textDarkGrey,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.black,
  ),
);