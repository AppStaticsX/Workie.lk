import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class DashedPhotoPicker extends StatefulWidget {
  final VoidCallback? onTap;
  final Function(String)? onFileSelected;
  final Function(File?)? onImageSelected; // New callback for selected image
  final Function(bool)? hasImage;
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color uploadTextColor;
  final Color errorTextColor;
  final BoxFit fit;
  final double scale;

  const DashedPhotoPicker({
    super.key,
    this.onTap,
    this.onFileSelected,
    this.onImageSelected,
    this.size = 300,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    this.textColor = Colors.grey,
    this.uploadTextColor = const Color(0xFF4E6BF5),
    this.errorTextColor = Colors.red,
    this.hasImage,
    required this.fit,
    required this.scale,
  });

  @override
  State<DashedPhotoPicker> createState() => DashedPhotoPickerState();
}

class DashedPhotoPickerState extends State<DashedPhotoPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  String? _errorMessage;
  File? _selectedImage;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        await _validateAndSetImage(image);
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  Future<void> _validateAndSetImage(XFile image) async {
    try {
      // Check file size (5MB limit)
      final int fileSize = await image.length();
      const int maxSizeInBytes = 5 * 1024 * 1024; // 5MB

      if (fileSize > maxSizeInBytes) {
        setState(() {
          _errorMessage = 'Image size must be less than 5MB. Current size: ${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
        });
        widget.hasImage?.call(false);
        return;
      }

      // Get image dimensions
      final Uint8List imageBytes = await image.readAsBytes();
      final Image imageWidget = Image.memory(imageBytes);

      // For web platform
      if (kIsWeb) {
        // We need to decode the image to get dimensions on web
        final imageProvider = MemoryImage(imageBytes);
        final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
        final completer = Completer<ImageInfo>();
        late ImageStreamListener listener;

        listener = ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info);
          stream.removeListener(listener);
        });

        stream.addListener(listener);
        final ImageInfo imageInfo = await completer.future;

        final int width = imageInfo.image.width;
        final int height = imageInfo.image.height;

        if (width < 250 || height < 250) {
          setState(() {
            _errorMessage = 'Image dimensions must be at least 250x250 pixels. Current size: ${width}x$height';
          });
          widget.hasImage?.call(false);
          return;
        }

        setState(() {
          _webImageBytes = imageBytes;
          _selectedImage = null;
          _errorMessage = null;
        });

        widget.hasImage?.call(true);
        widget.onFileSelected?.call(image.path);
        widget.onImageSelected?.call(null); // Web doesn't use File

      } else {
        // For mobile platforms
        final File file = File(image.path);
        final decodedImage = await decodeImageFromList(imageBytes);

        final int width = decodedImage.width;
        final int height = decodedImage.height;

        if (width < 250 || height < 250) {
          setState(() {
            _errorMessage = 'Image dimensions must be at least 250x250 pixels. Current size: ${width}x$height';
          });
          return;
        }

        setState(() {
          _selectedImage = file;
          _webImageBytes = null;
          _errorMessage = null;
        });

        widget.hasImage?.call(true);
        widget.onFileSelected?.call(image.path);
        widget.onImageSelected?.call(file);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to validate image: ${e.toString()}';
      });
    }
  }

  // Add this public method
  void clearImage() {
    setState(() {
      _selectedImage = null;
      _webImageBytes = null;
      _errorMessage = null;
    });
    widget.hasImage?.call(false);
    widget.onImageSelected?.call(null);
    widget.onFileSelected?.call('');
  }

  Widget _buildImageDisplay() {
    if (kIsWeb && _webImageBytes != null) {
      return ClipOval(
        child: Image.memory(
          _webImageBytes!,
          width: widget.size,
          height: widget.size,
          fit: widget.fit,
          scale: widget.scale,
        ),
      );
    } else if (_selectedImage != null) {
      return ClipOval(
        child: Image.file(
          _selectedImage!,
          width: widget.size,
          height: widget.size,
          fit: widget.fit,
          scale: widget.scale,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPlaceholderContent() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: DashedCirclePainter(
          color: widget.borderColor,
          strokeWidth: 2,
          dashLength: 8,
          gapLength: 6,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // User Icon
              Icon(
                CupertinoIcons.person_crop_circle,
                size: 60,
                color: widget.iconColor,
              ),
              const SizedBox(height: 20),
              // Upload Text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Upload',
                      style: TextStyle(
                        color: widget.uploadTextColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: widget.uploadTextColor,
                      ),
                    ),
                    TextSpan(
                      text: ' or drop\nimage here',
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = _selectedImage != null || _webImageBytes != null;

    return Column(
      children: [
        GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: () {
            widget.onTap?.call();
            _pickImage();
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Stack(
                    children: [
                      if (hasImage) _buildImageDisplay() else _buildPlaceholderContent(),
                      if (hasImage)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.uploadTextColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              CupertinoIcons.camera,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: widget.errorTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashLength = 8,
    this.gapLength = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double circumference = 2 * 3.14159 * radius;
    final double dashCount = circumference / (dashLength + gapLength);
    final double adjustedDashLength = circumference / (dashCount * 2);
    final double adjustedGapLength = adjustedDashLength;

    double currentAngle = 0;
    final double angleIncrement = (adjustedDashLength + adjustedGapLength) / radius;
    final double dashAngle = adjustedDashLength / radius;

    while (currentAngle < 2 * 3.14159) {
      final double endAngle = currentAngle + dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        dashAngle,
        false,
        paint,
      );
      currentAngle = endAngle + (adjustedGapLength / radius);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}