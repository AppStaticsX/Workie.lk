import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../services/profile_service.dart';
import 'start_page.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final GlobalKey<AddPersonalDetailsPageState> _personalDetailsKey = GlobalKey();
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
        bool isValid = _personalDetailsKey.currentState?.validateInputs() ?? false;
        if (!isValid) {
          _showSnackBar('Please fill all required personal details to continue.');
          return;
        }
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

  Future<void> _testBackendConnection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Testing backend connection...'),
            ],
          ),
        );
      },
    );

    try {
      final healthResult = await ProfileService.testServerHealth();
      final mediaResult = await ProfileService.testMediaRoute();

      Navigator.of(context).pop(); // Close loading dialog

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Backend Test Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Check: ${healthResult['success'] ? 'Success' : 'Failed'}'),
                if (!healthResult['success'])
                  Text('Error: ${healthResult['message']}'),
                const SizedBox(height: 8),
                Text('Media Route: ${mediaResult['success'] ? 'Success' : 'Failed'}'),
                if (!mediaResult['success'])
                  Text('Error: ${mediaResult['message']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showSnackBar('Test failed: $e');
    }
  }

// Update the _handleProfileCompletion method
  Future<void> _handleProfileCompletion() async {
    final personalDetailsState = _personalDetailsKey.currentState;
    if (personalDetailsState == null) return;

    // Check if user has selected an image
    if (personalDetailsState.profileImage == null && personalDetailsState.profileImageBytes == null) {
      _showSnackBar('Please select a profile picture to continue.');
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Uploading profile picture...'),
            ],
          ),
        );
      },
    );

    try {
      // Generate filename for the image
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (kDebugMode) {
        print('Starting profile picture upload...');
      }

      // Upload only the profile picture
      final result = await ProfileService.uploadProfilePicture(
        imageFile: personalDetailsState.profileImage,
        imageBytes: personalDetailsState.profileImageBytes,
        fileName: fileName,
      );

      // Hide loading indicator
      Navigator.of(context).pop();

      if (result['success']) {
        _showSnackBar('Profile picture uploaded successfully!');

        // Navigate to next screen or main app
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => MainDashboard()),
        // );
      } else {
        // Show detailed error message
        String errorMessage = result['message'] ?? 'Failed to upload profile picture';
        if (result['statusCode'] != null) {
          errorMessage += ' (Status: ${result['statusCode']})';
        }
        _showSnackBar(errorMessage);

        if (kDebugMode) {
          print('Profile picture upload failed: $result');
        }
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();

      if (kDebugMode) {
        print('Profile picture upload error: $e');
      }
      _showSnackBar('An error occurred while uploading your profile picture');
    }
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: Colors.transparent,
        leading: const Icon(
          CupertinoIcons.person_crop_circle_badge_plus,
          color: Colors.white,
          size: 36,
        ),
        title: Text('Create & Verify Your Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold
          )
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_selectedIndex) / (_maxIndex + 1),
            backgroundColor: _selectedIndex == 0? Colors.transparent : Colors.grey.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white,
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
          AddPersonalDetailsPage(key: _personalDetailsKey),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: IndexedStack(
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
              onTapAction: () {
                _navigateNext();
                _dismissKeyboard();
                },
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
      ),
    );
  }
}