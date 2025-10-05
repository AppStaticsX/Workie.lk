import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/screens/googlemap_screen.dart';

class ClientPostScreen extends StatefulWidget {
  const ClientPostScreen({super.key});

  @override
  State<ClientPostScreen> createState() => _ClientPostScreenState();
}

class _ClientPostScreenState extends State<ClientPostScreen> {

  bool _isPosting = false;
  bool _isJobTitleEmpty = false;
  bool _isJobCategoryEmpty = false;
  bool _isJobDescriptionEmpty = false;
  bool _isLocationEmpty = false;
  bool _isContactEmpty = false;
  bool _isWorkersNeededEmpty = false;
  bool _isBudgetEmpty = false;
  bool _isPaymentTypeEmpty = false;

  // Controllers
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _estimatedDaysController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _workersNeededController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _materialsNotesController = TextEditingController();

  // Focus Nodes
  final FocusNode _jobTitleFocusNode = FocusNode();

  // Dropdown values
  String? _selectedJobCategory;
  String? _selectedPaymentType;
  String? _selectedJobUrgency;
  bool _materialsProvided = false;
  bool _useEndDate = true; // true for end date, false for estimated days

  final List<String> _jobCategories = [
    'Masonry',
    'Carpentry',
    'Welding & Metal Fabrication',
    'Painting & Finishing',
    'Tile & Flooring',
    'Plumbing',
  ];

  final List<String> _paymentTypes = [
    'Per Day',
    'Per Hour',
  ];

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _selectLocationOnMap() {
    Navigator.push(
        context, MaterialPageRoute(
          builder: (context) => GoogleMapScreen(onPressed: (){},)
      )
    );
  }

  void _saveAsDraft() {
    // Implement save as draft functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job saved as draft')),
    );
  }

  void _clearForm() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Form'),
        content: const Text('Are you sure you want to clear all form data?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              _resetForm();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      // Clear all controllers
      _jobTitleController.clear();
      _jobDescriptionController.clear();
      _locationController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _estimatedDaysController.clear();
      _budgetController.clear();
      _workersNeededController.clear();
      _clientNameController.clear();
      _phoneController.clear();
      _whatsappController.clear();
      _emailController.clear();
      _materialsNotesController.clear();

      // Reset dropdown values
      _selectedJobCategory = null;
      _selectedPaymentType = null;
      _selectedJobUrgency = null;

      // Reset boolean values
      _materialsProvided = false;
      _useEndDate = true;

      // Reset error states
      _isJobTitleEmpty = false;
      _isJobCategoryEmpty = false;
      _isJobDescriptionEmpty = false;
      _isLocationEmpty = false;
      _isContactEmpty = false;
      _isWorkersNeededEmpty = false;
      _isBudgetEmpty = false;
      _isPaymentTypeEmpty = false;
    });
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      _isJobTitleEmpty = _jobTitleController.text.trim().isEmpty;
      _isJobCategoryEmpty = _selectedJobCategory == null;
      _isJobDescriptionEmpty = _jobDescriptionController.text.trim().isEmpty;
      _isLocationEmpty = _locationController.text.trim().isEmpty;
      _isWorkersNeededEmpty = _workersNeededController.text.trim().isEmpty;
      _isContactEmpty = _clientNameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty;
      _isBudgetEmpty = _budgetController.text.trim().isEmpty;
      _isPaymentTypeEmpty = _selectedPaymentType == null;
    });

    if (_isJobTitleEmpty || _isJobCategoryEmpty || _isJobDescriptionEmpty ||
        _isLocationEmpty || _isWorkersNeededEmpty || _isContactEmpty || _isBudgetEmpty || _isPaymentTypeEmpty) {
      isValid = false;
    }

    return isValid;
  }

  void _submitJobPost() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Create job post data
      final jobPostData = {
        'jobTitle': _jobTitleController.text.trim(),
        'jobCategory': _selectedJobCategory,
        'jobDescription': _jobDescriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'startDate': _startDateController.text,
        'endDate': _useEndDate ? _endDateController.text : null,
        'estimatedDays': !_useEndDate ? _estimatedDaysController.text : null,
        'paymentType': _selectedPaymentType,
        'budget': _budgetController.text.trim(),
        'workersNeeded': _workersNeededController.text.trim(),
        'clientName': _clientNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'whatsappNumber': _whatsappController.text.trim(),
        'email': _emailController.text.trim(),
        'materialsProvided': _materialsProvided,
        'materialsNotes': _materialsNotesController.text.trim(),
        'jobUrgency': _selectedJobUrgency,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back or to job list
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _estimatedDaysController.dispose();
    _budgetController.dispose();
    _workersNeededController.dispose();
    _clientNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _materialsNotesController.dispose();

    // Dispose focus nodes
    _jobTitleFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        surfaceTintColor: const Color(0xFF4E6BF5),
        backgroundColor: const Color(0xFF4E6BF5),
        elevation: 0,
        leading: const Icon(
          Iconsax.card_edit_copy,
          color: Colors.white,
          size: 28,
        ),
        title: const Text(
          'New Job Post',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4, top: 0, bottom: 0),
            child: IconButton(
              onPressed: _saveAsDraft,
              icon: const Icon(
                Iconsax.direct_inbox_copy,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12, top: 0, bottom: 0),
            child: IconButton(
              onPressed: _clearForm,
              icon: const Icon(
                Iconsax.trash_copy,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildJobTitleSection(),
            const SizedBox(height: 12),
            _buildJobCategorySection(),
            const SizedBox(height: 12),
            _buildJobDescriptionSection(),
            const SizedBox(height: 12),
            _buildLocationSection(),
            const SizedBox(height: 12),
            _buildTimelineSection(),
            const SizedBox(height: 12),
            _buildPaymentSection(),
            const SizedBox(height: 12),
            //_buildWorkersNeededSection(),
            const SizedBox(height: 12),
            _buildContactSection(),
            const SizedBox(height: 12),
            _buildMaterialsSection(),
            const SizedBox(height: 12),
            _buildUrgencySection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Job Title*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isJobTitleEmpty)
              const Text(
                '  (Required)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _jobTitleController,
          focusNode: _jobTitleFocusNode,
          onChanged: (value) {
            if (_isJobTitleEmpty && value.isNotEmpty) {
              setState(() => _isJobTitleEmpty = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'E.g. Masonry Work – Boundary Wall Construction',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isJobTitleEmpty ? Colors.red : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isJobTitleEmpty ? Colors.red : const Color(0xFF4E6BF5),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Job Category / Trade*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isJobCategoryEmpty)
              const Text(
                '  (Required)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedJobCategory,
          decoration: InputDecoration(
            hintText: 'Select job category',
            hintStyle: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.grey
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isJobCategoryEmpty ? Colors.red : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isJobTitleEmpty ? Colors.red : const Color(0xFF4E6BF5),
                width: 1.5,
              ),
            ),
          ),
          items: _jobCategories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedJobCategory = value;
              if (_isJobCategoryEmpty && value != null) {
                _isJobCategoryEmpty = false;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildJobDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Job Description / Details*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isJobDescriptionEmpty)
              const Text(
                '  (Required)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _jobDescriptionController,
          maxLines: 2,
          onChanged: (value) {
            if (_isJobDescriptionEmpty && value.isNotEmpty) {
              setState(() => _isJobDescriptionEmpty = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'E.g. Need 2 skilled masons to build a 15ft boundary wall. Cement & sand provided. Work should be completed within 5 days.',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isJobDescriptionEmpty ? Colors.red : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isJobDescriptionEmpty ? Colors.red : const Color(0xFF4E6BF5),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Location*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isLocationEmpty)
              const Text(
                '  (Required)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _locationController,
                onChanged: (value) {
                  if (_isLocationEmpty && value.isNotEmpty) {
                    setState(() => _isLocationEmpty = false);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'E.g. Colombo, Western Province or specific address',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.tertiary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _isLocationEmpty ? Colors.red : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _isLocationEmpty ? Colors.red : const Color(0xFF4E6BF5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: _selectLocationOnMap,
                icon: SvgPicture.asset('assets/icon/google-maps-svgrepo-com.svg',width: 54,)
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work Duration / Timeline (Estimated)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startDateController,
                readOnly: true,
                onTap: () => _selectDate(context, _startDateController),
                decoration: InputDecoration(
                  hintText: 'Start Date',
                  hintStyle: TextStyle(
                      color: Colors.grey
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.tertiary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: const Icon(Iconsax.calendar_copy),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: const Color(0xFF4E6BF5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: TextFormField(
                controller: _endDateController,
                readOnly: true,
                onTap: () => _selectDate(context, _endDateController),
                decoration: InputDecoration(
                  hintText: 'End Date',
                  hintStyle: TextStyle(
                      color: Colors.grey
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.tertiary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: const Icon(Iconsax.calendar_copy),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: const Color(0xFF4E6BF5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Payment Details*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isBudgetEmpty)
              const Text(
                '  (Required)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedPaymentType,
                decoration: InputDecoration(
                  hintText: 'Payment Type',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.tertiary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _isPaymentTypeEmpty? Colors.red : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _isPaymentTypeEmpty? Colors.red : const Color(0xFF4E6BF5),
                      width: 1.5,
                    ),
                  ),
                ),
                items: _paymentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentType = value;
                    if (_isPaymentTypeEmpty && value != null) {
                      _isPaymentTypeEmpty = false;
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: _budgetController,
                onChanged: (value) {
                  if (_isBudgetEmpty && value.isNotEmpty) {
                    setState(() => _isBudgetEmpty = false);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Rs: 3500',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.tertiary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _isBudgetEmpty ? Colors.red : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _isBudgetEmpty ? Colors.red : const Color(0xFF4E6BF5),
                      width: 1.5,
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

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Contact Information*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_isContactEmpty)
              const Text(
                '  (Name & Phone Required)',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _clientNameController,
          decoration: InputDecoration(
            hintText: 'Your Name',
            hintStyle: TextStyle(
                color: Colors.grey
            ),
            prefixIcon: Icon(Iconsax.user_copy),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFF4E6BF5),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Phone Number',
            hintStyle: TextStyle(
                color: Colors.grey
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(Iconsax.mobile_copy),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFF4E6BF5),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _whatsappController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'WhatsApp Number (Optional)',
            hintStyle: TextStyle(
                color: Colors.grey
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                'assets/icon/whatsapp-icon-logo-svgrepo-com.svg',
                width: 12,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFF4E6BF5),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Email (Optional)',
            hintStyle: TextStyle(
                color: Colors.grey
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                'assets/icon/google-gmail-svgrepo-com.svg',
                width: 12,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFF4E6BF5),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Materials Provided?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SwitchListTile(
          title: const Text('Materials Provided by Client'),
          subtitle: Text(_materialsProvided ? 'Yes, Material Provided' : 'No, Material Provided'),
          value: _materialsProvided,
          activeTrackColor: const Color(0xFF4E6BF5),
          activeColor: Colors.white,
          onChanged: (value) {
            setState(() => _materialsProvided = value);
          },
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
        if (_materialsProvided) ...[
          TextFormField(
            controller: _materialsNotesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'E.g. Cement & bricks provided. Worker to bring tools.',
              hintStyle: TextStyle(
                color: Colors.grey
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.tertiary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: const Color(0xFF4E6BF5),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUrgencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Application Closing Date*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _endDateController,
          readOnly: true,
          onTap: () => _selectDate(context, _endDateController),
          decoration: InputDecoration(
            hintText: 'Application Closing Date',
            hintStyle: TextStyle(
                color: Colors.grey
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: const Icon(Iconsax.calendar_copy),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFF4E6BF5),
                width: 1.5,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPosting ? null : _submitJobPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4E6BF5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isPosting
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Post Job',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}