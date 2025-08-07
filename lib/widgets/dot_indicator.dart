import 'package:flutter/material.dart';

class DotIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double spacing;
  final Function(int)? onDotTapped;

  const DotIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.grey,
    this.dotSize = 8.0,
    this.spacing = 8.0,
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
            (index) => GestureDetector(
          onTap: () => onDotTapped?.call(index),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: spacing / 2),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentIndex ? activeColor : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }
}