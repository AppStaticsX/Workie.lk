import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({
    super.key,
    this.email = 'uanushka2001@gmail.com',
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();

  late AnimationController _lottieController;
  Timer? _stopTimer;

  int _resendCountdown = 30;
  Timer? _timer;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _lottieController = AnimationController(vsync: this);
  }

  void _startCountdown() {
    _isResendEnabled = false;
    _resendCountdown = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  void _resendCode() {
    if (_isResendEnabled) {
      // Implement resend logic here
      if (kDebugMode) {
        print('Resending code...');
      }
      _startCountdown();
    }
  }

  void _continue() {
    String code = _pinController.text;
    if (code.length == 5) {
      // Implement verification logic here
      if (kDebugMode) {
        print('Verifying code: $code');
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the complete 5-digit code')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
    _lottieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF4E6BF5),
          width: 2,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow/elevation
        surfaceTintColor: Colors.transparent, // Remove surface tint
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Lottie animation
          Positioned.fill(
            child: Lottie.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/animation/circles-dark.json'
                  : 'assets/animation/circles-light.json',
              controller: _lottieController,
              frameRate: FrameRate(120),
              fit: BoxFit.cover,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;
                _lottieController.forward();
                _stopTimer = Timer(Duration(milliseconds: 600), () {
                  if (mounted && _lottieController.isAnimating) {
                    _lottieController.stop();
                  }
                });
              },
            ),
          ),

          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
            ),
          ),

          // Content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 36.0),
                      child: Column(
                        children: [
                          _LockIcon(),
                          const SizedBox(height: 40),
                          _VerificationTitle(),
                          _VerificationSubtitle(),
                          _EmailDisplay(email: widget.email),
                          const SizedBox(height: 40),
                          Pinput(
                            controller: _pinController,
                            length: 5,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            keyboardType: TextInputType.number,
                            onCompleted: (value) {
                              // Optional: Auto-continue when code is complete
                              // _continue();
                            },
                          ),
                          const SizedBox(height: 24),
                          _ResendCodeSection(
                            isResendEnabled: _isResendEnabled,
                            resendCountdown: _resendCountdown,
                            onResend: _resendCode,
                          ),
                          Spacer(),
                          _ContinueButton(onPressed: _continue),
                          _HelpText(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LockIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Iconsax.lock_1_copy,
        size: 60,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _VerificationTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        'A verification code was sent to your email',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _VerificationSubtitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Enter it below to verify this address:',
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _EmailDisplay extends StatelessWidget {
  final String email;

  const _EmailDisplay({required this.email});

  @override
  Widget build(BuildContext context) {
    return Text(
      email,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.inversePrimary,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _ResendCodeSection extends StatelessWidget {
  final bool isResendEnabled;
  final int resendCountdown;
  final VoidCallback onResend;

  const _ResendCodeSection({
    required this.isResendEnabled,
    required this.resendCountdown,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: isResendEnabled ? onResend : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.refresh_circle,
            color: isResendEnabled? const Color(0xFF4E6BF5) : Color(0xFF6B6B6B),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            isResendEnabled
                ? 'Resend code'
                : 'Resend code in $resendCountdown seconds',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isResendEnabled? const Color(0xFF4E6BF5) : Color(0xFF6B6B6B)
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ContinueButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: EdgeInsets.only(bottom: 24),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4E6BF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          'Continue'.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _HelpText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "Can't find the code? Please check your spam or junk mail folder.",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
      textAlign: TextAlign.center,
    );
  }
}