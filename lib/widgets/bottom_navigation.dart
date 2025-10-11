import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class BottomNavigation extends StatelessWidget {
  final String actionName;
  final VoidCallback onTapAction;
  final VoidCallback onBackAction;
  final bool isSaving;
  final bool isProfileEditing;

  const BottomNavigation({
    super.key,
    required this.actionName,
    required this.onTapAction,
    required this.onBackAction,
    required this.isSaving,
    required this.isProfileEditing
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSaving
                    ? Colors.grey
                    : isProfileEditing? Colors.grey : const Color(0xFF4E6BF5),
                width: 2.5
              )
            ),
            child: isProfileEditing
                ? IconButton(
              onPressed: null,
              icon: Icon(
                  Iconsax.arrow_left_2_copy,
                  color: Colors.grey
              ),
            ) : IconButton(
              onPressed: isSaving? null : onBackAction,
              icon: Icon(
                  Iconsax.arrow_left_2_copy,
                  color: isSaving
                      ? Colors.grey
                      : Theme.of(context).colorScheme.inverseSurface
              ),
            )
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: onTapAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E6BF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              child: !isSaving
                  ?Text(
                actionName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ) : Row(
                children: [
                  Transform.scale(
                    scale: 0.45, // Makes it half the size
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 9,
                        color: Colors.white,
                        strokeCap: StrokeCap.square,
                      ),
                    ),
                  ),
                  Text(
                    'Updating...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
