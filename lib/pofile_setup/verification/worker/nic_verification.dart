import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../widgets/imagesource_dialog.dart';

class NICVerification extends StatefulWidget {
  final Function(bool, {File? frontImage, File? backImage})? onSelectionChanged;

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

  bool get bothImagesSelected => selectedFrontFile != null && selectedBackFile != null;

  // Update the callback to pass the file objects
  void _updateSelectionStatus() {
    widget.onSelectionChanged?.call(
      bothImagesSelected,
      frontImage: selectedFrontFile,
      backImage: selectedBackFile,
    );
  }

  Future<void> _pickFile({required bool isFront}) async {
    try {
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

          _updateSelectionStatus();
        });
      }
    } catch (e) {
      //print('Error picking image: $e');
    }
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

      _updateSelectionStatus(); // Updated to use new method
    });
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showImageSourceDialog(context);
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 44),
                _buildTitle(context),
                const SizedBox(height: 24),
                _buildImageUploadContainer(
                  isSelected: selectedFrontFile != null,
                  selectedFile: selectedFrontFile,
                  fileName: frontFileName,
                  fileSize: frontFileSize,
                  onTap: () => _pickFile(isFront: true),
                  onPreview: () => _previewImage(isFront: true),
                  onRemove: () => _removeFile(isFront: true),
                  uploadIcon: Iconsax.personalcard_copy,
                  uploadText: 'Front-View',
                  viewLabel: 'FRONT VIEW',
                ),
                const SizedBox(height: 12),
                _buildImageLimit(),
                const SizedBox(height: 24),
                _buildImageUploadContainer(
                  isSelected: selectedBackFile != null,
                  selectedFile: selectedBackFile,
                  fileName: backFileName,
                  fileSize: backFileSize,
                  onTap: () => _pickFile(isFront: false),
                  onPreview: () => _previewImage(isFront: false),
                  onRemove: () => _removeFile(isFront: false),
                  uploadIcon: Iconsax.card_copy,
                  uploadText: 'Back-View',
                  viewLabel: 'BACK VIEW',
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

  // Reusable widget for the title
  Widget _buildTitle(BuildContext context) {
    return Text(
      textAlign: TextAlign.center,
      'Verify with Your NIC or\nDriver License',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold
      ),
    );
  }

  // Reusable widget for image upload container
  Widget _buildImageUploadContainer({
    required bool isSelected,
    required File? selectedFile,
    required String? fileName,
    required String? fileSize,
    required VoidCallback onTap,
    required VoidCallback onPreview,
    required VoidCallback onRemove,
    required IconData uploadIcon,
    required String uploadText,
    required String viewLabel,
  }) {
    return SizedBox(
      width: 300,
      height: 200,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTap: !isSelected ? onTap : null,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(
                color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
                width: 2,
              ) : null,
            ),
            child: isSelected && selectedFile != null
                ? _buildSelectedImageView(
              imageFile: selectedFile,
              fileName: fileName,
              fileSize: fileSize,
              onPreview: onPreview,
              onRemove: onRemove,
              viewLabel: viewLabel,
            )
                : _buildEmptyUploadView(
              icon: uploadIcon,
              uploadText: uploadText,
            ),
          ),
        ),
      ),
    );
  }

  // Reusable widget for selected image view
  Widget _buildSelectedImageView({
    required File imageFile,
    required String? fileName,
    required String? fileSize,
    required VoidCallback onPreview,
    required VoidCallback onRemove,
    required String viewLabel,
  }) {
    return Stack(
      children: [
        _buildImageBackground(imageFile),
        _buildImageOverlay(),
        _buildActionButtons(onPreview: onPreview, onRemove: onRemove),
        _buildFileInfo(fileName: fileName, fileSize: fileSize),
        _buildViewLabel(viewLabel),
      ],
    );
  }

  // Reusable widget for image background
  Widget _buildImageBackground(File imageFile) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: FileImage(imageFile),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Reusable widget for image overlay
  Widget _buildImageOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withValues(alpha: 0.3),
      ),
    );
  }

  // Reusable widget for action buttons
  Widget _buildActionButtons({
    required VoidCallback onPreview,
    required VoidCallback onRemove,
  }) {
    return Positioned(
      top: 8,
      right: 8,
      child: Row(
        children: [
          _buildActionButton(
            onPressed: onPreview,
            icon: CupertinoIcons.zoom_in,
            backgroundColor: Colors.black54,
          ),
          SizedBox(width: 4),
          _buildActionButton(
            onPressed: onRemove,
            icon: Icons.close,
            backgroundColor: Colors.red.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  // Reusable widget for individual action button
  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.all(8),
      ),
    );
  }

  // Reusable widget for file info
  Widget _buildFileInfo({
    required String? fileName,
    required String? fileSize,
  }) {
    return Positioned(
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
              'File Name: $fileName',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              fileSize ?? '',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget for view label
  Widget _buildViewLabel(String label) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Reusable widget for empty upload view
  Widget _buildEmptyUploadView({
    required IconData icon,
    required String uploadText,
  }) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: isHovered ? Color(0xFF4CAF50) : Color(0xFF666666),
        strokeWidth: 2,
        dashLength: 8,
        dashSpace: 4,
      ),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _buildUploadContent(icon, uploadText),
      ),
    );
  }

  // Reusable widget for upload content
  Widget _buildUploadContent(IconData icon, String viewOfID) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUploadIcon(icon),
        SizedBox(height: 12),
        _buildUploadText(),
        _buildUploadDescription(viewOfID),
      ],
    );
  }

  // Reusable widget for upload icon
  Widget _buildUploadIcon(IconData icon) {
    return Container(
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
    );
  }

  // Reusable widget for upload text
  Widget _buildUploadText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 18,
          fontFamily: 'Google Sans',
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
              fontFamily: 'Google Sans',
            ),
          ),
          TextSpan(text: ' or Take\nImage Here'),
        ],
      ),
    );
  }

  // Reusable widget for upload description
  Widget _buildUploadDescription(String viewOfID) {
    return Text('( $viewOfID of NIC or Driver Licence. )');
  }

  // Reusable widget for image limit text
  Widget _buildImageLimit() {
    return Text(
      '360x480 Min / 5 MB Max',
      style: TextStyle(
          fontSize: 16,
          color: Colors.grey
      ),
    );
  }

  // Reusable widget for alert text
  Widget _buildAlertText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            _buildAlertTextSpan(
              'Must be an actual photo of you.',
              Colors.grey,
            ),
            _buildAlertTextSpan(
              '\nLogos, clip-art, group photos, and digitally-altered images',
              Theme.of(context).colorScheme.inverseSurface,
              fontWeight: FontWeight.w600,
            ),
            _buildAlertTextSpan(
              ' are not allowed. It will cause account ',
              Colors.grey,
            ),
            _buildAlertTextSpan(
              'Rejection',
              Colors.red,
              fontWeight: FontWeight.bold,
            ),
            _buildAlertTextSpan(
              ' or ',
              Theme.of(context).colorScheme.inverseSurface,
            ),
            _buildAlertTextSpan(
              'Termination.',
              Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget for alert text span
  TextSpan _buildAlertTextSpan(
      String text,
      Color color, {
        FontWeight fontWeight = FontWeight.normal,
      }) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 16,
        color: color,
        fontFamily: 'Google Sans',
        fontWeight: fontWeight,
      ),
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
      bottomNavigationBar: SafeArea(
        child: Container(
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