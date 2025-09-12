import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_education_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_experience_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_overview_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_personal_details_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_skills_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/add_title_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/select_work_page.dart';
import 'package:workie/pofile_setup/verification/worker/start_page.dart';
import 'package:workie/widgets/bottom_navigation.dart';
import 'package:workie/widgets/bottom_navigation_with_skip.dart';
import 'package:workie/widgets/simple_bottom_navigation.dart';
import '../../../services/add_skills_service.dart';
import '../../../services/hive_service.dart';
import '../../../services/overview_service.dart';
import '../../../services/profile_service.dart';
import '../../../services/work_category_service.dart';
import 'start_page.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final GlobalKey<AddPersonalDetailsPageState> _personalDetailsKey = GlobalKey();
  final GlobalKey<AddOverviewPageState> _overviewDetailsKey = GlobalKey();
  final GlobalKey<AddSkillsPageState> _addSkillsKey = GlobalKey();
  int _selectedIndex = 0;
  final int _maxIndex = 7;

  bool _hasWorkSelection = false;
  bool _hasSkills = false;
  bool _hasTitle = false;
  bool _hasExperience = false;
  bool _hasEducation = false;
  bool _isCompletingProfile = false;
  bool _isSaving = false;

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
        _saveWorkCategory();
        return;
      case 2:
        if (!_hasSkills) {
          _showSnackBar('Please add at least one skill to continue.');
          return;
        }
        _saveSkills();
        return;
      case 3:
        if (!_hasTitle) {
          _showSnackBar('Please enter your professional title to continue.');
          return;
        }
        break;
      case 4:
        final overviewState = _overviewDetailsKey.currentState;
        if (overviewState == null || overviewState.overviewController.text.trim().length < 100) {
          _showSnackBar('Please write at least 100 characters in your overview to continue.');
          return;
        }
        _saveOverview(); // This will handle navigation internally
        return;
      case 5:
        if (!_hasExperience) {
          _showSnackBar('Please add at least one work experience to continue, or use the skip button.');
          return;
        }

        break;

      case 6:
        if (!_hasEducation) {
          _showSnackBar('Please add at least one education to continue, or use the skip button.');
          return;
        }
        break;
      case 7:
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

  Future<void> _saveSkills() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final userId = await AddSkillsService.getCurrentUserId();
      final addSkillsState = _addSkillsKey.currentState;

      if (userId == null) {
        _showSnackBar('Error: User not logged in');
        return;
      }

      if (addSkillsState?.selectedSkills == null || addSkillsState!.selectedSkills.isEmpty) {
        _showSnackBar('No skills selected to save');
        return;
      }

      final result = await AddSkillsService.addSkillsToProfile(
        userId: userId,
        skills: addSkillsState.selectedSkills,
        defaultLevel: 'beginner',
        defaultExperience: 0,
      );

      if (result?['success'] == true) {
        if (kDebugMode) {
          print('Added ${result?['added']} skills successfully');
          print('Skipped ${result?['skipped']} existing skills');
        }

        // Navigate to next page after successful save
        if (_selectedIndex < _maxIndex) {
          setState(() {
            _selectedIndex++;
          });
        }
      } else {
        _showSnackBar('Failed to save skills: ${result?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving skills: $e');
      }
      _showSnackBar('An error occurred while saving skills');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _saveWorkCategory() async {
    try {
      setState(() {
        _isSaving = true;
      });

      // Check if we have work selection using the same method as validation
      final hasWorkSelection = await HiveService.hasWorkSelection();
      if (!hasWorkSelection) {
        _showSnackBar('No work selection found. Please select at least one work option.');
        return;
      }

      if (kDebugMode) {
        print('Work selection confirmed, proceeding to save...');
      }

      // Save to backend database
      final success = await WorkCategoryService.saveWorkCategoriesToProfile();

      if (success) {
        if (kDebugMode) {
          print('Work categories saved to backend database successfully');
        }
        // Navigate to next page after successful save
        if (_selectedIndex < _maxIndex) {
          setState(() {
            _selectedIndex++;
          });
        }
      } else {
        if (kDebugMode) {
          print('Failed to save work categories to backend database');
        }
        _showSnackBar('Failed to save work categories. Please try again.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving work categories: $e');
      }
      _showSnackBar('An error occurred while saving work categories.');
    } finally {
      setState(() {
        _isSaving = false;
      });
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

  Future<void> _saveOverview() async {
    final overviewDetailsState = _overviewDetailsKey.currentState;
    if (overviewDetailsState?.overviewController.text.isEmpty ?? true) {
      _showSnackBar('Please enter your overview to continue.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await OverviewService.saveOverview(
          overviewDetailsState!.overviewController.text.trim()
      );

      if (success) {
        // Navigate to next page after successful save
        if (_selectedIndex < _maxIndex) {
          setState(() {
            _selectedIndex++;
          });

          if (kDebugMode) {
            print('Overview saved successfully, navigated to index: $_selectedIndex');
          }
        }
      } else {
        _showSnackBar('Failed to save overview. Please try again.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving overview: $e');
      }
      _showSnackBar('An error occurred while saving your overview.');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

// Update the _handleProfileCompletion method
  // Update the _handleProfileCompletion method
  Future<void> _handleProfileCompletion() async {
    if (_isCompletingProfile || _isSaving) return; // Prevent multiple calls

    setState(() {
      _isCompletingProfile = true;
      _isSaving = true; // Add this to show loading state in UI
    });

    try {
      // Check if user is authenticated
      final isAuthenticated = await ProfileService.isAuthenticated();
      if (!isAuthenticated) {
        _showSnackBar('Error: Please log in again.');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      // Get current user ID
      final userId = await ProfileService.getCurrentUserId();
      if (userId == null) {
        _showSnackBar('Error: User not found. Please log in again.');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      // Get personal details from the form
      final personalDetailsState = _personalDetailsKey.currentState;
      if (personalDetailsState == null) {
        _showSnackBar('Error: Unable to access personal details form.');
        return;
      }

      // Validate the form data
      final isValid = ProfileService.validateProfileData(
        dateOfBirth: personalDetailsState.birthDayController.text,
        streetAddress: personalDetailsState.streetAddressController.text,
        city: personalDetailsState.cityController.text,
        stateOrProvince: personalDetailsState.stateOrProvinceController.text,
        postalCode: personalDetailsState.postalCodeController.text,
        phoneNumber: personalDetailsState.phoneNumberController.text,
        profileImage: personalDetailsState.profileImage,
        profileImageBytes: personalDetailsState.profileImageBytes,
      );

      if (!isValid) {
        _showSnackBar('Please fill all required fields and add a profile picture.');
        return;
      }

      DateTime? dob;
      try {
        dob = DateTime.parse(personalDetailsState.birthDayController.text);
      } catch (_) {
        dob = null;
      }
      if (dob == null) {
        _showSnackBar('Invalid date of birth format.');
        return;
      }

      final profileResult = await ProfileService.savePersonalDetailsToProfile(
        userId: userId,
        dateOfBirth: dob,
        streetAddress: personalDetailsState.streetAddressController.text,
        city: personalDetailsState.cityController.text,
        province: personalDetailsState.stateOrProvinceController.text,
        postalCode: personalDetailsState.postalCodeController.text,
        phoneNumber: personalDetailsState.phoneNumberController.text,
        apartmentOrSuite: personalDetailsState.apartmentOrSuiteController.text.isNotEmpty
            ? personalDetailsState.apartmentOrSuiteController.text
            : null,
        profileImage: personalDetailsState.profileImage,
        profileImageBytes: personalDetailsState.profileImageBytes,
      );

      if (kDebugMode) {
        print('savePersonalDetailsToProfile result: $profileResult');
      }

      if (profileResult != null) {
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WorkerVerificationStartPage()
              )
          );
        }
      } else {
        _showSnackBar('Failed to complete profile. Please try again.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error completing profile: $e');
      }
      _showSnackBar('An error occurred while completing your profile.');
    } finally {
      if (mounted) {
        setState(() {
          _isCompletingProfile = false;
          _isSaving = false; // Reset both states
        });
      }
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
          CupertinoIcons.person_2_fill,
          color: Colors.white,
          size: 30,
        ),
        title: Text('Create & Verify Your Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              color: Colors.white
            )
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_selectedIndex) / (_maxIndex),
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
            key: _addSkillsKey,
            onSkillsChanged: (hasSkills) {
              setState(() {
                _hasSkills = hasSkills;
              });
            },
          ),
          AddTitlePage(
            onTextChanged: (hasTitle) {
              setState(() {
                _hasTitle = hasTitle;
              });
            },
          ),
          AddOverviewPage(
            key: _overviewDetailsKey,
            onTextChanged: (hasOverview) {
              setState(() {
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
              isSaving: _isSaving,
              actionName: 'Add Skills',
              onTapAction: _navigateNext,
              onBackAction: _navigateBack,
            ),
            BottomNavigation(
              isSaving: _isSaving,
              actionName: 'Add Profile Title',
              onTapAction: _navigateNext,
              onBackAction: _navigateBack,
            ),
            BottomNavigation(
              isSaving: _isSaving,
              actionName: 'Add Overview',
              onTapAction: _navigateNext,
              onBackAction: _navigateBack,
            ),
            BottomNavigation(
              isSaving: _isSaving,
              actionName: 'Add Experience',
              onTapAction: _navigateNext,
              onBackAction: _navigateBack,
            ),
            BottomNavigationWithSkip(
              isSaving: _isSaving,
              actionName: 'Add Education',
              onTapAction: () {
                _navigateNext();
                _dismissKeyboard();
              },
              onBackAction: _navigateBack,
              onSkip: _skipNext,
            ),
            BottomNavigationWithSkip(
              isSaving: _isSaving,
              actionName: 'Add Personal Info',
              onTapAction: _navigateNext,
              onBackAction: _navigateBack,
              onSkip: _skipNext,
            ),
            BottomNavigation(
              isSaving: _isSaving,
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