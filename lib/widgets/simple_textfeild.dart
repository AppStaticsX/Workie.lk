import 'package:flutter/material.dart';
import '../values/color.dart';

class SimpleTextfield extends StatelessWidget {

  final TextEditingController controller;
  final String lableText;
  final String hintText;
  final Icon prefixIconData;
  final bool obscureText;
  final String? errorText; // Add error text parameter
  final String? Function(String?)? validator; // Add validator function

  const SimpleTextfield({
    super.key,
    required this.controller,
    required this.lableText,
    required this.hintText,
    required this.prefixIconData,
    required this.obscureText,
    this.errorText,
    this.validator
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            obscureText: obscureText,
            controller: controller,
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.tertiary,
              labelText: lableText,
              labelStyle: TextStyle(
                  color: AppColors.textSilver
              ),
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.hintTextSilver),
              prefixIcon: prefixIconData,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  width: 1.5,
                  color: errorText != null ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF4E6BF5), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : const Color(0xFF4E6BF5),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
            validator: validator,
          ),
          if (errorText != null && errorText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 6),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}