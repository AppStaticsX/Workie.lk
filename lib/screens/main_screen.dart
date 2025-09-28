import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workie/pages/explore_page.dart';
import 'package:workie/pages/home_page.dart';
import 'package:workie/pages/post_page.dart';
import '../pages/activity_page.dart';
import '../pages/profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String selectedRole = '';

  @override
  void initState() {
    super.initState();
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeTabPage(),
          const ExploreTabPage(),
          PostPage(navigatePage: () {
            _navigateBottomBar(0);
          }),
          const ActivityTabPage(),
          ProfileTabPage(onCreatePost: (){
            setState(() {
              _navigateBottomBar(2);
            });
          }),
        ],
      ), // Display the selected page
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24)
              )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildAnimatedNavIcon(Iconsax.home_copy, Iconsax.home_1, 0, 'Home'),
              buildAnimatedNavIcon(Iconsax.location_copy, Iconsax.location, 1, 'Explore'),
              //buildPlusNavIcon('assets/icon/menu_button.png', 'assets/icon/menu_button.png', 2, 'Post'),
              buildAnimatedNavIcon(Iconsax.element_2_copy, Iconsax.element_2, 2, 'Post'),
              buildAnimatedNavIcon(Iconsax.video_play_copy, Iconsax.video_play, 3, 'Reels'),
              buildAnimatedNavIcon(Iconsax.user_copy, Iconsax.user, 4, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAnimatedNavIcon(IconData icon, IconData activeIcon, int index, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _navigateBottomBar(index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8, top: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated top line indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 3,
              width: isSelected ? 30 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF4E6BF5),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(height: 8),
            // Animated icon switcher
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey('${index}_$isSelected'),
                color: isSelected ? const Color(0xFF4E6BF5) : Colors.grey.shade600,
                size: isSelected ? 28 : 24,
              ),
            ),
            const SizedBox(height: 4),
            // Animated text
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? const Color(0xFF4E6BF5) : Colors.grey.shade600,
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label, style: TextStyle(fontFamily: 'Google Sans'),),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildPlusNavIcon(String icon, String activeIcon, int index, String lable) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _navigateBottomBar(index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8, top: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 3,
              width: isSelected ? 30 : 0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(height: 8),
            // Animated icon switcher
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Image.asset(
                  isSelected? activeIcon : icon,
                key: ValueKey('${index}_$isSelected'),
                width: isSelected? 24 : 24,
                color: isSelected ? const Color(0xFF4E6BF5) : Colors.grey.shade600, // Add this line
                colorBlendMode: BlendMode.srcIn, // Optional: controls how color is applied
              )
              /*Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey('${index}_$isSelected'),
                color: isSelected ? const Color(0xFF4E6BF5) : Colors.grey.shade600,
                size: isSelected ? 28 : 24,
              ),*/

            ),
            const SizedBox(height: 4),
            // Animated text
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? const Color(0xFF4E6BF5) : Colors.grey.shade600,
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(lable, style: TextStyle(fontFamily: 'Google Sans')),
            ),
          ],
        ),
      ),
    );
  }
}