import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../widgets/imagesource_dialog.dart';

class NICVerification extends StatefulWidget {
  final Function(bool)? onSelectionChanged; // Add callback for validation

  const NICVerification({super.key, this.onSelectionChanged});

  @override
  State<NICVerification> createState() => _NICVerificationState();
}

class _NICVerificationState extends State<NICVerification> {
  File? selectedFrontFile;
  File? selectedBackFile;
  String? frontFileName;
  String? backFileName;
  String? frontFileSize;
  String? backFileSize;
  bool isHovered = false;

  final ImagePicker _picker = ImagePicker();

  // Check if both images are selected
  bool get bothImagesSelected => selectedFrontFile != null && selectedBackFile != null;

  Future<void> _pickFile({required bool isFront}) async {
    try {
      // Show options for camera or gallery
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        File file = File(image.path);
        int fileSize = await file.length();

        setState(() {
          if (isFront) {
            selectedFrontFile = file;
            frontFileName = image.name;
            frontFileSize = _formatFileSize(fileSize);
          } else {
            selectedBackFile = file;
            backFileName = image.name;
            backFileSize = _formatFileSize(fileSize);
          }

          // Notify parent about selection state
          widget.onSelectionChanged?.call(bothImagesSelected);
        });
      }
    } catch (e) {
      //print('Error picking image: $e');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showImageSourceDialog(context);
  }

  void _removeFile({required bool isFront}) {
    setState(() {
      if (isFront) {
        selectedFrontFile = null;
        frontFileName = null;
        frontFileSize = null;
      } else {
        selectedBackFile = null;
        backFileName = null;
        backFileSize = null;
      }

      // Notify parent about selection state
      widget.onSelectionChanged?.call(bothImagesSelected);
    });
  }

  void _previewImage({required bool isFront}) {
    final File? imageFile = isFront ? selectedFrontFile : selectedBackFile;
    final String title = isFront ? 'Front View Preview' : 'Back View Preview';

    if (imageFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _ImagePreviewScreen(
            imageFile: imageFile,
            title: title,
          ),
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 Bytes";
    const suffixes = ["Bytes", "KB", "MB", "GB", "TB"];
    var i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }

  void _onHover(bool hover) {
    setState(() {
      isHovered = hover;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable content below
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 44),
                Text(
                  textAlign: TextAlign.center,
                  'Verify with Your NIC or\nDriver License',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 24),
                // Front view upload
                SizedBox(
                  width: 300,
                  height: 200,
                  child: MouseRegion(
                    onEnter: (_) => _onHover(true),
                    onExit: (_) => _onHover(false),
                    child: GestureDetector(
                      onTap: selectedFrontFile == null ? () => _pickFile(isFront: true) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: selectedFrontFile != null ? Border.all(
                            color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
                            width: 2,
                          ) : null,
                        ),
                        child: selectedFrontFile != null
                            ? Stack(
                          children: [
                            // Image preview
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(selectedFrontFile!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Overlay with semi-transparent background
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                            // Action buttons
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _previewImage(isFront: true),
                                    icon: Icon(CupertinoIcons.zoom_in, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      padding: EdgeInsets.all(8),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  IconButton(
                                    onPressed: () => _removeFile(isFront: true),
                                    icon: Icon(Icons.close, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red.withOpacity(0.7),
                                      padding: EdgeInsets.all(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // File info at bottom
                            Positioned(
                              bottom: 8,
                              left: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'File Name: $frontFileName',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      frontFileSize ?? '',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // "Front View" label
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'FRONT VIEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            : CustomPaint(
                          painter: DashedBorderPainter(
                            color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
                            strokeWidth: 2,
                            dashLength: 8,
                            dashSpace: 4,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: _buildUploadContent(Iconsax.personalcard_copy, 'Front-View'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildImageLimit(),
                const SizedBox(height: 24),
                // Back view upload
                SizedBox(
                  width: 300,
                  height: 200,
                  child: MouseRegion(
                    onEnter: (_) => _onHover(true),
                    onExit: (_) => _onHover(false),
                    child: GestureDetector(
                      onTap: selectedBackFile == null ? () => _pickFile(isFront: false) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: selectedBackFile != null ? Border.all(
                            color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
                            width: 2,
                          ) : null,
                        ),
                        child: selectedBackFile != null
                            ? Stack(
                          children: [
                            // Image preview
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(selectedBackFile!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Overlay with semi-transparent background
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                            // Action buttons
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _previewImage(isFront: false),
                                    icon: Icon(CupertinoIcons.zoom_in, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      padding: EdgeInsets.all(8),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  IconButton(
                                    onPressed: () => _removeFile(isFront: false),
                                    icon: Icon(Icons.close, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red.withOpacity(0.7),
                                      padding: EdgeInsets.all(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // File info at bottom
                            Positioned(
                              bottom: 8,
                              left: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'File Name: $backFileName',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      backFileSize ?? '',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // "Back View" label
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'BACK VIEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            : CustomPaint(
                          painter: DashedBorderPainter(
                            color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
                            strokeWidth: 2,
                            dashLength: 8,
                            dashSpace: 4,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: _buildUploadContent(Iconsax.card_copy, 'Back-View'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildImageLimit(),
                const SizedBox(height: 24),
                _buildAlertText(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Text _buildImageLimit() {
    return Text(
      '360x480 Min / 5 MB Max',
      style: TextStyle(
          fontSize: 16,
          color: Colors.grey
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
                color: Colors.grey,
              ),
            ),
            TextSpan(
              text: '\nLogos, clip-art, group photos, and digitally-altered images',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: ' are not allowed. It will cause account ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            TextSpan(
              text: 'Rejection',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' or ',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.normal,
              ),
            ),
            TextSpan(
              text: 'Termination.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadContent(IconData icon, String viewOfID) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isHovered ? Colors.white : Color(0xFFcccccc),
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: 'UPLOAD',
                style: TextStyle(
                  color: const Color(0xFF4E6BF5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: ' or Take\nImage Here'),
            ],
          ),
        ),
        Text(
            '( $viewOfID of NIC or Driver Licence. )'
        ),
      ],
    );
  }
}

// Image Preview Screen
class _ImagePreviewScreen extends StatelessWidget {
  final File imageFile;
  final String title;

  const _ImagePreviewScreen({
    required this.imageFile,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    width: 300,
                    color: Colors.grey[800],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 50,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Unable to load image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
              label: Text('Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // You can add share functionality here if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Share functionality can be added here'),
                    backgroundColor: Colors.grey[800],
                  ),
                );
              },
              icon: Icon(Icons.share),
              label: Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4E6BF5),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashLength = 8,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
            size.width - strokeWidth, size.height - strokeWidth),
        Radius.circular(12),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final PathMetrics pathMetrics = path.computeMetrics();

    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;

      while (distance < pathMetric.length) {
        final double length = draw ? dashLength : dashSpace;
        final double end = distance + length;

        if (draw) {
          canvas.drawPath(
            pathMetric.extractPath(distance, end.clamp(0, pathMetric.length)),
            paint,
          );
        }

        distance = end;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}