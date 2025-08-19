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
  final int _maxIndex = 3;

  bool _hasWorkSelection = false;
  bool _hasSkills = true; // Default true for initial skills, will update

  void _navigateNext() {
    if (_selectedIndex == 1 && !_hasWorkSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one option to continue.')),
      );
      return;
    }
    if (_selectedIndex == 2 && !_hasSkills) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one skill to continue.')),
      );
      return;
    }
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
          SelectWorkPage(
            onSelectionChanged: (hasSelection) {
              setState(() {
                _hasWorkSelection = hasSelection;
              });
            },
          ),
          AddSkillsPage(
            onSkillsChanged: (hasSkills) {
              setState(() {
                _hasSkills = hasSkills;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: IndexedStack(
        index: _selectedIndex,
        children: [
          SimpleBottomNavigation(
            actionName: 'Let\'s Continue',
            onTapAction: _navigateNext,
          ),
          BottomNavigation(
            actionName: 'Add Skills',
            onTapAction: _navigateNext,
            onBackAction: _navigateBack,
          ),
          BottomNavigation(
            actionName: 'Add Profile Title',
            onTapAction: _navigateNext,
            onBackAction: _navigateBack,
          ),
          BottomNavigation(
            actionName: 'Finish',
            onTapAction: () {
              Navigator.of(context).pushReplacementNamed('/main');
            },
            onBackAction: _navigateBack,
          ),
        ],
      ),
    );
  }
}