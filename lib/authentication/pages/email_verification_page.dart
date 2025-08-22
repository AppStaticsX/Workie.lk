import 'package:flutter/material.dart';
import 'dart:async';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:workie/screens/select_role_screen.dart';

import '../../services/auth_service.dart';

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
  int _selectedIndex = 0;
  Timer? _timer;
  bool _isResendEnabled = false;
  bool _isLoading = false;

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

  void _nextPage() {
    setState(() {
      _selectedIndex++;
    });
  }

  void _resendCode() async {
    if (_isResendEnabled) {
      final result = await AuthService().resendEmailOtp(widget.email);
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification code sent successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send code. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      _startCountdown();
    }
  }

  void _continue() async {
    String code = _pinController.text;

    if (code.length == 5) {
      setState(() {
        _isLoading = true;
      });
      final result = await AuthService().verifyEmailOtp(widget.email, code);
      if (result['success'] == true) {
        setState(() {
          _isLoading = false;
        });
        _nextPage();
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Verification failed')),
          );
        }
      }
    } else {
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
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
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
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
            ),
          ),

          IndexedStack(
            index: _selectedIndex,
            children: [
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
                              _VerificationTitle(title: 'A verification code was sent to your email'),
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
                              _ContinueButton(
                                onPressed: _continue,
                                loadingStatus: _isLoading,
                              ),
                              _HelpText(helpText: 'Can\'t find the code? Please check your spam or junk mail folder.'),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
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
                              const SizedBox(height: 40),
                              Lottie.asset(
                                'assets/animation/blue_checkmark.json',
                                repeat: false,
                                width: 200,
                                height: 200
                              ),
                              const SizedBox(height: 40),
                              _VerificationTitle(title: 'Your email has been successfully verified!'),
                              const SizedBox(height: 40),
                              Spacer(),
                              _ContinueButton(
                                onPressed: (){
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SelectRoleScreen()
                                      )
                                  );
                                },
                              ),
                              _HelpText(helpText: 'You’re almost ready to get started with us.'),
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
          )
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
  final String title;

  const _VerificationTitle({
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        title,
        //'A verification code was sent to your email',
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
  final bool? loadingStatus;

  const _ContinueButton({
    required this.onPressed,
    this.loadingStatus
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = loadingStatus ?? false;
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isLoading)
              Transform.scale(
                scale: 0.45, // Makes it half the size
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 9,
                    color: Colors.white,
                    strokeCap: StrokeCap.square,
                  ),
                ),
              ),
            Text(
              'Continue'.toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpText extends StatelessWidget {
  final String helpText;

  const _HelpText({
    required this.helpText
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      helpText,
      //"Can't find the code? Please check your spam or junk mail folder.",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
      textAlign: TextAlign.center,
    );
  }
}