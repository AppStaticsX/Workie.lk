import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/services/profile_service.dart';
import 'package:workie/widgets/dashed_photo_picker.dart';
import 'dart:typed_data';

import 'custom_dashed_photo_picker.dart';

class ProfilePicBottomsheet extends StatefulWidget {
  final VoidCallback closeBottomSheet;
  final Function(File?, Uint8List?, double? , double?)? onImageAttached;
  final String? currentImageUrl;

  const ProfilePicBottomsheet({
    super.key,
    required this.closeBottomSheet,
    this.onImageAttached,
    this.currentImageUrl,
  });

  @override
  State<ProfilePicBottomsheet> createState() => _ProfilePicBottomsheetState();
}

class _ProfilePicBottomsheetState extends State<ProfilePicBottomsheet> {

  bool _hasImage = false;
  double _imgScale = 1;
  double _imgAngle = 0;
  File? _selectedImage;
  Uint8List? _webImageBytes;
  bool _showCurrentImage = true;

  final GlobalKey<CustomDashedPhotoPickerState> _photoPickerKey = GlobalKey<CustomDashedPhotoPickerState>();

  @override
  void initState() {
    super.initState();
    // If there's a current image URL, set hasImage to true initially
    if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty) {
      _hasImage = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Safe setState that checks if widget is still mounted and not in build phase
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(fn);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12)
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildBodyFields(context)
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              'Your Photo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold
              )
          ),
          IconButton(
              onPressed: widget.closeBottomSheet,
              icon: const Icon(
                Icons.close,
                size: 28,
              )
          )
        ],
      ),
    );
  }

  Widget _buildBodyFields(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  CustomDashedPhotoPicker(
                    key: _photoPickerKey,
                    initialNetworkImage: widget.currentImageUrl, // Pass the current image URL
                    hasImage: (hasImage) {
                      _safeSetState(() {
                        _hasImage = hasImage;
                      });
                    },
                    onImageSelected: (file) {
                      _selectedImage = file;
                    },
                    onFileSelected: (path) {
                      // Use addPostFrameCallback to safely update state after build is complete
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _photoPickerKey.currentState != null) {
                          final state = _photoPickerKey.currentState!;
                          if (kIsWeb) {
                            // Access the private field safely
                            try {
                              final webBytes = (state as dynamic)._webImageBytes;
                              _safeSetState(() {
                                _webImageBytes = webBytes;
                              });
                            } catch (e) {
                              // Fallback - could also use reflection or make field public
                              if (kDebugMode) {
                                print('Could not access web image bytes: $e');
                              }
                            }
                          }
                        }
                      });
                    },
                    backgroundColor: Colors.transparent,
                    iconColor: Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.5),
                    borderColor: Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.5),
                    fit: BoxFit.none,
                    scale: _imgScale,
                    angle: _imgAngle,
                  ),
                  const SizedBox(height: 16),
                  (_selectedImage != null || _webImageBytes != null)
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.search_zoom_in_1_copy,
                        size: 28,
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                      _buildImageScaler(),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _imgAngle = _imgAngle + 90;
                            });
                          },
                          icon: Icon(
                              Iconsax.refresh
                          )
                      )
                    ],
                  )
                      : const SizedBox(height: 16),
                  _hasImage
                      ? _buildImageDeleteButton()
                      : _buildImageLimit(),
                  const SizedBox(height: 24),
                  _buildAlertText(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Column(
            children: [
              _buildBottomActionButtons(),
              const SizedBox(height: 24)
            ],
          ),
        ],
      ),
    );
  }

  Text _buildImageLimit() {
    return Text(
      '250x250 Min / 5 MB Max',
      style: TextStyle(
          fontSize: 16,
          color: Colors.grey
      ),
    );
  }

  Widget _buildImageScaler() {
    return Slider(
      value: _imgScale,
      min: 1,
      max: 2,
      thumbColor: const Color(0xFF4E6BF5),
      activeColor: const Color(0xFF4E6BF5),
      inactiveColor: Theme.of(context).colorScheme.tertiary,
      onChanged: (double value) {
        setState(() {
          _imgScale = value;
        });
      },
    );
  }


  Widget _buildImageDeleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextButton(
          onPressed: () {
            _photoPickerKey.currentState?.clearImage();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.delete,
                  size: 22,
                  color: const Color(0xFF4E6BF5),
                ),
                const SizedBox(width: 12),
                Text(
                  'Delete current Image',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF4E6BF5),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }

  Padding _buildAlertText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Must be an actual photo of you.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Google Sans',
                color: Colors.grey,
              ),
            ),
            TextSpan(
              text: '\nLogos, clip-art, group photos, and digitally-altered images',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Google Sans',
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: ' are not allowed. It will cause account ',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Google Sans',
                color: Colors.grey,
              ),
            ),
            TextSpan(
              text: 'Rejection',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Google Sans',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' or ',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Google Sans',
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.normal,
              ),
            ),
            TextSpan(
              text: 'Termination.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Google Sans',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold
                )
            )
        ),
        const SizedBox(width: 24),
        ElevatedButton(
          onPressed: (_selectedImage != null || _webImageBytes != null) ? () async {
            // Generate a filename based on current timestamp
            final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

            try {
              // Show loading indicator (optional)
              // You might want to add a loading state here

              // Upload the profile picture
              final result = await ProfileService.uploadProfilePicture(
                imageFile: _selectedImage,
                imageBytes: _webImageBytes,
                fileName: fileName,
              );

              if (result != null) {
                // Success - pass image data with scale to parent and close
                widget.onImageAttached?.call(_selectedImage, _webImageBytes, _imgScale, _imgAngle);

                // Show success message (optional)
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile picture uploaded successfully!')),
                  );
                }

                // Close the bottom sheet
                if (mounted) {
                  Navigator.pop(context);
                }
              } else {
                // Handle upload failure
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to upload profile picture. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              // Handle any errors during upload
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E6BF5),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          child: Text(
              'Upload Photo',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold
              )
          ),
        ),
      ],
    );
  }
}