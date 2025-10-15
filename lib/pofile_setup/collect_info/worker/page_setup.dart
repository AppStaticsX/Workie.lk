import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
import '../../../services/education_data_service.dart';
import '../../../services/experience_data_service.dart';
import '../../../services/hive_service.dart';
import '../../../services/overview_service.dart';
import '../../../services/profile_service.dart';
import '../../../services/title_service.dart';
import '../../../services/work_category_service.dart';
import 'start_page.dart';

class ProfileSetup extends StatefulWidget {
  final int? selectedIndex;
  final VoidCallback? onSuccessRedirect;
  final bool isProfileEditing;

  const ProfileSetup({
    super.key,
    this.selectedIndex,
    this.onSuccessRedirect,
    required this.isProfileEditing
  });

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  // Global keys for accessing child widget states
  final GlobalKey<AddPersonalDetailsPageState> _personalDetailsKey = GlobalKey();
  final GlobalKey<AddOverviewPageState> _overviewDetailsKey = GlobalKey();
  final GlobalKey<AddSkillsPageState> _addSkillsKey = GlobalKey();
  final GlobalKey<AddTitlePageState> _addTitleKey = GlobalKey();
  final GlobalKey<AddEducationPageState> _addEducationKey = GlobalKey();
  final GlobalKey<AddExperiencePageState> _addExperienceKey = GlobalKey();

  // Current step in the profile setup process
  int _selectedIndex = 0;
  final int _maxIndex = 7;

  // Track completion status of each step
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
    _selectedIndex = widget.selectedIndex ?? 0;
    _initializeHive();
    _checkForExistingWorkSelection();
  }

  // Initialize Hive database
  Future<void> _initializeHive() async {
    try {
      await HiveService.initHive();
    } catch (e) {
      // Handle initialization error silently
    }
  }

  // Check if user has already made work selections
  Future<void> _checkForExistingWorkSelection() async {
    try {
      final hasSelection = await HiveService.hasWorkSelection();
      setState(() {
        _hasWorkSelection = hasSelection;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  // Handle navigation to next step with validation
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
        _saveTitle(); // Add this call
        return;
      case 4:
        final overviewState = _overviewDetailsKey.currentState;
        if (overviewState == null || overviewState.overviewController.text.trim().length < 100) {
          _showSnackBar('Please write at least 100 characters in your overview to continue.');
          return;
        }
        _saveOverview();
        return;
      case 5:
        // Save experience data when moving to education page
        if (!_hasExperience) {
          _showSnackBar('Please add at least one work experience to continue, or use the skip button.');
          return;
        }
        _saveExperience();
        return;
      case 6:
        if (!_hasEducation) {
          _showSnackBar('Please add at least one education to continue, or use the skip button.');
          return;
        }
        _saveEducation();
        return;
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

    // Navigate to next step
    if (_selectedIndex < _maxIndex) {
      setState(() {
        _selectedIndex++;
      });
    }
  }

  // Save user's selected skills to backend
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

      // Use replaceSkillsInProfile to replace existing skills with currently selected ones
      final result = await AddSkillsService.replaceSkillsInProfile(
        userId: userId,
        skills: addSkillsState.selectedSkills,
        defaultLevel: 'beginner',
        defaultExperience: 0,
      );

      if (result?['success'] == true) {
        // Show success message
        final replacedCount = result?['replaced'] ?? 0;

        widget.onSuccessRedirect?.call();  // ✅ This calls the function
        
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
      _showSnackBar('An error occurred while saving skills');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Save selected work categories to backend
  Future<void> _saveWorkCategory() async {
    try {
      setState(() {
        _isSaving = true;
      });

      // Verify work selection exists
      final hasWorkSelection = await HiveService.hasWorkSelection();
      if (!hasWorkSelection) {
        _showSnackBar('No work selection found. Please select at least one work option.');
        return;
      }

      // Save to backend database
      final success = await WorkCategoryService.saveWorkCategoriesToProfile();

      if (success) {
        // Navigate to next page after successful save
        if (_selectedIndex < _maxIndex) {
          setState(() {
            _selectedIndex++;
          });
        }
      } else {
        _showSnackBar('Failed to save work categories. Please try again.');
      }
    } catch (e) {
      _showSnackBar('An error occurred while saving work categories.');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Navigate back to previous step
  void _navigateBack() {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex--;
      });
    }
  }

  // Skip current step and move to next
  void _skipNext() {
    if (_selectedIndex < _maxIndex) {
      setState(() {
        _selectedIndex++;
      });
    } else {
      _handleProfileCompletion();
    }
  }

  // Show snackbar message to user
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  // Save user's title to backend
  Future<void> _saveTitle() async {
    final titleState = _addTitleKey.currentState;
    if (titleState?.professionController.text.trim().isEmpty ?? true) {
      _showSnackBar('Please enter your professional title to continue.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final title = titleState!.professionController.text.trim();

      // Validate title
      final validationError = TitleService.validateTitle(title);
      if (validationError != null) {
        _showSnackBar(validationError);
        return;
      }

      final result = await TitleService.saveTitle(title: title);

      if (result['success'] == true) {
        // Navigate to next page after successful save
        if (_selectedIndex < _maxIndex) {
          setState(() {
            _selectedIndex++;
          });
        }
      } else {
        _showSnackBar(result['message'] ?? 'Failed to save title');
      }
    } catch (e) {
      // Extract the actual error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      _showSnackBar(errorMessage);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Save user's overview text to backend
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
        }
      } else {
        _showSnackBar('Failed to save overview. Please try again.');
      }
    } catch (e) {
      _showSnackBar('An error occurred while saving your overview.');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Save user's work experience to backend
  Future<void> _saveExperience() async {
    final experienceState = _addExperienceKey.currentState;
    if (experienceState == null || experienceState.workExperiencesList.isEmpty) {
      _showSnackBar('Please add at least one experience to continue, or use the skip button.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await ExperienceDataService.saveMultipleExperiences(
        experienceList: experienceState.workExperiencesList,
      );

      if (result?['success'] == true) {
        if (_selectedIndex < _maxIndex) {
          setState(() {
            _selectedIndex++;
          });
        }
        widget.onSuccessRedirect?.call();
      } else {
        _showSnackBar(result?['message'] ?? 'Failed to save work experience');
      }
    } catch (e) {
      _showSnackBar('An error occurred while saving work experience');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _saveEducation() async {
    final educationState = _addEducationKey.currentState;
    if (educationState == null || educationState.educationExperiences.isEmpty) {
      _showSnackBar('Please add at least one education to continue, or use the skip button.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await EducationDataService.saveEducationDataWithCertificates(
        educationList: educationState.educationExperiences,
      );

      if (result?['success'] == true) {
        // Navigate to next page after successful save
        widget.onSuccessRedirect?.call();  // ✅ This calls the function

        if (_selectedIndex < _maxIndex) {
          setState(() {
            _selectedIndex++;
          });
        }
      } else {
        _showSnackBar('Failed to save education: ${result?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showSnackBar('An error occurred while saving education data');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Complete profile setup and navigate to verification
  Future<void> _handleProfileCompletion() async {
    if (_isCompletingProfile || _isSaving) return; // Prevent multiple calls

    setState(() {
      _isCompletingProfile = true;
      _isSaving = true;
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

      // Parse date of birth
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

      // Save personal details to profile
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

      if (profileResult != null) {
        // Navigate to verification page
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
      _showSnackBar('An error occurred while completing your profile.');
    } finally {
      if (mounted) {
        setState(() {
          _isCompletingProfile = false;
          _isSaving = false;
        });
      }
    }
  }

  // Dismiss keyboard when needed
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
        leading: Icon( widget.isProfileEditing
          ? Iconsax.user_edit_copy
          : Iconsax.user_copy,
          color: Colors.white,
          size: 28,
        ),
        title: Text(widget.isProfileEditing? 'Edit Your Profile' : 'Create Your Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white
            )
        ),
        // Progress indicator at bottom of app bar
        bottom: widget.isProfileEditing
            ? null
            : PreferredSize(
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
            key: _addTitleKey,
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
            key: _addExperienceKey,
            onExperienceChanged: (hasExperience) {
              setState(() {
                _hasExperience = hasExperience;
              });
            },
          ),
          AddEducationPage(
            key: _addEducationKey,
            onEducationChanged: (hasEducation) {
              setState(() {
                _hasEducation = hasEducation;
              });
            },
          ),
          AddPersonalDetailsPage(key: _personalDetailsKey),
        ],
      ),
      // Different bottom navigation for each step
      bottomNavigationBar: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            SimpleBottomNavigation(
              actionName: 'Let\'s Continue',
              onTapAction: _navigateNext,
            ),
            BottomNavigation(
              isProfileEditing: widget.isProfileEditing,
              isSaving: _isSaving,
              actionName: 'Add Job Category',
              onTapAction: _navigateNext,
              onBackAction: _navigateBack,
            ),
            BottomNavigation(
              isProfileEditing: widget.isProfileEditing,
              isSaving: _isSaving,
              actionName: widget.isProfileEditing? 'Update Your Skills' : 'Add Your Skills',
              onTapAction: _navigateNext,
              onBackAction: _navigateBack,
            ),
            BottomNavigation(
              isProfileEditing: widget.isProfileEditing,
              isSaving: _isSaving,
              actionName: widget.isProfileEditing? 'Update Profile Title' : 'Add Profile Title',
              onTapAction: _navigateNext,
              onBackAction: _navigateBack,
            ),
            BottomNavigation(
              isProfileEditing: widget.isProfileEditing,
              isSaving: _isSaving,
              actionName: 'Add Your Bio',
              onTapAction: _navigateNext,
              onBackAction: _navigateBack,
            ),
            BottomNavigationWithSkip(
              isSaving: _isSaving,
              actionName: 'Add Experience',
              onTapAction: () {
                _navigateNext();
                _dismissKeyboard();
              },
              onBackAction: _navigateBack,
              onSkip: _skipNext,
              isProfileEditing: widget.isProfileEditing,
            ),
            BottomNavigationWithSkip(
              isSaving: _isSaving,
              actionName: 'Add Education',
              onTapAction: _navigateNext,
              onBackAction: _navigateBack,
              onSkip: _skipNext,
              isProfileEditing: widget.isProfileEditing,
            ),
            BottomNavigation(
              isProfileEditing: widget.isProfileEditing,
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