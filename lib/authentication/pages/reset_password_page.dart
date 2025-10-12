import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:workie/authentication/pages/login_page.dart';
import 'package:workie/services/auth_service.dart';
import 'package:workie/widgets/custom_textfield.dart';
import '../../generated/app_localizations.dart';
import '../../values/color.dart';
import '../../widgets/error_dialog.dart';

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
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmController = TextEditingController();

  String _resetToken = ''; // Changed from _verificationCode to _resetToken

  // Add loading states
  bool _isLoading = false;
  String? _errorMessage;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    _newPasswordController.dispose();
    _newPasswordConfirmController.dispose();
    _lottieController.dispose();
    _stopTimer?.cancel();
    super.dispose();
  }

  void _validatePassword(String password) {
    String? error;
    if (password.isEmpty) {
      error = AppLocalizations.of(context)!.passwordRequired;
    } else if (password.length < 8) {
      error = AppLocalizations.of(context)!.passwordTooShort;
    } else if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    ).hasMatch(password)) {
      error = "Password must contain uppercase, lowercase, number & special character";
    } else if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      error = "Password cannot have repeated characters";
    } else if (RegExp(
      r'(012|123|234|345|456|567|678|789|890|abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)',
      caseSensitive: false,
    ).hasMatch(password)) {
      error = "Password cannot contain sequential characters";
    }

    if (_passwordError != error) {
      setState(() => _passwordError = error);
    }
  }

  void _validateConfirmPassword(String confirmPassword) {
    String? error;
    if (confirmPassword != _newPasswordController.text) {
      error = "Passwords do not match";
    }
    if (_confirmPasswordError != error) {
      setState(() => _confirmPasswordError = error);
    }
  }

  void _nextPage() {
    setState(() {
      _selectedIndex++;
    });
  }

  // Add email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleUpdatePassword() async {
    final password = _newPasswordController.text.trim();
    final confirmPassword = _newPasswordConfirmController.text.trim();

    _validatePassword(password);
    _validateConfirmPassword(confirmPassword);

    if (_passwordError != null || _confirmPasswordError != null) {
      setState(() {}); // To update the error message in the UI
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();
    final result = await authService.resetPassword(_resetToken, password); // Using _resetToken

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage()
                      )
                  );
                },
                child: const Text(
                  'Back to Sign-in',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            title: 'Password Updated!',
            contentText: 'Password of your account with email address ',
            contentText2: _emailController.text,
            contentText3: ' has been changed successfully. You can now sign in with your new password.',
          );
        },
      );
    } else {
      setState(() {
        _passwordError = result['message'] ?? 'Failed to reset password.';
      });
    }
  }

  // Handle sending reset password email (sends PIN according to backend)
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reset PIN sent to $email'), // Updated message
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }

        if (_selectedIndex == 1) {
          return;
        } else {
          _nextPage();
        }

      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to send reset PIN. Please try again.';
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
                            _EnterEmail(
                              controller: _emailController,
                              errorMessage: _errorMessage,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: _VerifyEmail(
                                    pinController: _pinController,
                                    resetButtonFunction: () {
                                      _sendResetPasswordEmail();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            _UpdatePassword(
                              controller: _newPasswordController,
                              confirmController: _newPasswordConfirmController,
                              errorText: _passwordError,
                              confirmErrorText: _confirmPasswordError,
                              onPasswordChanged: (val) {
                                _validatePassword(val);
                                _validateConfirmPassword(_newPasswordConfirmController.text);
                              },
                              onConfirmChanged: (val) {
                                _validateConfirmPassword(val);
                              },
                            )
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
                                  _HelpText(helpText: 'Make sure you use the same email you signed up with before.'),
                                ],
                              ),
                              Column(
                                children: [
                                  _ContinueButton(
                                    onPressed: () async {
                                      final pin = _pinController.text.trim(); // Changed from 'code' to 'pin'
                                      final email = _emailController.text.trim();

                                      if (pin.length != 5) {
                                        setState(() {
                                          _errorMessage = 'Please enter the 5-digit PIN sent to your email.'; // Updated message
                                        });
                                        return;
                                      }

                                      setState(() {
                                        _isLoading = true;
                                        _errorMessage = null;
                                      });

                                      final authService = AuthService();
                                      final verifyResult = await authService.verifyResetCode(
                                        email,
                                        pin, // Using 'pin' instead of 'code'
                                      );

                                      setState(() {
                                        _isLoading = false;
                                      });

                                      if (verifyResult['success'] == true) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('PIN verified! You can now reset your password.'), // Updated message
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                        setState(() {
                                          _resetToken = verifyResult['resetToken'] ?? ''; // Store resetToken
                                        });
                                        _nextPage();
                                      } else {
                                        setState(() {
                                          _errorMessage = verifyResult['message'] ?? 'Invalid or expired PIN.'; // Updated message
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(_errorMessage!, style: TextStyle(color: Colors.white),),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    isLoading: _isLoading,
                                  ),
                                  _HelpText(helpText: 'Check your inbox and spam folder for the PIN. Didn\'t get it? Request a new one.'), // Updated message
                                ],
                              ),
                              Column(
                                children: [
                                  _ContinueButton(
                                    onPressed: () {
                                      _handleUpdatePassword();
                                    },
                                    isLoading: _isLoading,
                                  ),
                                  _HelpText(helpText: 'A mix of letters, numbers, and symbols makes it stronger. Try not to reuse your old password.'),
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
      height: 50,
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
            ? Transform.scale(
          scale: 0.45, // Makes it half the size
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: CircularProgressIndicator(
              strokeWidth: 9,
              color: Colors.white,
              strokeCap: StrokeCap.square,
            ),
          ),
        )
            : Text(
          'Continue'.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
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

class _EnterEmail extends StatelessWidget {
  final TextEditingController controller;
  final String? errorMessage;

  const _EnterEmail({
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              _LockIcon(iconData: Iconsax.sms_search_copy),
              const SizedBox(height: 40),
              _VerificationTitle(title: 'Find Your Account'),
              const SizedBox(height: 20),
              _VerificationSubtitle(subTitle: 'Enter your registered email address to get a verification PIN.'), // Updated text
              const SizedBox(height: 30),
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

class _VerifyEmail extends StatelessWidget {
  final TextEditingController pinController;
  final VoidCallback resetButtonFunction;

  const _VerifyEmail({
    required this.pinController,
    required this.resetButtonFunction
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              _LockIcon(iconData: Iconsax.shield_tick_copy),
              const SizedBox(height: 40),
              _VerificationTitle(title: 'Verify Your Identity'),
              const SizedBox(height: 20),
              _VerificationSubtitle(subTitle: 'Enter the 5-digit PIN we sent to your email.'), // Updated text
              const SizedBox(height: 30),
              Pinput(
                controller: pinController,
                length: 5,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                keyboardType: TextInputType.number,
                onCompleted: (value) {
                  // Optional: Auto-continue when PIN is complete
                },
              ),
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.15),
                child: TextButton(
                    onPressed: resetButtonFunction,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.refresh_circle_copy),
                        const SizedBox(width: 8),
                        Text('Resend PIN') // Updated text
                      ],
                    )
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _UpdatePassword extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController confirmController;
  final String? errorText;
  final String? confirmErrorText;
  final Function(String) onPasswordChanged;
  final Function(String) onConfirmChanged;

  const _UpdatePassword({
    required this.controller,
    required this.confirmController,
    this.errorText,
    this.confirmErrorText,
    required this.onPasswordChanged,
    required this.onConfirmChanged
  });

  @override
  State<_UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<_UpdatePassword> {
  bool _obscureText = true;
  bool _obscureText2 = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              _LockIcon(iconData: Iconsax.lock_1_copy),
              const SizedBox(height: 40),
              _VerificationTitle(title: 'Set a New Password'),
              const SizedBox(height: 20),
              _VerificationSubtitle(subTitle: 'Create a strong password to secure your account.'),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'New Password',
                      style: TextStyle(
                          fontSize: 15
                      ),
                    ),
                  ),
                ],
              ),
              CustomTextfield(
                controller: widget.controller,
                lableText: AppLocalizations.of(context)!.password,
                hintText: AppLocalizations.of(context)!.password,
                prefixIconData: Icon(Iconsax.lock_copy, color: AppColors.textSilver),
                suffixIconData: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.iconSilver,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
                obscureText: _obscureText,
                errorText: widget.errorText, // Add onChanged callback
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Confirm New Password',
                      style: TextStyle(
                          fontSize: 15
                      ),
                    ),
                  ),
                ],
              ),
              CustomTextfield(
                controller: widget.confirmController,
                lableText: 'Confirm Password',
                hintText: 'Confirm Password',
                prefixIconData: Icon(Iconsax.lock_copy, color: AppColors.textSilver),
                suffixIconData: IconButton(
                  icon: Icon(
                    _obscureText2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.iconSilver,
                  ),
                  onPressed: () => setState(() => _obscureText2 = !_obscureText2),
                ),
                obscureText: _obscureText2,
                errorText: widget.confirmErrorText,// Add onChanged callback
              ),
            ],
          ),
        ),
      ],
    );
  }
}