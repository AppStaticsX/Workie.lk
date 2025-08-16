import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:workie/services/auth_service.dart';
import 'package:workie/widgets/custom_textfield.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _lottieController;
  Timer? _stopTimer;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  String _verificationCode = '';

  // Add loading states
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    _lottieController.dispose();
    _stopTimer?.cancel();
    super.dispose();
  }

  void _nextPage() {
    setState(() {
      _selectedIndex++;
    });
  }

  // Add email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Handle sending reset password email
  Future<void> _sendResetPasswordEmail() async {
    final email = _emailController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final result = await authService.sendResetPasswordEmail(email);

      if (result['success'] == true) {
        setState(() {
          _verificationCode = result['code'] ?? '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reset code sent to $email'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }

        _nextPage();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to send reset email. Please check your email address.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Account Password'),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Background animation
          Positioned.fill(
            child: Lottie.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/animation/circles-dark.json'
                  : 'assets/animation/circles-light.json',
              controller: _lottieController,
              fit: BoxFit.cover,
              frameRate: FrameRate(120),
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

          // Overlay
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IndexedStack(
                          index: _selectedIndex,
                          children: [
                            _enterEmail(
                              controller: _emailController,
                              errorMessage: _errorMessage,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: _verifyEmail(pinController: _pinController),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36.0),
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: [
                              Column(
                                children: [
                                  _ContinueButton(
                                    onPressed: _isLoading ? null : _sendResetPasswordEmail,
                                    isLoading: _isLoading,
                                  ),
                                  _HelpText(),
                                ],
                              ),
                              Column(
                                children: [
                                  _ContinueButton(
                                    onPressed: () async {
                                      final code = _pinController.text.trim();
                                      final email = _emailController.text.trim();

                                      if (code.length != 5) {
                                        setState(() {
                                          _errorMessage = 'Please enter the 5-digit code sent to your email.';
                                        });
                                        return;
                                      }

                                      setState(() {
                                        _isLoading = true;
                                        _errorMessage = null;
                                      });

                                      final authService = AuthService();
                                      final result = await authService.verifyResetCode(email, code);

                                      setState(() {
                                        _isLoading = false;
                                      });

                                      if (result['success'] == true) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Code verified! You can now reset your password.'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                        _nextPage(); // Or navigate to the password reset form
                                      } else {
                                        setState(() {
                                          _errorMessage = result['message'] ?? 'Invalid or expired code.';
                                        });
                                      }
                                    },
                                    isLoading: _isLoading,
                                  ),
                                  _HelpText(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
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
  final IconData iconData;

  const _LockIcon({
    required this.iconData
  });

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
        iconData,
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
      flex: 0,
      child: Text(
        maxLines: 2,
        title,
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
  final String subTitle;

  const _VerificationSubtitle({
    required this.subTitle
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      subTitle,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ContinueButton({
    required this.onPressed,
    this.isLoading = false,
  });

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
        child: isLoading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
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

// Screens

class _enterEmail extends StatelessWidget {
  final TextEditingController controller;
  final String? errorMessage;

  const _enterEmail({
    required this.controller,
    this.errorMessage,
  });

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Column(
            children: [
              _LockIcon(iconData: Iconsax.lock),
              const SizedBox(height: 40),
              _VerificationTitle(title: 'Reset Your Account Password'),
              const SizedBox(height: 40),
              _VerificationSubtitle(subTitle: 'Enter your email address to receive a reset code'),
              const SizedBox(height: 20),
              CustomTextfield(
                controller: controller,
                lableText: 'Email Address',
                hintText: 'Enter your email address',
                obscureText: false,
              ),
            ],
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _verifyEmail extends StatelessWidget {
  final TextEditingController pinController;

  const _verifyEmail({
    required this.pinController
  });

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

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 2/3,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Column(
            children: [
              _LockIcon(iconData: Iconsax.lock),
              const SizedBox(height: 40),
              _VerificationTitle(title: 'Enter Verification Code'),
              const SizedBox(height: 40),
              _VerificationSubtitle(subTitle: 'Enter the 5-digit code sent to your email'),
              const SizedBox(height: 20),
              Pinput(
                controller: pinController,
                length: 5,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                keyboardType: TextInputType.number,
                onCompleted: (value) {
                  // Optional: Auto-continue when code is complete
                  // _continue();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}