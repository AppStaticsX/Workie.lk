import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/widgets/simple_prefixtextfield.dart';

import '../../collect_info/worker/page_setup.dart';

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
        MaterialPageRoute(builder: (context) => const ProfileSetup(
          isProfileEditing: false,
        )),
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
                      if (_isCodeSent) ...[
                        const SizedBox(height: 16),
                        _statusMessage(),
                      ],
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
        Iconsax.mobile_copy,
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
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ll send you a verification code to confirm\nyour mobile number',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _mobileNumberInput() {
    return SimplePrefixTextfield(
      controller: _mobileNumberController,
      lableText: 'Mobile Number',
      prefixIconData: Icon(
        Iconsax.mobile_copy,
      ),
      obscureText: false,
      keyboardType: TextInputType.phone,
    );
  }

  Widget _verificationCodeSection() {
    return AnimatedContainer(
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
            ? _sendVerificationCode
            : null,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: _canResend || !_isCodeSent
              ? const Color(0xFF4E6BF5)
              : const Color(0xFF4E6BF5).withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF4E6BF5).withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        ),
        icon: _getButtonIcon(),
      ),
    );
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
          ? const Icon(Icons.refresh, size: 20)
          : Text(
        '${_countdown}s',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return const Icon(Icons.send, size: 28);
  }

  Widget _statusMessage() {
    return Container(
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
    );
  }

  Widget _verifyButton() {
    return SizedBox(
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