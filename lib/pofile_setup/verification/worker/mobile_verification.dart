import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:workie/services/twilio_service.dart';

// Phone number formatter for Sri Lankan numbers
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove any non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format as XXX XXX XXX for better readability
    String formatted = '';
    if (digitsOnly.isNotEmpty) {
      for (int i = 0; i < digitsOnly.length; i++) {
        if (i == 3 || i == 6) {
          formatted += ' ';
        }
        formatted += digitsOnly[i];
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class MobileVerification extends StatefulWidget {
  final Function(bool)? onVerificationComplete;

  const MobileVerification({
    super.key,
    this.onVerificationComplete
  });

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

  final TwilioService _twilioService = TwilioService();

  bool _isCodeSent = false;
  bool _isLoading = false;
  bool _isVerifying = false;
  int _countdown = 60;
  bool _canResend = false;
  bool _isVerified = false;

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
      _showSnackBar('Please enter your mobile number', isError: true);
      return;
    }

    // Clean and validate phone number
    final phoneNumber = _mobileNumberController.text.trim().replaceAll(' ', '');
    
    // Sri Lankan mobile numbers are 9 digits (after removing leading 0)
    // Format: 0XXXXXXXX (10 digits with 0) or XXXXXXX (9 digits without 0)
    if (phoneNumber.length < 9 || phoneNumber.length > 10) {
      _showSnackBar('Please enter a valid Sri Lankan mobile number', isError: true);
      return;
    }
    
    // Check if it's a valid Sri Lankan mobile number pattern
    final cleanNumber = phoneNumber.startsWith('0') ? phoneNumber.substring(1) : phoneNumber;
    if (!RegExp(r'^7[0-9]{8}$').hasMatch(cleanNumber)) {
      _showSnackBar('Please enter a valid Sri Lankan mobile number starting with 07', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _twilioService.sendVerificationCode(cleanNumber);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCodeSent = success;
        });
        
        if (success) {
          _startCountdown();
          _showSnackBar('Verification code sent successfully!', isError: false);
        } else {
          _showSnackBar('Failed to send verification code. Please try again.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('An error occurred. Please try again.', isError: true);
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationCodeController.text.isEmpty) {
      _showSnackBar('Please enter the verification code', isError: true);
      return;
    }

    if (_verificationCodeController.text.length != 5) {
      _showSnackBar('Please enter a valid 5-digit code', isError: true);
      return;
    }

    if (_mobileNumberController.text.isEmpty) {
      _showSnackBar('Mobile number is required', isError: true);
      return;
    }

    // Clean the phone number for verification
    final phoneNumber = _mobileNumberController.text.trim().replaceAll(' ', '');
    final cleanNumber = phoneNumber.startsWith('0') ? phoneNumber.substring(1) : phoneNumber;

    setState(() {
      _isVerifying = true;
    });

    try {
      final result = await _twilioService.verifyCode(
        _verificationCodeController.text.trim(),
        cleanNumber,
      );

      if (mounted) {
        setState(() {
          _isVerifying = false;
        });

        if (result.isSuccess) {
          _showSnackBar(result.message, isError: false);
          
          // Navigate to profile setup after successful verification
          await Future.delayed(const Duration(milliseconds: 500));
          
          setState(() {
            _isVerified = true;
          });

          widget.onVerificationComplete?.call(true);

        } else {
          _showSnackBar(result.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        _showSnackBar('An error occurred during verification. Please try again.', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Progress bar
          _progressBar(),

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
                      _headerIcon(),
                      const SizedBox(height: 20),
                      _titleSection(),
                      const SizedBox(height: 40),
                      _mobileNumberInput(),
                      const SizedBox(height: 20),
                      _verificationCodeSection(),
                      const SizedBox(height: 40),
                      _verifyButton(),
                      const SizedBox(height: 24),
                      _helpText(),
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

  Widget _progressBar() {
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 3/3,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4E6BF5).withValues(alpha: 0.3),
                const Color(0xFF4E6BF5),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Iconsax.call_add,
        size: 80,
        color: Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }

  Widget _titleSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          'Verify Your\nMobile Number',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ll send you a verification code to confirm\nyour mobile number',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _mobileNumberInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _mobileNumberController,
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: '7XXXXXXXX',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Iconsax.call_add_copy),
            prefixText: '+94 ',
            prefixStyle: TextStyle(
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFF4E6BF5),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9), // 9 digits for Sri Lankan numbers
            _PhoneNumberFormatter(),
          ],
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ll send a verification code to this number',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _verificationCodeSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Pinput(
              controller: _verificationCodeController,
              length: 5,
              defaultPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF4E6BF5),
                    width: 2,
                  ),
                ),
              ),
              submittedPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _sendCodeButton(),
          ),
        ],
      ),
    );
  }

  Widget _sendCodeButton() {
    return SizedBox(
      height: 56,
      child: _isLoading
          ? _loadingContainer()
          : IconButton(
        onPressed: _canResend || !_isCodeSent
            ? () async {
          if (_canResend) {
            await _resendCode();
          } else {
            await _sendVerificationCode();
          }
        }
            : null,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: _canResend || !_isCodeSent
              ? const Color(0xFF4E6BF5)
              : const Color(0xFF4E6BF5),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF4E6BF5),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        ),
        icon: _getButtonIcon(),
      ),
    );
  }

  Future<void> _resendCode() async {
    final phoneNumber = _mobileNumberController.text.trim().replaceAll(' ', '');
    if (phoneNumber.isEmpty) {
      _showSnackBar('Please enter your mobile number', isError: true);
      return;
    }
    
    final cleanNumber = phoneNumber.startsWith('0') ? phoneNumber.substring(1) : phoneNumber;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _twilioService.resendVerificationCode(cleanNumber);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          _startCountdown();
          _showSnackBar('New verification code sent!', isError: false);
          // Clear the previous code input
          _verificationCodeController.clear();
        } else {
          _showSnackBar('Failed to resend code. Please try again.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('An error occurred. Please try again.', isError: true);
      }
    }
  }

  Widget _loadingContainer() {
    return Container(
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
    );
  }

  Widget _getButtonIcon() {
    if (_isCodeSent) {
      return _canResend
          ? Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: const Icon(Iconsax.refresh_copy, size: 28),
        )
          : Text(
        '${_countdown}s',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
      );
    }
    return const Icon(Iconsax.send_1, size: 28);
  }



  Widget _verifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isLoading || _isVerifying) ? null : _verifyCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4E6BF5),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color(0xFF4E6BF5).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isVerifying
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
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _helpText() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      'Having trouble? Make sure your mobile number\nis correct and try again.',
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        height: 1.4,
      ),
    );
  }
}