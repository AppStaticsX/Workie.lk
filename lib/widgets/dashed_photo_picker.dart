import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashedPhotoPicker extends StatefulWidget {
  final VoidCallback? onTap;
  final Function(String)? onFileSelected;
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color uploadTextColor;

  const DashedPhotoPicker({
    super.key,
    this.onTap,
    this.onFileSelected,
    this.size = 300,
    this.backgroundColor = const Color(0xFF2A2A2A),
    this.borderColor = Colors.white,
    this.iconColor = Colors.white,
    this.textColor = Colors.grey,
    this.uploadTextColor = const Color(0xFF4CAF50),
  });

  @override
  State<DashedPhotoPicker> createState() => _DashedPhotoPickerState();
}

class _DashedPhotoPickerState extends State<DashedPhotoPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
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
              ),
            );
          },
        ),
      ),
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