import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/services/profile_service.dart';
import 'package:workie/widgets/dashed_photo_picker.dart';
import 'dart:typed_data';

import 'custom_dashed_cover_photo_picker.dart';
import 'custom_dashed_photo_picker.dart';

class CoverPicBottomsheet extends StatefulWidget {
  final VoidCallback closeBottomSheet;
  final Function(File?, Uint8List?)? onImageAttached;
  final String? currentImageUrl;

  const CoverPicBottomsheet({
    super.key,
    required this.closeBottomSheet,
    this.onImageAttached,
    this.currentImageUrl,
  });

  @override
  State<CoverPicBottomsheet> createState() => _CoverPicBottomsheetState();
}

class _CoverPicBottomsheetState extends State<CoverPicBottomsheet> {

  bool _hasImage = false;
  File? _selectedImage;
  Uint8List? _webImageBytes;
  bool _showCurrentImage = true;

  final GlobalKey<CustomDashedCoverPhotoPickerState> _photoPickerKey = GlobalKey<CustomDashedCoverPhotoPickerState>();

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
              'Cover Photo',
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
                  CustomDashedCoverPhotoPicker(
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
                  ),
                  (_selectedImage != null || _webImageBytes != null)
                      ? const SizedBox(height: 16)
                      : const SizedBox(height: 12),
                  _hasImage
                      ? _buildImageDeleteButton()
                      : _buildImageLimit(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildBottomActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Text _buildImageLimit() {
    return Text(
      '1584 X 396 Min / 5 MB Max',
      style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
      ),
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

  Widget _buildBottomActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF353535),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              )
          ),
        ),
        const SizedBox(width: 24),
        ElevatedButton(
          onPressed: (_selectedImage != null || _webImageBytes != null) ? () async {
            // Generate a filename based on current timestamp
            final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg';

            try {
              // Show loading indicator (optional)
              // You might want to add a loading state here

              // Upload the cover photo
              final result = await ProfileService.uploadCoverPhoto(
                imageFile: _selectedImage,
                imageBytes: _webImageBytes,
                fileName: fileName,
              );

              if (result != null) {
                // Success - pass image data to parent and close
                widget.onImageAttached?.call(_selectedImage, _webImageBytes);

                // Show success message (optional)
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cover photo uploaded successfully!')),
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
                      content: Text('Failed to upload cover photo. Please try again.'),
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