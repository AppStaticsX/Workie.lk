import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../values/color.dart';

class SimpleTextfield extends StatelessWidget {

  final TextEditingController controller;
  final String? lableText;
  final String hintText;
  final int maxLines;
  final Icon? prefixIconData;
  final double paddingHorizontal;
  final bool obscureText;
  final String? errorText;
  final String? Function(String?)? validator;
  final Color focusBorderColor;

  const SimpleTextfield({
    super.key,
    required this.controller,
    this.lableText,
    required this.hintText,
    this.prefixIconData,
    required this.obscureText,
    this.errorText,
    this.validator,
    required this.paddingHorizontal,
    required this.maxLines,
    required this.focusBorderColor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(99),
            ],
            maxLines: maxLines,
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
                borderSide: BorderSide(color: focusBorderColor, width: 2),
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