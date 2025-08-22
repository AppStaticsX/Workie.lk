import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../values/dimension.dart';

class SquareTile extends StatefulWidget {
  final VoidCallback onPressed;
  final bool loading;
  final String imagePath;
  final String provider;

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.provider,
    required this.loading,
    required this.onPressed,
  });

  @override
  State<SquareTile> createState() => _SquareTileState();
}

class _SquareTileState extends State<SquareTile> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFFFBBC05), end: Color(0xFFEB4335)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFFEB4335), end: Color(0xFF34A853)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFF34A853), end: Color(0xFF4285F4)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFF4285F4), end: Color(0xFFFBBC05)),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault * 3.6),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.loading
                ? Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Transform.scale(
                    scale: 0.45,
                      child: AnimatedBuilder(
                        animation: _colorAnimation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            strokeWidth: 9,
                            color: _colorAnimation.value,
                            strokeCap: StrokeCap.square,
                          );
                        },
                      ),
                    ),
                )
              : Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SvgPicture.asset(
                  widget.imagePath,
                  height: 24,
                ),
              ),
              //const SizedBox(width: 12),
              Text(
                widget.provider,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontSize: 16
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
