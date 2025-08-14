import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/widgets/simple_prefixtextfield.dart';

import '../../collect_info/profile_setup.dart';

class MobileVerification extends StatefulWidget {
  const MobileVerification({super.key});

  @override
  State<MobileVerification> createState() => _MobileVerificationState();
}

class _MobileVerificationState extends State<MobileVerification>
    with TickerProviderStateMixin {
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _verificationCodeController =
  TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isCodeSent = false;
  bool _isLoading = false;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _verificationCodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    if (_countdown > 0) {
      setState(() {
        _countdown--;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _updateCountdown();
        }
      });
    } else {
      setState(() {
        _canResend = true;
      });
    }
  }

  Future<void> _sendVerificationCode() async {
    if (_mobileNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your mobile number'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isCodeSent = true;
      });
      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification code sent successfully!'),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the verification code'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate verification
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ProfileSetup()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Enhanced progress bar with gradient
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

          // Main content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Title with better styling
                      Text(
                        'Verify Your\nMobile Number',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'We\'ll send you a verification code to confirm\nyour mobile number',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Icon with enhanced styling
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E6BF5).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.mobile_copy,
                          size: 80,
                          color: const Color(0xFF4E6BF5),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Mobile number input
                      SimplePrefixTextfield(
                        controller: _mobileNumberController,
                        lableText: 'Mobile Number',
                        prefixIconData: Icon(
                          Iconsax.call_copy,
                        ),
                        obscureText: false,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 20),

                      // Verification code section
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SimplePrefixTextfield(
                                controller: _verificationCodeController,
                                hintText: 'Enter verification code',
                                obscureText: false,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: _isLoading
                                    ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF4E6BF5).withValues(alpha: 0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4E6BF5),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : OutlinedButton(
                                  onPressed: _canResend || !_isCodeSent
                                      ? _sendVerificationCode
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    side: BorderSide(
                                      color: const Color(0xFF4E6BF5).withValues(alpha: 
                                        _canResend || !_isCodeSent ? 1.0 : 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _isCodeSent
                                        ? _canResend
                                        ? 'Resend'
                                        : '${_countdown}s'
                                        : 'Send Code',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4E6BF5).withValues(alpha: 
                                        _canResend || !_isCodeSent ? 1.0 : 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status message
                      if (_isCodeSent) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.green.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.tick_circle_copy,
                                color: Colors.green.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Code sent to +${_mobileNumberController.text}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Enhanced verify button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E6BF5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: const Color(0xFF4E6BF5).withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            'Verify Mobile Number',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Help text
                      Text(
                        'Having trouble? Make sure your mobile number\nis correct and try again.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}