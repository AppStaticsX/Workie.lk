import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieDialog extends StatelessWidget {
  /// The asset path or URL for the Lottie animation
  final String lottieAsset;

  /// Optional width of the Lottie animation
  final double? width;

  /// Optional height of the Lottie animation
  final double? height;

  /// Optional fit for the Lottie animation
  final BoxFit fit;

  /// Optional repeat behavior for the animation
  final bool repeat;

  /// Optional callback when animation completes
  final void Function()? onAnimationComplete;

  /// Optional background color for the dialog
  final Color? backgroundColor;

  /// Optional border radius for the dialog
  final BorderRadius? borderRadius;

  /// Optional padding around the Lottie animation
  final EdgeInsets padding;

  const LottieDialog({
    super.key,
    required this.lottieAsset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.onAnimationComplete,
    this.backgroundColor,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(vertical: 0, horizontal: 0), // Zero horizontal padding
  });

  /// Helper method to show the dialog
  static Future<void> show({
    required BuildContext context,
    required String lottieAsset,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool repeat = true,
    void Function()? onAnimationComplete,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 0, horizontal: 0), // Zero horizontal padding
    bool barrierDismissible = true,
  }) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => LottieDialog(
        lottieAsset: lottieAsset,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        onAnimationComplete: onAnimationComplete,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        padding: padding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: backgroundColor ?? Color(0xFF262626),
          borderRadius: borderRadius ?? BorderRadius.circular(14),
        ),
        child: Padding(
          padding: padding,
          child: Lottie.asset(
            lottieAsset,
            width: 80,
            height: 80,
            fit: fit,
            repeat: repeat,
            onLoaded: onAnimationComplete != null
                ? (_) => onAnimationComplete!()
                : null,
            delegates: LottieDelegates(
                values: [
                  // You can add value delegates here if needed
                  ValueDelegate.color(['**'], value: Colors.white),
                ]
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension of LottieDialog that provides common dialog variants
extension LottieDialogExtensions on LottieDialog {
  /// Shows a loading dialog with a specified Lottie animation
  static Future<void> showLoading(
      BuildContext context, {
        String lottieAsset = 'assets/animations/splash_anim.json',
        double? width,
        double? height,
        bool barrierDismissible = false,
      }) {
    return LottieDialog.show(
      context: context,
      lottieAsset: lottieAsset,
      fit: BoxFit.contain,
      width: width,
      height: height,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Shows a success dialog with a specified Lottie animation
  static Future<void> showSuccess(
      BuildContext context, {
        String lottieAsset = 'assets/animations/success.json',
        double? width,
        double? height,
        bool repeat = false,
        Duration displayDuration = const Duration(seconds: 2),
      }) async {
    LottieDialog.show(
      context: context,
      lottieAsset: lottieAsset,
      width: width,
      height: height,
      repeat: repeat,
      barrierDismissible: false,
    );

    await Future.delayed(displayDuration);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}