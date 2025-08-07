import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../values/color.dart';

class SimplePrefixTextfield extends StatelessWidget {

  final TextEditingController controller;
  final String lableText;
  final String hintText;
  final String suffixText;
  final Icon prefixIconData;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final String? Function(String?)? validator;

  const SimplePrefixTextfield({
    super.key,
    required this.controller,
    required this.lableText,
    required this.hintText,
    required this.prefixIconData,
    required this.obscureText,
    required this.suffixText,
    required this.keyboardType,
    this.errorText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(9),
            ],
            keyboardType: keyboardType,
            obscureText: obscureText,
            controller: controller,
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold
            ),
            decoration: InputDecoration(
              labelText: lableText,
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSilver
              ),
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.hintTextSilver),
              prefixIcon: prefixIconData,
              prefixText: suffixText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  width: 2,
                  color: errorText != null ? Colors.red : Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : const Color(0xFF4E6BF5),
                  width: 2.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
            validator: validator,
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12
              ),
            ),
          ),
      ],
    );
  }
}