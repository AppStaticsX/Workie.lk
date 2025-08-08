import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:workie/authentication/pages/reset_password_page.dart';
import 'package:workie/authentication/pages/signup_page.dart';
import 'package:workie/generated/app_localizations.dart';
import 'package:workie/screens/select_role_screen.dart';
import 'package:workie/screens/splash_screen.dart';
import 'package:workie/widgets/custom_textfield.dart';
import 'package:workie/widgets/custom_toast.dart';
import '../../values/color.dart';
import '../../values/dimension.dart';
import '../../widgets/agreement_dialog.dart';
import '../../widgets/square_tile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin{
  late AnimationController _lottieController;
  Timer? _stopTimer;

  bool _obscureText = true;
  bool _isChecked = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _setupLiveValidation();
    _lottieController = AnimationController(vsync: this);
  }

  void _setupLiveValidation() {
    _emailController.addListener(() => _validateEmail(_emailController.text.trim()));
    _passwordController.addListener(() => _validatePassword(_passwordController.text.trim()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
    } else if (password.length < 6) {
      error = AppLocalizations.of(context)!.passwordTooShort;
    }

    if (_passwordError != error) {
      setState(() => _passwordError = error);
    }
  }

  bool get _hasErrors => _emailError != null || _passwordError != null;

  void _validateAllFields() {
    _validateEmail(_emailController.text.trim());
    _validatePassword(_passwordController.text.trim());
  }

  void _handleLogin() {
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

    _navigateToRoleSelection();
    //_showCustomDialog(context);
  }

  void _showAgreement() {
    showCustomAlertDialog(
      context,
      [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: const TextStyle(
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
          child: Text(
            AppLocalizations.of(context)!.agree,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<void> _navigateToRoleSelection() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const SelectRoleScreen(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));

            var scaleAnimation = Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
            ));

            return SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomToastSuccess.init(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Background Lottie Animation
          Positioned(
            child: Lottie.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/animation/circles-dark.json'
                  : 'assets/animation/circles-light.json',
              controller: _lottieController,
              fit: BoxFit.cover,
              frameRate: FrameRate(120),
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;

                // Start the animation
                _lottieController.forward();

                // Stop after 2 seconds (or any specific time)
                _stopTimer = Timer(Duration(milliseconds: 600), () {
                  if (mounted && _lottieController.isAnimating) {
                    _lottieController.stop();
                  }
                });
              },
            )
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  _buildHeader(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildSubtitle(),
                  const SizedBox(height: 24),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildAgreementCheckbox(),
                  const SizedBox(height: 24),
                  _buildLoginButton(),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 4),
                  _buildSocialLogin(),
                  const SizedBox(height: 16),
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
            AppLocalizations.of(context)!.welcomeBack,
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
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.loginGuide,
              maxLines: 3,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15,
                height: 1.2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: CustomTextfield(
        controller: _emailController,
        lableText: AppLocalizations.of(context)!.emailAddress,
        hintText: AppLocalizations.of(context)!.emailAddress,
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
        errorText: _passwordError,
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
              textAlign: TextAlign.start,
              text: TextSpan(
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context)!.termsAgreement,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: _getLocaleFontSize(),
                    ),
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context)!.termsOfUse,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: _getLocaleFontSize(),
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
                  TextSpan(
                    text: AppLocalizations.of(context)!.and,
                    style: TextStyle(
                      fontSize: _getLocaleFontSize(),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context)!.privacyPolicy,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: _getLocaleFontSize(),
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SplashScreen()),
                        );
                        if (kDebugMode) print('Privacy Policy tapped!');
                      },
                  ),
                  if (_isLocalLanguage())
                    TextSpan(
                      text: AppLocalizations.of(context)!.termsAgreementFull,
                      style: TextStyle(
                        fontSize: _getLocaleFontSize(),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault * 3.6),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            _handleLogin();
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
                AppLocalizations.of(context)!.logIn,
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {},
            child: Text(
              AppLocalizations.of(context)!.contactUs,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: _isLocalLanguage() ? 13 : 15,
                fontWeight: FontWeight.w600,
                //letterSpacing: 0.5,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const ResetPasswordPage(),
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
            },
            child: Text(
              AppLocalizations.of(context)!.forgotPassword,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: _isLocalLanguage() ? 13 : 15,
                fontWeight: FontWeight.w600,
                //letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(thickness: 0.8, color: Theme.of(context).colorScheme.primary, radius: BorderRadius.circular(5)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              AppLocalizations.of(context)!.orContinueWith.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: _isLocalLanguage() ? 12 : 16,
              ),
            ),
          ),
          Expanded(
            child: Divider(thickness: 0.8, color: Theme.of(context).colorScheme.primary, radius: BorderRadius.circular(5)),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (!_isChecked) _showAgreement();
          },
          child: SquareTile(
            imagePath: 'assets/icon/google-color-svgrepo-com.svg',
            provider: AppLocalizations.of(context)!.continueWithGoogle,
          ),
        ),
      ],
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
              pageBuilder: (context, animation, secondaryAnimation) => const SignupPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
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
              AppLocalizations.of(context)!.notAMember,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: _getBottomTextSize(),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.signupNow,
              style: TextStyle(
                decorationColor: const Color(0xFF4E6BF5),
                fontWeight: FontWeight.bold,
                fontSize: _getBottomTextSize(),
                color: const Color(0xFF4E6BF5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isLocalLanguage() {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'si' || locale == 'ta';
  }

  double? _getLocaleFontSize() {
    return _isLocalLanguage() ? 10 : null;
  }

  double _getBottomTextSize() {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'si') return 13;
    if (locale == 'ta') return 10;
    return 16;
  }
}