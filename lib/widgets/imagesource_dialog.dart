import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../values/dimension.dart';

class ImageSourceDialog extends StatelessWidget {
  final String title;
  final VoidCallback? onGalleryTap;
  final VoidCallback? onCameraTap;
  final VoidCallback? onCancel;

  const ImageSourceDialog({
    super.key,
    this.title = 'Select Image Source',
    this.onGalleryTap,
    this.onCameraTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: AppDimension.paddingDefault),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onGalleryTap ?? () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
              child: Row(
                children: [
                  Icon(
                    Iconsax.image_copy,
                    color: const Color(0xFF4E6BF5),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Gallery',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ],
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onCameraTap ?? () {
                Navigator.of(context).pop(ImageSource.camera);
              },
              child: Row(
                children: [
                  Icon(
                    Iconsax.camera_copy,
                    color: const Color(0xFF4E6BF5),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Camera',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: onCancel ?? () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ),
      ],
    );
  }
}

Future<ImageSource?> showImageSourceDialog(BuildContext context, {
  String title = 'Select Image Source',
  VoidCallback? onGalleryTap,
  VoidCallback? onCameraTap,
  VoidCallback? onCancel,
}) {
  return showCupertinoDialog<ImageSource>(
    context: context,
    builder: (BuildContext context) {
      return ImageSourceDialog(
        title: title,
        onGalleryTap: onGalleryTap,
        onCameraTap: onCameraTap,
        onCancel: onCancel,
      );
    },
  );
}

// Alternative usage method that maintains the original functionality
Future<ImageSource?> showDefaultImageSourceDialog(BuildContext context) {
  return showImageSourceDialog(context);
}