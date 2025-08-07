import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:workie/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToGetStarted();
  }

  _navigateToGetStarted() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 1500), // Custom duration
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(
                begin: 1.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut, // Custom curve
              )),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icon/briefcase-svgrepo.svg',
              height: 150,
              width: 150,
            ),

           const SizedBox(height: 30),

           Text(
              'Workie'.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontFamily: 'Anton',
                letterSpacing: 9.0,
              ),
            ),

            /*Text(
              'Empowering People'.toUpperCase(),
              style: const TextStyle(
                  color: Colors.grey,
                  letterSpacing: 1.2,
                  height: 1.2,
                  fontFamily: 'Fredoka'
              ),
            ),*/
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 80,
        color: Colors.transparent,
        child: Lottie.asset(
          'assets/animation/loading_anim.json',
        ),
      ),
    );
  }
}