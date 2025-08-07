import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData iconData;
  final double width;
  final double height;
  final double size;
  final Color color;
  final Color? iconColor;

  const CustomIconButton({
    super.key,
    required this.iconData,
    required this.size,
    required this.width,
    required this.height,
    required this.color,
    this.iconColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8)
      ),
      width: width,
      height: height,
      child: Icon(iconData, size: size, color: iconColor),
    );
  }
}
