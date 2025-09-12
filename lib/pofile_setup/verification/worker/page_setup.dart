import 'package:flutter/material.dart';
import 'package:workie/widgets/bottom_navigation.dart';
import 'package:workie/pofile_setup/verification/worker/mobile_verification.dart';
import 'package:workie/pofile_setup/verification/worker/nic_verification.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  int _selectedIndex = 0;
  bool _isNicSelected = false;
  bool _isSaving = false;

  final int _maxIndex = 2;

  void _onNicSelectionChanged(bool isSelected) {
    setState(() {
      _isNicSelected = isSelected;
    });
  }

  void _handleNextStep() {
    // Check validation based on current step
    if (_selectedIndex == 0 && !_isNicSelected) {
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
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: Colors.transparent,
        leading: const Icon(
          Icons.verified_user_outlined,
          size: 26,
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
            value: (_selectedIndex+1) / (_maxIndex),
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
            isSaving: _isSaving,
            actionName: 'Next Step',
            onTapAction: _handleNextStep, // Use the same validation method
            onBackAction: () {
              setState(() {
                _selectedIndex = _selectedIndex - 1;
              });
            },
          ),
          BottomNavigation(
            isSaving: _isSaving,
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