import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_skills_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/select_work_page.dart';
import 'package:workie/widgets/bottom_navigation.dart';
import 'package:workie/widgets/simple_bottom_navigation.dart';
import 'start_page.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  int _selectedIndex = 0;
  final int _maxIndex = 3; // Define max index for safety

  void _navigateNext() {
    if (_selectedIndex < _maxIndex) {
      setState(() {
        _selectedIndex++;
      });
    }
  }

  void _navigateBack() {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        surfaceTintColor: Colors.transparent,
        leading: const Icon(
          Iconsax.user_copy,
          size: 26,
        ),
        title: const Text('Create & Verify Your Profile'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const WorkerCollectInfoStartPage(),
          const SelectWorkPage(),
          const AddSkillsPage()
        ],
      ),
      bottomNavigationBar: IndexedStack(
        index: _selectedIndex,
        children: [
          SimpleBottomNavigation(
              actionName: 'Let\'s Get Started',
              onTapAction: _navigateNext,
          ),
          BottomNavigation(
            actionName: 'Next',
            onTapAction: _navigateNext,
            onBackAction: _navigateBack,
          ),
          BottomNavigation(
            actionName: 'Next',
            onTapAction: _navigateNext,
            onBackAction: _navigateBack,
          ),
          BottomNavigation(
            actionName: 'Finish',
            onTapAction: () {
              // Handle completion - maybe navigate to main app
              Navigator.of(context).pushReplacementNamed('/main');
            },
            onBackAction: _navigateBack,
          ),
        ],
      ),
    );
  }
}