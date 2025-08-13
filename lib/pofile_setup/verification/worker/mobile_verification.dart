import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/widgets/simple_prefixtextfield.dart';

import '../../collect_info/profile_setup.dart';

class MobileVerification extends StatefulWidget {
  const MobileVerification({super.key});

  @override
  State<MobileVerification> createState() => _MobileVerificationState();
}

class _MobileVerificationState extends State<MobileVerification> {
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed progress bar at the top
        LinearProgressIndicator(
          value: 3 / 3,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4E6BF5)),
        ),
        // Scrollable content below
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 44),
                Text(
                  textAlign: TextAlign.center,
                  'Verify Your\nMobile Number',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    Icon(
                      Iconsax.mobile_copy,
                      size: 150,
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SimplePrefixTextfield(
                        controller: _mobileNumberController,
                        lableText: 'Mobile Number',
                        prefixIconData: Icon(Iconsax.call_copy),
                        obscureText: false,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SimplePrefixTextfield(
                              controller: _verificationCodeController,
                              hintText: 'Verification Code',
                              obscureText: false,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () {
                                // Handle send verification code
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Send Code',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (mounted) {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const ProfileSetup())
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:const Color(0xFF4E6BF5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Verify Mobile-Number',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}