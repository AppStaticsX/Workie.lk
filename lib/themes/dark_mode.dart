import 'package:flutter/material.dart';
import 'package:workie/values/color.dart';

ThemeData darkMode = ThemeData(
    colorScheme: ColorScheme.dark(
      surface: const Color(0xFF1A1A1A), //0xFF151515
      primary: AppColors.textSilver,
      secondary: const Color(0xFF0F0F0F),
      tertiary: const Color(0xFF2C2C2C),
      inversePrimary: Colors.white,
    ),
);