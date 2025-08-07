import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final String provider;

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 72,
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.tertiary,),
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.tertiary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            imagePath,
            height: 24,
          ),
          const SizedBox(width: 12),
          Text(
            provider,
            style: TextStyle(
                fontWeight: FontWeight.bold,
              fontSize: 16
            ),
          )
        ],
      ),
    );
  }
}
