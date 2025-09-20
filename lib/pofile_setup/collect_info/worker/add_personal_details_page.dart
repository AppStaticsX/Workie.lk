import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:workie/values/color.dart';
import 'components/profile_pic_bottomsheet.dart';

class AddPersonalDetailsPage extends StatefulWidget {
  const AddPersonalDetailsPage({super.key});

  @override
  State<AddPersonalDetailsPage> createState() => AddPersonalDetailsPageState();
}

class AddPersonalDetailsPageState extends State<AddPersonalDetailsPage> {
  File? profileImage;
  Uint8List? profileImageBytes;
  double? profileImageScale;
  double? profileImageAngle;

  String? selectedProvince;

  final List<String> provinces = [
    'Western',
    'Central',
    'Southern',
    'Northern',
    'Eastern',
    'North Western',
    'North Central',
    'Uva',
    'Sabaragamuwa'
  ];

  bool _isBirthDayEmpty = false;
  bool _isStreetAddressEmpty = false;
  bool _isCityEmpty = false;
  bool _isStateOrProvinceEmpty = false;
  bool _isPostalCodeEmpty = false;
  bool _isPhoneNumberEmpty = false;
  bool _isApartmentOrSuiteEmpty = false;
  bool _isProfileImage = false;
  bool _isPhoneNumberInvalid = false;

  TextEditingController birthDayController = TextEditingController();
  TextEditingController streetAddressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateOrProvinceController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController apartmentOrSuiteController = TextEditingController();

  FocusNode birthDayFocusNode = FocusNode();
  FocusNode streetAddressFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode stateOrProvinceFocusNode = FocusNode();
  FocusNode postalCodeFocusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode apartmentOrSuiteFocusNode = FocusNode();

  bool validateInputs() {
    setState(() {
      _isBirthDayEmpty = birthDayController.text.isEmpty;
      _isStreetAddressEmpty = streetAddressController.text.isEmpty;
      _isCityEmpty = cityController.text.isEmpty;
      _isStateOrProvinceEmpty = stateOrProvinceController.text.isEmpty;
      _isPostalCodeEmpty = postalCodeController.text.isEmpty;
      _isPhoneNumberEmpty = phoneNumberController.text.isEmpty;
      _isPhoneNumberInvalid = phoneNumberController.text.isNotEmpty && phoneNumberController.text.length != 9;
      _isProfileImage = profileImage == null && profileImageBytes == null;
    });

    return !(_isBirthDayEmpty ||
        _isStreetAddressEmpty ||
        _isCityEmpty ||
        _isStateOrProvinceEmpty ||
        _isPostalCodeEmpty ||
        _isPhoneNumberEmpty ||
        _isPhoneNumberInvalid ||
        _isProfileImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildHeaderSection(context),
            const SizedBox(height: 32),
            _buildProfilePhotoSection(context),
            const SizedBox(height: 36),
            _buildBirthDateField(context),
            const SizedBox(height: 30),
            _buildStreetAddressField(context),
            const SizedBox(height: 16),
            _buildAptOrSuiteField(context),
            const SizedBox(height: 16),
            _buildCityAndStateFields(context),
            const SizedBox(height: 16),
            _buildPostalCodeField(context),
            const SizedBox(height: 30),
            _buildPhoneField(context),
            const SizedBox(height: 36),

          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Almost done! Finish a few details and publish.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Add a clear photo so clients can trust you. We need a bit of personal information to keep things safe.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            //color: Theme.of(context).colorScheme.inverseSurface,
              height: 1.3,
              color: AppColors.textSilver
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  profileImageAngle = 0;
                });
                showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: false,
                    context: context,
                    builder: (context) => ProfilePicBottomsheet(
                      closeBottomSheet: () {
                        Navigator.pop(context);
                      },
                      onImageAttached: (file, bytes, scale, angle) {
                        setState(() {
                          profileImage = file;
                          profileImageBytes = bytes;
                          profileImageScale = scale;
                          profileImageAngle = angle;
                        });
                      },
                    )
                );
              },
              child: profileImage != null || profileImageBytes != null
                  ? ClipOval(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: kIsWeb && profileImageBytes != null
                      ? ClipRect(
                        child: Transform.rotate(
                          angle: profileImageAngle! - 45,
                          child: Transform.scale(
                            scale: profileImageScale,
                            child: Image.
                            memory(
                              profileImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                      : profileImage != null
                      ? ClipRect(
                          child: Transform.rotate(
                            angle: profileImageAngle! - 45,
                            child: Transform.scale(
                              scale: profileImageScale,
                              child: Image.
                              file(
                                profileImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      )
                      : Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: !_isProfileImage
                                ? Colors.transparent
                                : Colors.red,
                            width: 2
                        )
                    ),
                    child:
                    SvgPicture
                        .asset(
                      'assets/icon/undraw_male-avatar_zkzx.svg',
                      width: 120,
                    ),
                  ),
                ),
              )
                  : Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: !_isProfileImage
                            ? Colors.transparent
                            : Colors.red,
                        width: 2
                    )
                ),
                child:
                SvgPicture
                    .asset(
                  'assets/icon/undraw_male-avatar_zkzx.svg',
                  width: 120,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            setState(() {
              profileImageAngle = 0;
            });
            showModalBottomSheet(
                isScrollControlled: true,
                isDismissible: false,
                context: context,
                builder: (context) => ProfilePicBottomsheet(
                  closeBottomSheet: () {
                    Navigator.pop(context);
                  },
                  //onSave: _addWorkExperience,
                )
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: Color(0xFF4E6BF5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.add,
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  profileImage != null || profileImageBytes != null
                      ? 'Change Photo'
                      : 'Add Photo',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inverseSurface
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBirthDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Date of Birth *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
            ),
            if (_isBirthDayEmpty)
              const Text(
                '  (Required)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          onTap: () async {
            // Unfocus the text field to prevent keyboard from showing
            FocusScope.of(context).unfocus();

            // Calculate date 18 years ago from today
            final DateTime eighteenYearsAgo = DateTime(
              DateTime.now().year - 18,
              DateTime.now().month,
              DateTime.now().day,
            );

            // Show date picker
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: eighteenYearsAgo, // Default to 18 years ago
              firstDate: DateTime(1900), // Adjust as needed
              lastDate: eighteenYearsAgo, // Must be at least 18 years old
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: Theme.of(context).colorScheme.primary,
                      onPrimary: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            // If user picked a date, validate age and format it
            if (pickedDate != null) {
              // Double-check age validation (though date picker already limits selection)
              final age = DateTime.now().difference(pickedDate).inDays / 365.25;

              if (age >= 18) {
                final formattedDate = "${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                birthDayController.text = formattedDate;

                // Update the empty state if needed
                if (_isBirthDayEmpty) {
                  setState(() => _isBirthDayEmpty = false);
                }
              } else {
                // Show error message if somehow an invalid date was selected
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You must be at least 18 years old'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          controller: birthDayController,
          focusNode: birthDayFocusNode,
          readOnly: true, // Prevent manual typing, only allow date picker
          onChanged: (value) {
            if (_isBirthDayEmpty && value.isNotEmpty) {
              setState(() => _isBirthDayEmpty = false);
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Iconsax.calendar_1_copy),
            hintText: 'yyyy-mm-dd',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isBirthDayEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isBirthDayEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreetAddressField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Street Address *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
            ),
            if (_isStreetAddressEmpty)
              const Text(
                '  (Required)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: streetAddressController,
          focusNode: streetAddressFocusNode,
          onChanged: (value) {
            if (_isStreetAddressEmpty && value.isNotEmpty) {
              setState(() => _isStreetAddressEmpty = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'Ex: New York', // Also fix the hint text
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isStreetAddressEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isStreetAddressEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAptOrSuiteField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Apartment / Suite',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
            ),
            if (_isApartmentOrSuiteEmpty || !_isApartmentOrSuiteEmpty)
              Text(
                '  (Optional)',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.inverseSurface),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: apartmentOrSuiteController,
          focusNode: apartmentOrSuiteFocusNode,
          onChanged: (value) {
            if (_isApartmentOrSuiteEmpty && value.isNotEmpty) {
              setState(() => _isApartmentOrSuiteEmpty = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'Ex: New York', // Also fix the hint text
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isApartmentOrSuiteEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isApartmentOrSuiteEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityAndStateFields(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Row(
                children: [
                  const Text(
                    'City / Town *',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
                  ),
                  if (_isCityEmpty)
                    const Text(
                      '  (Required)',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Flexible(
              flex: 1,
              child: Row(
                children: [
                  const Text(
                    'Province *',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
                  ),
                  if (_isStateOrProvinceEmpty)
                    const Text(
                      '  (Required)',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: cityController,
                focusNode: cityFocusNode,
                onChanged: (value) {
                  if (_isCityEmpty && value.isNotEmpty) {
                    setState(() => _isCityEmpty = false);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Ex: New York', // Also fix the hint text
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.tertiary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isCityEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isCityEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24), // Add spacing between fields
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedProvince,
                decoration: InputDecoration(
                  hintText: 'Select Province',
                  hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.tertiary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isStateOrProvinceEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isStateOrProvinceEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                      width: 2,
                    ),
                  ),
                ),
                items: provinces.map((String province) {
                  return DropdownMenuItem<String>(
                    value: province,
                    child: Text(
                        province, style: TextStyle(fontWeight: FontWeight.normal)
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProvince = newValue;
                    stateOrProvinceController.text = newValue ?? '';
                    if (_isStateOrProvinceEmpty && newValue != null) {
                      _isStateOrProvinceEmpty = false;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostalCodeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'ZIP / Postal Code *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
            ),
            if (_isPostalCodeEmpty)
              const Text(
                '  (Required)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Pinput(
          controller: postalCodeController,
          focusNode: postalCodeFocusNode,
          length: 5, // Adjust based on your postal code length requirements
          onChanged: (value) {
            if (_isPostalCodeEmpty && value.isNotEmpty) {
              setState(() => _isPostalCodeEmpty = false);
            }
          },
          defaultPinTheme: PinTheme(
            width: 44,
            height: 44,
            textStyle: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isPostalCodeEmpty
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 44,
            height: 44,
            textStyle: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isPostalCodeEmpty
                    ? Colors.red
                    : Theme.of(context).colorScheme.inverseSurface,
                width: 2,
              ),
            ),
          ),
          errorPinTheme: PinTheme(
            width: 44,
            height: 44,
            textStyle: const TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red,
                width: 1.5,
              ),
            ),
          ),
          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
          showCursor: true,
          cursor: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 9),
                width: 22,
                height: 1,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Mobile Number *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
            ),
            if (_isPhoneNumberEmpty)
              const Text(
                '  (Required)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            if (_isPhoneNumberInvalid)
              const Text(
                '  (Must be 9 digits)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              height: 48,
              width: 54,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: SvgPicture.asset(
                  'assets/icon/android_compatible_flag.svg',
                  height: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: TextFormField(
                controller: phoneNumberController,
                focusNode: phoneNumberFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                onChanged: (value) {
                  setState(() {
                    if (_isPhoneNumberEmpty && value.isNotEmpty) {
                      _isPhoneNumberEmpty = false;
                    }
                    _isPhoneNumberInvalid = value.isNotEmpty && value.length != 9;
                  });
                },
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: '712211251',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixText: '+94 ',
                  prefixStyle: TextStyle(color: Theme.of(context).colorScheme.inverseSurface, fontSize: 16),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.tertiary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: (_isPhoneNumberEmpty || _isPhoneNumberInvalid)
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: (_isPhoneNumberEmpty || _isPhoneNumberInvalid)
                          ? Colors.red
                          : Theme.of(context).colorScheme.inverseSurface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}