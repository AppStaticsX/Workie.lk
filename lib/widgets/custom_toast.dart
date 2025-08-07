import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomToastSuccess {
  static final FToast _fToast = FToast();

  /// Initialize FToast with context (Call this inside `initState` or `build`)
  static void init(BuildContext context) {
    _fToast.init(context);
  }

  /// Function to show the custom toast
  static void show(String message, String svgPath, {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black87,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgPath, // Change this to your SVG icon
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: gravity, // Position (TOP, CENTER, BOTTOM)
      toastDuration: const Duration(seconds: 3), // Duration
    );
  }
}

