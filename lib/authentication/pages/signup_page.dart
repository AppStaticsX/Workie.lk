import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:workie/authentication/pages/email_verification_page.dart';
import 'package:workie/authentication/pages/login_page.dart';
import 'package:workie/generated/app_localizations.dart';
import 'package:workie/screens/splash_screen.dart';
import 'package:workie/widgets/custom_textfield.dart';
import '../../values/color.dart';
import '../../values/dimension.dart';
import '../../values/string.dart';
import '../../widgets/agreement_dialog.dart';
import '../../widgets/simple_textfeild.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  late AnimationController _lottieController;
  Timer? _stopTimer;

  bool _obscureText = true;
  bool _isChecked = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _lastNameError;
  String? _firstNameError;
  String? _confirmPassowrdError;

  @override
  void initState() {
    super.initState();
    _setupLiveValidation();
    _lottieController = AnimationController(vsync: this);
  }

  void _setupLiveValidation() {
    _emailController.addListener(() => _validateEmail(_emailController.text.trim()));
    _passwordController.addListener(() => _validatePassword(_passwordController.text.trim()));
    _confirmPasswordController.addListener(() => _validateConfirmPassword(_confirmPasswordController.text.trim()));
    _firstNameController.addListener(() => _validateFirstName(_firstNameController.text.trim()));
    _lastNameController.addListener(() => _validateLastName(_lastNameController.text.trim()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  void _validateEmail(String email) {
    String? error;
    if (email.isEmpty) {
      error = AppLocalizations.of(context)!.emailRequired;
    } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      error = AppLocalizations.of(context)!.emailInvalid;
    }

    if (_emailError != error) {
      setState(() => _emailError = error);
    }
  }

  void _validatePassword(String password) {
    String? error;
    if (password.isEmpty) {
      error = AppLocalizations.of(context)!.passwordRequired;
    } else if (password.length < 8) {
      error = AppLocalizations.of(context)!.passwordTooShort;
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(password)) {
      error = "Password must contain uppercase, lowercase, number & special character";
    } else if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      error = "Password cannot have repeated characters";
    } else if (RegExp(r'(012|123|234|345|456|567|678|789|890|abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)', caseSensitive: false).hasMatch(password)) {
      error = "Password cannot contain sequential characters";
    }

    if (_passwordError != error) {
      setState(() => _passwordError = error);
    }
  }

  void _validateConfirmPassword(String confirmPassword) {
    String? error;
    if (confirmPassword.isEmpty) {
      error = AppLocalizations.of(context)!.passwordRequired;
    } else if (confirmPassword != _passwordController.text) {
      error = AppLocalizations.of(context)!.passwordTooShort;
    }

    if (_confirmPassowrdError != error) {
      setState(() => _confirmPassowrdError = error);
    }
  }

  void _validateFirstName(String firstName) {
    String? error;
    if (firstName.isEmpty) {
      error = "Name is required";
    } else if (RegExp(r'\d').hasMatch(firstName)) {
      error = "Invalid name";
    } else if (firstName.length <= 2) {
      error = "Invalid length";
    }

    if (_firstNameError != error) {
      setState(() => _firstNameError = error);
    }
  }

  void _validateLastName(String lastName) {
    String? error;
    if (lastName.isEmpty) {
      error = "Name is required";
    } else if (RegExp(r'\d').hasMatch(lastName)) {
      error = "Invalid name";
    } else if (lastName.length <= 2) {
      error = "Invalid length";
    }

    if (_lastNameError != error) {
      setState(() => _lastNameError = error);
    }
  }

  // Method to validate all fields at once
  void _validateAllFields() {
    _validateEmail(_emailController.text.trim());
    _validatePassword(_passwordController.text.trim());
    _validateConfirmPassword(_confirmPasswordController.text.trim());
    _validateFirstName(_firstNameController.text.trim());
    _validateLastName(_lastNameController.text.trim());
  }

  bool get _hasErrors => _emailError != null || _passwordError != null || _confirmPassowrdError != null ||_lastNameError != null || _firstNameError != null;

  void _handleSignup() {
    _validateAllFields();

    if (_hasErrors) {
      return;
    }

    if (!_isChecked) {
      _showAgreement();
      return;
    }

    if (_isChecked && !_hasErrors) {
      setState(() {
        _isLoading = true;
      });
    }

    _navigateToVerification();
  }

  void _showAgreement() {
    showCustomAlertDialog(
      context,
      [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() => _isChecked = true);
            _dismissKeyboard();
          },
          child: const Text(
            'Agree',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToVerification() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const EmailVerificationPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Background Lottie Animation
          Positioned(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0), // Flip horizontally
              child: Lottie.asset(
                Theme.of(context).brightness == Brightness.dark
                ? 'assets/animation/circles-dark.json'
                : 'assets/animation/circles-light.json',
                controller: _lottieController,
                frameRate: FrameRate(120),
                fit: BoxFit.cover,
                onLoaded: (composition) {
                  _lottieController.duration = composition.duration;

                  // Start the animation
                  _lottieController.forward();

                  // Stop after 2 seconds (or any specific time)
                  _stopTimer = Timer(Duration(milliseconds: 650), () {
                    if (mounted && _lottieController.isAnimating) {
                      _lottieController.stop();
                    }
                  });
                },
              ),
            ),
          ),
          // Optional overlay to control animation opacity
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6), // Adjust opacity as needed
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  _buildHeader(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  _buildTitle(),
                  const SizedBox(height: 4),
                  _buildSubtitle(),
                  const SizedBox(height: 24),
                  _buildNameFields(),
                  const SizedBox(height: 20),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 16),
                  _buildAgreementCheckbox(),
                  const SizedBox(height: 24),
                  _buildSignupButton(),
                  const SizedBox(height: 30),
                  //_buildDivider(),
                  //const SizedBox(height: 4),
                  //_buildSocialSignup(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/icon/briefcase-svgrepo.svg', height: 60),
        const SizedBox(width: 8),
        Column(
          children: [
            Text(
              'Workie.LK'.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                height: 1.1,
                fontSize: 34,
              ),
            ),
            Text(
              'Empowering People'.toUpperCase(),
              style: TextStyle(
                letterSpacing: 4.6,
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        children: [
          Text(
            'Create Account,',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 24,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.signupGuide,
              maxLines: 3,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15,
                height: 1.2,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        children: [
          Expanded(
            child: SimpleTextfield(
              controller: _firstNameController,
              lableText: 'First Name',
              hintText: 'First Name',
              prefixIconData: Icon(Iconsax.user_copy, color: AppColors.textSilver),
              obscureText: false,
              errorText: _firstNameError,
            ),
          ),
          Expanded(
            child: SimpleTextfield(
              controller: _lastNameController,
              lableText: 'Last Name',
              hintText: 'Last Name',
              prefixIconData: Icon(Iconsax.user_copy, color: AppColors.textSilver),
              obscureText: false,
              errorText: _lastNameError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: CustomTextfield(
        controller: _emailController,
        lableText: 'Email Address',
        hintText: 'Email Address',
        prefixIconData: Icon(Iconsax.send_1_copy, color: AppColors.textSilver),
        suffixIconData: IconButton(
          onPressed: () {
            _emailController.clear();
            setState(() => _emailError = null);
          },
          icon: Icon(Icons.close_outlined, color: AppColors.textSilver),
        ),
        obscureText: false,
        errorText: _emailError,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: CustomTextfield(
        controller: _passwordController,
        lableText: 'Password',
        hintText: 'Password',
        prefixIconData: Icon(Iconsax.lock_copy, color: AppColors.textSilver),
        suffixIconData: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.iconSilver,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        obscureText: _obscureText,
        errorText: _passwordError,
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: CustomTextfield(
        controller: _confirmPasswordController,
        lableText: 'Confirm Password',
        hintText: 'Confirm Password',
        prefixIconData: Icon(Iconsax.lock_copy, color: AppColors.textSilver),
        suffixIconData: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.iconSilver,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        obscureText: _obscureText,
        errorText: _confirmPassowrdError,
      ),
    );
  }

  Widget _buildAgreementCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault * 3.6),
      child: Row(
        children: [
          InkWell(
            onTap: () => setState(() => _isChecked = !_isChecked),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isChecked ? const Color(0xFF4E6BF5) : Colors.grey,
                  width: 2,
                ),
              ),
              child: _isChecked ? const Icon(Iconsax.tick_circle, size: 14, color: Color(0xFF4E6BF5)) : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
                children: [
                  const TextSpan(
                    text: 'I confirm that I have read, consent and agree to WORKIE\'s ',
                  ),
                  TextSpan(
                    text: 'Terms of Use',
                    style: TextStyle(
                      decorationColor: Theme.of(context).colorScheme.inversePrimary,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SplashScreen()),
                        );
                        if (kDebugMode) print('Terms of Use tapped!');
                      },
                  ),
                  const TextSpan(
                    text: ' and ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, height: 1),
                  ),
                  TextSpan(
                    text: 'Privacy Policy.',
                    style: TextStyle(
                      decorationColor: Theme.of(context).colorScheme.inversePrimary,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SplashScreen()),
                        );
                        if (kDebugMode) print('Privacy Policy tapped!');
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault * 3.6),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            _handleSignup();
            _dismissKeyboard();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E6BF5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
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
                'Sign up',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomAppBar(
      height: 50,
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already a member?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Log in',
              style: TextStyle(
                decorationColor: Color(0xFF4E6BF5),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF4E6BF5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}