import 'package:flutter/material.dart';
import 'package:workie/widgets/bottom_navigation.dart';
import 'package:workie/pofile_setup/verification/worker/mobile_verification.dart';
import 'package:workie/pofile_setup/verification/worker/nic_verification.dart';
import 'package:workie/pofile_setup/verification/worker/portrait_verification.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  int _selectedIndex = 0;
  bool _isPortraitSelected = false;

  void _onPortraitSelectionChanged(bool isSelected) {
    setState(() {
      _isPortraitSelected = isSelected;
    });
  }

  void _handleNextStep() {
    // Check if we're on the portrait verification step (index 0)
    if (_selectedIndex == 0 && !_isPortraitSelected) {
      // Show error message or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please select a portrait photo before proceeding',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inverseSurface
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      return;
    }

    // Proceed to next step if validation passes
    setState(() {
      _selectedIndex = _selectedIndex + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        surfaceTintColor: Colors.transparent,
        leading: const Icon(
          Icons.verified_user_outlined,
          size: 26,
        ),
        title: const Text(
          'Profile Verification'
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          PortraitVerification(
            onSelectionChanged: _onPortraitSelectionChanged,
          ),
          const NICVerification(),
          const MobileVerification()
        ],
      ),
      bottomNavigationBar: IndexedStack(
        index: _selectedIndex,
        children: [
          BottomNavigation(
            actionName: 'Next Step',
            onTapAction: _handleNextStep,
            onBackAction: () {
              setState(() {
                return;
              });
            },
          ),
          BottomNavigation(
            actionName: 'Next Step',
            onTapAction: () {
              setState(() {
                _selectedIndex = _selectedIndex + 1;
              });
            },
            onBackAction: () {
              setState(() {
                _selectedIndex = _selectedIndex - 1;
              });
            },
          ),
          BottomNavigation(
            actionName: 'test',
            onTapAction: () {
              setState(() {
                _selectedIndex = _selectedIndex + 1;
              });
            },
            onBackAction: () {
              setState(() {
                _selectedIndex = _selectedIndex - 1;
              });
            },
          ),
          BottomNavigation(
            actionName: 'test',
            onTapAction: () {
              setState(() {
                _selectedIndex = _selectedIndex + 1;
              });
            },
            onBackAction: () {
              setState(() {
                _selectedIndex = _selectedIndex - 1;
              });
            },
          )
        ],
      ),
    );
  }
}
