import 'package:flutter/material.dart';

class SimpleBottomNavigation extends StatelessWidget {
  final String actionName;
  final VoidCallback onTapAction;

  const SimpleBottomNavigation({
    super.key,
    required this.actionName,
    required this.onTapAction,
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: onTapAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E6BF5),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            child: Text(
              actionName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}