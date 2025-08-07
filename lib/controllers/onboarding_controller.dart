import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workie/authentication/pages/login_page.dart';

class OnboardingController extends GetxController with GetTickerProviderStateMixin {
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // Animation controllers for smooth transitions
  late AnimationController buttonAnimationController;
  late AnimationController pageTransitionController;

  @override
  void onInit() {
    super.onInit();

    // Initialize animation controllers
    buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  void updatePageIndicator(index) {
    currentPageIndex.value = index;

    // Trigger button animation when page changes
    buttonAnimationController.reset();
    buttonAnimationController.forward();
  }

  void dotNavigationClick(index) {
    currentPageIndex.value = index;

    // Smooth page transition with custom curve
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );

    // Add haptic feedback for better UX
    _triggerHapticFeedback();
  }

  void skipPage() {
    // Animate to last page with smooth transition
    pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutQuart,
    );

    _triggerHapticFeedback();
  }

  void nextPage() {
    if (currentPageIndex.value == 2) {
      // Navigate to login with custom transition
      _navigateToLogin();
    } else {
      int nextPage = currentPageIndex.value + 1;

      // Smooth page transition
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );

      _triggerHapticFeedback();
    }
  }

  void _navigateToLogin() {
    // Add completion animation
    pageTransitionController.forward().then((_) {
      Get.off(
            () => LoginPage(),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });

    _triggerHapticFeedback();
  }

  void _triggerHapticFeedback() {
    // Add subtle haptic feedback for better user experience
    try {
      // Only trigger if platform supports it
      if (GetPlatform.isAndroid || GetPlatform.isIOS) {
        // You can add haptic feedback here if you have the package
        // HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Silently handle if haptic feedback is not available
    }
  }

  // Method to restart animations when needed
  void restartAnimations() {
    buttonAnimationController.reset();
    pageTransitionController.reset();
    buttonAnimationController.forward();
  }

  // Animation getters for use in UI
  Animation<double> get buttonScaleAnimation => Tween<double>(
    begin: 1.0,
    end: 1.1,
  ).animate(CurvedAnimation(
    parent: buttonAnimationController,
    curve: Curves.elasticOut,
  ));

  Animation<double> get pageTransitionAnimation => Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: pageTransitionController,
    curve: Curves.easeInOut,
  ));

  @override
  void onClose() {
    // Dispose all controllers properly
    pageController.dispose();
    buttonAnimationController.dispose();
    pageTransitionController.dispose();
    super.onClose();
  }
}