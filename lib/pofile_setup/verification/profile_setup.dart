import 'package:flutter/material.dart';
import 'package:workie/pofile_setup/bottom_navigation.dart';
import 'package:workie/pofile_setup/verification/worker/nic_verification.dart';
import 'package:workie/pofile_setup/verification/worker/portrait_verification.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  int _selectedIndex = 0;

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
          const PortraitVerification(),
          const NICVerification()
        ],
      ),
      bottomNavigationBar: IndexedStack(
        index: _selectedIndex,
        children: [
          BottomNavigation(
            actionName: 'Next Step',
            onTapAction: () {
              setState(() {
                _selectedIndex = _selectedIndex + 1;
              });
            },
            onBackAction: () {
              setState(() {
                return;
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
