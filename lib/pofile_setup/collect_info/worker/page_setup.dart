import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_education_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_experience_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_skills_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_title_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/select_work_page.dart'; // Add this new page import
import 'package:workie/widgets/bottom_navigation.dart';
import 'package:workie/widgets/bottom_navigation_with_skip.dart';
import 'package:workie/widgets/simple_bottom_navigation.dart';
import 'start_page.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  int _selectedIndex = 0;
  final int _maxIndex = 5;

  bool _hasWorkSelection = false;
  bool _hasSkills = false;
  bool _hasText = false;
  bool _hasExperience = false;
  bool _hasEducation = false;

  void _navigateNext() {
    // Validation for each step
    switch (_selectedIndex) {
      case 0:
        break;
      case 1:
      // Select work page validation
        if (!_hasWorkSelection) {
          _showSnackBar('Please select at least one work option to continue.');
          return;
        }
        break;
      case 2:
      // Add skills page validation
        if (!_hasSkills) {
          _showSnackBar('Please add at least one skill to continue.');
          return;
        }
        break;
      case 3:
      // Add title page validation
        if (!_hasText) {
          _showSnackBar('Please enter your professional title to continue.');
          return;
        }
        break;
      case 4:
      // Experience page validation - prevent navigation if no experience added
        if (!_hasExperience) {
          _showSnackBar('Please add at least one work experience to continue, or use the skip button.');
          return;
        }
        break;
      case 5:
      // Education page - handle completion or navigation to next flow
        _handleProfileCompletion();
        return;
      case 6:
      // Overview page - final step
        _handleProfileCompletion();
        return;
      default:
        break;
    }

    // Navigate to next page if validation passes
    if (_selectedIndex < _maxIndex) {
      setState(() {
        _selectedIndex++;
      });
    } else {
      // Handle completion when reached the end
      _handleProfileCompletion();
    }
  }

  void _navigateBack() {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex--;
      });
    }
  }

  void _skipNext() {
    if (_selectedIndex < _maxIndex) {
      setState(() {
        _selectedIndex++;
      });
    } else {
      // Handle completion when skipping from the last page
      _handleProfileCompletion();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  void _handleProfileCompletion() {
    _showSnackBar('Profile setup completed!');
    // Add navigation to next screen or complete the flow
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextScreen()));
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
        // Progress indicator
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_selectedIndex + 1) / (_maxIndex + 1),
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
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
          AddTitlePage(
            onTextChanged: (hasText) {
              setState(() {
                _hasText = hasText;
              });
            },
          ),
          AddExperiencePage(
            onExperienceChanged: (hasExperience) {
              setState(() {
                _hasExperience = hasExperience;
              });
            },
          ),
          AddEducationPage(
            onEducationChanged: (hasEducation) {
              setState(() {
                _hasEducation = hasEducation;
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
            actionName: 'Add Experience',
            onTapAction: _navigateNext,
            onBackAction: _navigateBack,
          ),
          BottomNavigationWithSkip(
            actionName: 'Add Education',
            onTapAction: _navigateNext,
            onBackAction: _navigateBack,
            onSkip: _skipNext,
          ),
          BottomNavigationWithSkip(
            actionName: 'Write an Overview',
            onTapAction: _navigateNext,
            onBackAction: _navigateBack,
            onSkip: _skipNext,
          ),
          BottomNavigationWithSkip(
            actionName: 'Complete Profile',
            onTapAction: _navigateNext,
            onBackAction: _navigateBack,
            onSkip: _skipNext,
          ),
        ],
      ),
    );
  }
}