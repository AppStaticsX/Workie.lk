import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../widgets/imagesource_dialog.dart';

class NICVerification extends StatefulWidget {
  const NICVerification({super.key});

  @override
  State<NICVerification>createState() => _NICVerificationState();
}

class _NICVerificationState extends State<NICVerification> {
  File? selectedFile;
  String? fileName;
  String? fileSize;
  bool isHovered = false;

  final ImagePicker _picker = ImagePicker();

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
      }
    } catch (e) {
      print('Error picking image: $e');
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
        // Fixed progress bar at the top
        LinearProgressIndicator(
          value: 2/3,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4E6BF5)),
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
                  'Verify with Your NIC or\nDriver License',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 300,
                  height: 200,
                  child: MouseRegion(
                    onEnter: (_) => _onHover(true),
                    onExit: (_) => _onHover(false),
                    child: GestureDetector(
                      onTap: selectedFile == null ? _pickFile : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: selectedFile != null ? Border.all(
                            color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
                            width: 2,
                          ) : null,
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
                                ? _buildUploadContent(Iconsax.personalcard_copy, 'Front-View')
                                : _buildFileContent(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildImageLimit(),
                const SizedBox(height: 24),
                SizedBox(
                  width: 300,
                  height: 200,
                  child: MouseRegion(
                    onEnter: (_) => _onHover(true),
                    onExit: (_) => _onHover(false),
                    child: GestureDetector(
                      onTap: selectedFile == null ? _pickFile : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: selectedFile != null ? Border.all(
                            color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
                            width: 2,
                          ) : null,
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
                                ? _buildUploadContent(Iconsax.card_copy, 'Back-View')
                                : _buildFileContent(),
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
                text: 'Upload',
                style: TextStyle(
                  color: const Color(0xFF4E6BF5),
                  fontWeight: FontWeight.bold,
                  //decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(text: ' or take\nimage here'),
            ],
          ),
        ),
        Text(
            '( $viewOfID of NIC or Driver Licence. )'
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