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
  bool _isNicSelected = false;

  void _onPortraitSelectionChanged(bool isSelected) {
    setState(() {
      _isPortraitSelected = isSelected;
    });
  }

  void _onNicSelectionChanged(bool isSelected) {
    setState(() {
      _isNicSelected = isSelected;
    });
  }

  void _handleNextStep() {
    // Check validation based on current step
    if (_selectedIndex == 0 && !_isPortraitSelected) {
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

    if (_selectedIndex == 1 && !_isNicSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please upload both front and back images of your NIC/Driver License before proceeding.',
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
          NICVerification(
            onSelectionChanged: _onNicSelectionChanged,
          ),
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
            onTapAction: _handleNextStep, // Use the same validation method
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
        ],
      ),
    );
  }
}