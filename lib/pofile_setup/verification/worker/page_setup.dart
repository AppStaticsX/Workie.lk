import 'package:flutter/material.dart';
import 'package:workie/screens/main_screen.dart';
import 'package:workie/widgets/bottom_navigation.dart';
import 'package:workie/pofile_setup/verification/worker/mobile_verification.dart';
import 'package:workie/pofile_setup/verification/worker/nic_verification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../../../services/push_data/nic_verification_service.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  int _selectedIndex = 0;
  bool _isNicSelected = false;
  bool _isSaving = false;
  bool _isMobileVerified = false;

  // Store uploaded images
  File? _frontImage;
  File? _backImage;
  String? _frontImageUrl;
  String? _backImageUrl;

  final int _maxIndex = 2;

  void _onNicSelectionChanged(bool isSelected, {File? frontImage, File? backImage}) {
    setState(() {
      _isNicSelected = isSelected;
      _frontImage = frontImage;
      _backImage = backImage;
    });
  }

  Future<void> _handleNextStep() async {
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

    // If on NIC verification step and images are selected, upload them
    if (_selectedIndex == 0 && _isNicSelected && _frontImage != null && _backImage != null) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Get auth token
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        if (token == null) {
          throw Exception('Authentication token not found. Please login again.');
        }

        // Upload NIC documents
        final result = await NicVerificationService.uploadNicDocuments(
          frontImage: _frontImage!,
          backImage: _backImage!,
          token: token,
        );

        if (result['success'] == true) {
          // Store uploaded URLs for later use
          _frontImageUrl = result['data']?['files']?['idPhotoFront']?['url'];
          _backImageUrl = result['data']?['files']?['idPhotoBack']?['url'];

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'NIC documents uploaded successfully!',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Proceed to next step
          setState(() {
            _selectedIndex = _selectedIndex + 1;
          });
        } else {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'Failed to upload NIC documents. Please try again.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface
                  ),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error uploading documents: ${e.toString()}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface
                ),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    } else {
      // For other steps, just proceed normally
      setState(() {
        _selectedIndex = _selectedIndex + 1;
      });
    }
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
          MobileVerification(
            onVerificationComplete: (isVerified) {
              setState(() {
                _isMobileVerified = isVerified;
              });
            },
          )
        ],
      ),
      bottomNavigationBar: IndexedStack(
        index: _selectedIndex,
        children: [
          BottomNavigation(
            isProfileEditing: true,
            isSaving: _isSaving,
            actionName: _isSaving ? 'Uploading...' : 'Next Step',
            onTapAction: _handleNextStep,
            onBackAction: () {},
          ),
          BottomNavigation(
            isProfileEditing: false,
            isSaving: _isSaving,
            actionName: _isSaving ? 'Verifying...' : 'Complete Verification',
            onTapAction: () {
              if (!_isMobileVerified) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please verify your mobile number before continuing.',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                );
                return;
              }

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainScreen()
                  )
              );
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