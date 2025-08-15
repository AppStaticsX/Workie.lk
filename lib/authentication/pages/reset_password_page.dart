import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:workie/services/auth_service.dart';
import 'package:workie/widgets/custom_textfield.dart';
import 'package:http/http.dart' as http;

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> with TickerProviderStateMixin {
  late AnimationController _lottieController;
  Timer? _stopTimer;
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _lottieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 36.0),
                      child: Column(
                        children: [
                          _LockIcon(),
                          const SizedBox(height: 40),
                          _VerificationTitle(),
                          const SizedBox(height: 40),
                          _VerificationSubtitle(),
                          const SizedBox(height: 20),
                          CustomTextfield(
                            controller: _emailController,
                            lableText: 'Email Address',
                            hintText: 'Email Address',
                            obscureText: false,
                          ),
                          Spacer(),
                          _ContinueButton(
                            onPressed: () async {
                              final email = _emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please enter your email address')),
                                );
                                return;
                              }
                              final success = await AuthService().sendResetPasswordEmail(email);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Reset password email sent!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to send reset email.')),
                                );
                              }
                            },
                          ),
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
        Iconsax.warning_2_copy,
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
      flex: 0,
      child: Text(
        maxLines: 2,
        'Reset your account password',
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
      'Enter the email address of account that you want to reset passowrd:',
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
      textAlign: TextAlign.center,
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