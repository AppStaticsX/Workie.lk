import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/material.dart';

class FullScreenPopupDialog extends StatelessWidget {
  final String darkLottie;
  final String lightLottie;
  final String title;
  final String subTitle;

  const FullScreenPopupDialog({
    super.key,
    required this.darkLottie,
    required this.lightLottie,
    required this.title,
    required this.subTitle
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            Theme.of(context).brightness == Brightness.dark
                ? darkLottie
                : lightLottie
          ),
          Text(
            textAlign: TextAlign.center,
            title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inverseSurface
            ),
          ),
          Text(
            textAlign: TextAlign.center,
            subTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface
            ),
          )
        ],
      ),
    );
  }
}
