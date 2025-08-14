import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../widgets/imagesource_dialog.dart';

class PortraitVerification extends StatefulWidget {
  final Function(bool)? onSelectionChanged;

  const PortraitVerification({
    super.key,
    this.onSelectionChanged
  });

  @override
  State<PortraitVerification>createState() => _PortraitVerificationState();
}

class _PortraitVerificationState extends State<PortraitVerification> {
  File? selectedFile;
  String? fileName;
  String? fileSize;
  bool isHovered = false;

  final ImagePicker _picker = ImagePicker();

  void _onHover(bool hover) {
    setState(() {
      isHovered = hover;
    });
  }

  void _notifySelectionChanged() {
    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(selectedFile != null);
    }
  }

  Future<void> _pickFile() async {
    try {
      // Show options for camera or gallery
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        File file = File(image.path);
        int fileSize = await file.length();

        setState(() {
          selectedFile = file;
          fileName = image.name;
          this.fileSize = _formatFileSize(fileSize);
        });

        _notifySelectionChanged();
      }
    } catch (e) {
      //print('Error picking image: $e');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showImageSourceDialog(context);
  }

  void _removeFile() {
    setState(() {
      selectedFile = null;
      fileName = null;
      fileSize = null;
    });
    _notifySelectionChanged();
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 Bytes";
    const suffixes = ["Bytes", "KB", "MB", "GB", "TB"];
    var i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 1/3,
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4E6BF5).withValues(alpha: 0.3),
                    const Color(0xFF4E6BF5),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(3),
                ),
              ),
            ),
          ],
        ),
        // Scrollable content below
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 44),
                Text(
                  textAlign: TextAlign.center,
                  'A Portrait Photo of Your\nTaken Recently',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 300,
                  height: 380,
                  child: Material(
                    elevation: isHovered ? 4 : 0,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                    child: MouseRegion(
                      onEnter: (_) => _onHover(true),
                      onExit: (_) => _onHover(false),
                      child: GestureDetector(
                        onTap: selectedFile == null ? _pickFile : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
                              width: 2,
                              style: selectedFile == null ? BorderStyle.none : BorderStyle.solid,
                            ),
                          ),
                          child: CustomPaint(
                            painter: selectedFile == null
                                ? DashedBorderPainter(
                              color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
                              strokeWidth: 2,
                              dashLength: 8,
                              dashSpace: 4,
                            )
                                : null,
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: selectedFile == null
                                  ? _buildUploadContent()
                                  : _buildFileContent(),
                            ),
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
      '250x250 Min / 5 MB Max',
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

  Widget _buildUploadContent() {
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
            Iconsax.user_edit_copy,
            color: Colors.white,
            size: 30,
          ),
        ),
        SizedBox(height: 20),
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
                  //decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(text: ' or Take\nImage Here'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          color: Color(0xFF4CAF50),
          size: 50,
        ),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            fileName ?? '',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          fileSize ?? '',
          style: TextStyle(
            color: Color(0xFF999999),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 15),
        ElevatedButton(
          onPressed: _removeFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF666666),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
          child: Text(
            'Remove Image',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
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