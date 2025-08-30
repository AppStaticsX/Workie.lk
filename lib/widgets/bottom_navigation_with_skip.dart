import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class BottomNavigationWithSkip extends StatelessWidget {
  final String actionName;
  final VoidCallback onTapAction;
  final VoidCallback onBackAction;
  final VoidCallback onSkip;

  const BottomNavigationWithSkip({
    super.key,
    required this.actionName,
    required this.onTapAction,
    required this.onBackAction,
    required this.onSkip
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF4E6BF5),
                    width: 2.5
                )
            ),
            child: IconButton(
              onPressed: onBackAction,
              icon: const Icon(Iconsax.arrow_left_2_copy),
            ),
          ),
          TextButton(
              onPressed: onSkip,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Color(0xFF4E6BF5),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              )
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: onTapAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E6BF5),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              child: Text(
                actionName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
