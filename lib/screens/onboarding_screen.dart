import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:workie/authentication/pages/login_page.dart';
import 'package:workie/controllers/onboarding_controller.dart';
import 'package:workie/values/string.dart';
import 'package:get/get.dart';

import '../providers/language_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _showLanguageBottomSheet(BuildContext context) {
    final _ = Provider.of<LanguageProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<LanguageProvider>(
        builder: (context, provider, child) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Language options
                _buildLanguageOption(
                  context,
                  'English',
                  'en',
                  Iconsax.language_square_copy,
                  provider.locale.languageCode == 'en',
                  provider,
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  'සිංහල',
                  'si',
                  Iconsax.language_square_copy,
                  provider.locale.languageCode == 'si',
                  provider,
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  'தமிழ்',
                  'ta',
                  Iconsax.language_square_copy,
                  provider.locale.languageCode == 'ta',
                  provider,
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context,
      String language,
      String code,
      IconData icon,
      bool isSelected,
      LanguageProvider languageProvider,
      ) {
    return GestureDetector(
      onTap: () {
        // Handle language selection
        languageProvider.setLocale(Locale(code));
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4E6BF5).withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF4E6BF5) : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4E6BF5) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF4E6BF5) : Colors.grey[800],
                  letterSpacing: 2
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: const Color(0xFF4E6BF5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnBoardWidget(
                imagePath: 'assets/image/onboarding_image_1.svg',
                onBoardTitle: 'Find the Perfect Match - Fast',
                onBoardSubTitle: AppStrings.onBoardSubtitle1,
                pageIndex: 0,
              ),
              OnBoardWidget(
                imagePath: 'assets/image/onboarding_image_2.svg',
                onBoardTitle: 'Connect with Top Employers',
                onBoardSubTitle: AppStrings.onBoardSubtitle1,
                pageIndex: 1,
              ),
              OnBoardWidget(
                imagePath: 'assets/image/onboarding_image_3.svg',
                onBoardTitle: 'Start Your Career Journey',
                onBoardSubTitle: AppStrings.onBoardSubtitle1,
                pageIndex: 2,
              ),
            ],
          ),

          Positioned(
              top: MediaQuery.of(context).padding.top + 24,
              left: 32,
              child: Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return GestureDetector(
                    onTap: () {
                      _showLanguageBottomSheet(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                              width: 1.5,
                              color: const Color(0xFF4E6BF5)
                          ),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Iconsax.translate),
                            SizedBox(width: 8,),
                            Text(
                              languageProvider.getLanguageDisplayText(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.8,
                                fontSize: languageProvider.locale.languageCode == 'si' ||
                                    languageProvider.locale.languageCode == 'ta' ? 13 : 14,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
          ),
          const AnimatedDotIndicator(),
          // Animated Next/Finish Button
          Positioned(
            right: 40,
            bottom: MediaQuery.of(context).padding.bottom + 60,
            child: Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4E6BF5).withValues(alpha: 0.3),
                    blurRadius: controller.currentPageIndex.value == 2 ? 20 : 8,
                    spreadRadius: controller.currentPageIndex.value == 2 ? 4 : 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedScale(
                scale: controller.currentPageIndex.value == 2 ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.currentPageIndex.value == 2
                        ? const Color(0xFF4E6BF5)
                        : const Color(0xFF4E6BF5),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (controller.currentPageIndex.value == 2) {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: animation.drive(
                                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                                    .chain(CurveTween(curve: Curves.easeInOut)),
                              ),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    } else {
                      controller.nextPage();
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 00),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      controller.currentPageIndex.value == 2
                          ? Icons.check
                          : Iconsax.arrow_right_3_copy,
                      key: ValueKey(controller.currentPageIndex.value),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

class AnimatedDotIndicator extends StatelessWidget {
  const AnimatedDotIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 80,
      left: 40,
      child: Obx(() => AnimatedSlide(
        offset: Offset(0, controller.currentPageIndex.value == 2 ? 0.5 : 0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: controller.currentPageIndex.value == 2 ? 0.7 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: SmoothPageIndicator(
            controller: controller.pageController,
            onDotClicked: controller.dotNavigationClick,
            count: 3,
            effect: ExpandingDotsEffect(
              activeDotColor: controller.currentPageIndex.value == 2
                  ? const Color(0xFF4E6BF5)
                  : const Color(0xFF4E6BF5),
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 8,
            ),
          ),
        ),
      )),
    );
  }
}

class OnBoardWidget extends StatefulWidget {
  const OnBoardWidget({
    super.key,
    required this.imagePath,
    required this.onBoardTitle,
    required this.onBoardSubTitle,
    required this.pageIndex,
  });

  final String imagePath, onBoardTitle, onBoardSubTitle;
  final int pageIndex;

  @override
  State<OnBoardWidget> createState() => _OnBoardWidgetState();
}

class _OnBoardWidgetState extends State<OnBoardWidget>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _textController;
  late Animation<double> _imageAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _imageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Start animations with staggered delays
    Future.delayed(Duration(milliseconds: widget.pageIndex * 200), () {
      if (mounted) {
        _imageController.forward();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _textController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),

          // Animated SVG Image
          AnimatedBuilder(
            animation: _imageAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _imageAnimation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    boxShadow: _imageAnimation.value > 0.8
                        ? [
                      BoxShadow(
                        color: const Color(0xFF4E6BF5).withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ]
                        : [],
                  ),
                  child: SvgPicture.asset(
                    widget.imagePath,
                    height: 300,
                    width: 300,
                    placeholderBuilder: (context) => Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 36),

          // Animated Title
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _textAnimation,
              child: Text(
                widget.onBoardTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Animated Subtitle
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_textController),
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 0.8,
              ).animate(_textController),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.onBoardSubTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        ],
      ),
    );
  }
}