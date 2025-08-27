import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_education_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_experience_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_personal_details_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_skills_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_title_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/select_work_page.dart';
import 'package:workie/widgets/bottom_navigation.dart';
import 'package:workie/widgets/bottom_navigation_with_skip.dart';
import 'package:workie/widgets/simple_bottom_navigation.dart';
import '../../../services/hive_service.dart';
import 'start_page.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  int _selectedIndex = 0;
  final int _maxIndex = 6;

  bool _hasWorkSelection = false;
  bool _hasSkills = false;
  bool _hasText = false;
  bool _hasExperience = false;
  bool _hasEducation = false;

  @override
  void initState() {
    super.initState();
    _initializeHive();
    _checkForExistingWorkSelection();
  }

  Future<void> _initializeHive() async {
    try {
      await HiveService.initHive();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Hive: $e');
      }
    }
  }

  Future<void> _checkForExistingWorkSelection() async {
    try {
      final hasSelection = await HiveService.hasWorkSelection();
      setState(() {
        _hasWorkSelection = hasSelection;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error checking existing work selection: $e');
      }
    }
  }

  void _navigateNext() {
    switch (_selectedIndex) {
      case 0:
        break;
      case 1:
        if (!_hasWorkSelection) {
          _showSnackBar('Please select at least one work option to continue.');
          return;
        }
        _saveWorkSelectionOnContinue();
        break;
      case 2:
        if (!_hasSkills) {
          _showSnackBar('Please add at least one skill to continue.');
          return;
        }
        break;
      case 3:
        if (!_hasText) {
          _showSnackBar('Please enter your professional title to continue.');
          return;
        }
        break;
      case 4:
        if (!_hasExperience) {
          _showSnackBar('Please add at least one work experience to continue, or use the skip button.');
          return;
        }
        break;
      case 5:
        if (!_hasEducation) {
          _showSnackBar('Please add at least one education to continue, or use the skip button.');
          return;
        }
        break;
      case 6:
        _handleProfileCompletion();
        return;
      default:
        break;
    }

    if (_selectedIndex < _maxIndex) {
      setState(() {
        _selectedIndex++;
      });

      if (kDebugMode) {
        print('Navigated to index: $_selectedIndex');
        if (_selectedIndex == 6) {
          print('Now showing AddPersonalDetailsPage');
        }
      }
    }
  }

  Future<void> _saveWorkSelectionOnContinue() async {
    try {
      final savedData = await HiveService.getWorkSelection();
      if (savedData != null) {
        if (kDebugMode) {
          print('Work selection saved successfully: ${savedData.categoryTitle}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error confirming work selection save: $e');
      }
    }
  }

  void _navigateBack() {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex--;
      });

      if (kDebugMode) {
        print('Navigated back to index: $_selectedIndex');
      }
    }
  }

  void _skipNext() {
    if (_selectedIndex < _maxIndex) {
      setState(() {
        _selectedIndex++;
      });

      if (kDebugMode) {
        print('Skipped to index: $_selectedIndex');
        if (_selectedIndex == 6) {
          print('Skipped to AddPersonalDetailsPage');
        }
      }
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: Colors.transparent,
        leading: const Icon(
          Iconsax.user_copy,
          color: Colors.white,
          size: 26,
        ),
        title: const Text('Create & Verify Your Profile',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_selectedIndex) / (_maxIndex + 1),
            backgroundColor: _selectedIndex == 0? Colors.transparent : Colors.grey.withValues(alpha: 0.3),
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
          const AddPersonalDetailsPage(),
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
            actionName: 'Add Personal Info',
            onTapAction: _navigateNext,
            onBackAction: _navigateBack,
            onSkip: _skipNext,
          ),
          BottomNavigation(
            actionName: 'Complete Profile',
            onTapAction: _navigateNext,
            onBackAction: _navigateBack,
          ),
        ],
      ),
    );
  }
}