import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workie/models/education_model.dart';

class EducationBottomsheet extends StatefulWidget {
  final VoidCallback closeBottomSheet;
  final Function(EducationModel) onSave;
  final EducationModel? initialData;

  const EducationBottomsheet({
    super.key,
    required this.closeBottomSheet,
    required this.onSave,
    this.initialData,
  });

  @override
  State<EducationBottomsheet> createState() => _EducationBottomsheetState();
}

class _EducationBottomsheetState extends State<EducationBottomsheet> {
  String endYear = 'Year';
  String startYear = 'Year';

  bool _isTitleEmpty = false;
  bool _isCompanyEmpty = false;
  bool _isLocationEmpty = false;
  bool _isStartDateEmpty = false;
  bool _isEndDateEmpty = false;
  bool _isDateRangeInvalid = false;
  bool _hasErrors = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final FocusNode titleFocusNode = FocusNode();
  final FocusNode companyFocusNode = FocusNode();
  final FocusNode locationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _populateFields(widget.initialData!);
    }
  }

  void _populateFields(EducationModel education) {
    titleController.text = education.title;
    companyController.text = education.company;
    locationController.text = education.location;
    startYear = education.startYear;

    if (education.endYear != null) {
      endYear = education.endYear!;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    locationController.dispose();
    titleFocusNode.dispose();
    companyFocusNode.dispose();
    locationFocusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isTitleEmpty = titleController.text.isEmpty;
      _isCompanyEmpty = companyController.text.isEmpty;
      _isLocationEmpty = locationController.text.isEmpty;
      _isStartDateEmpty = startYear == 'Year';
      _isEndDateEmpty = endYear == 'Year';
      _isDateRangeInvalid = false;

      if (!_isStartDateEmpty && !_isEndDateEmpty) {
        _isDateRangeInvalid = _isEndDateBeforeStartDate();
      }

      _hasErrors = _isTitleEmpty || _isCompanyEmpty || _isLocationEmpty ||
          _isStartDateEmpty || _isEndDateEmpty || _isDateRangeInvalid;
    });
  }

  bool _isEndDateBeforeStartDate() {
    if (startYear == 'Year' || endYear == 'Year') {
      return false;
    }

    int startYearInt = int.parse(startYear);
    int endYearInt = int.parse(endYear);

    return endYearInt < startYearInt;
  }

  void _handleSave() {
    _validateInput();

    if (!_hasErrors) {
      final education = EducationModel(
        title: titleController.text,
        company: companyController.text,
        location: locationController.text,
        startMonth: 'January', // Default month since only years are used
        startYear: startYear,
        endMonth: 'December', // Default month since only years are used
        endYear: endYear,
        isCurrentWork: false, // Education is always completed
      );

      widget.onSave(education);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12)
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildFormFields(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              'Add Education History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold
              )
          ),
          IconButton(
              onPressed: widget.closeBottomSheet,
              icon: const Icon(
                Icons.close,
                size: 28,
              )
          )
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildCompanyField(),
                  const SizedBox(height: 16),
                  _buildLocationField(),
                  const SizedBox(height: 24),
                  _buildDateSection(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
          Column(
            children: [
              _buildBottomActionButtons(),
              const SizedBox(height: 24)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School / Institute *',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: titleController,
          focusNode: titleFocusNode,
          onChanged: (value) {
            if (_isTitleEmpty && value.isNotEmpty) {
              setState(() => _isTitleEmpty = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'Ex: Vocational Training School',
            hintStyle: const TextStyle(
                color: Colors.grey
            ),
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
                color: _isTitleEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isTitleEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                width: 2,
              ),
            ),
          ),
        ),
        if (_isTitleEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'School / Institute is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompanyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diploma / Course *',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: companyController,
          focusNode: companyFocusNode,
          onChanged: (value) {
            if (_isCompanyEmpty && value.isNotEmpty) {
              setState(() => _isCompanyEmpty = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'Ex: Certificate in Carpentry',
            hintStyle: const TextStyle(
                color: Colors.grey
            ),
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
                color: _isCompanyEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isCompanyEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                width: 2,
              ),
            ),
          ),
        ),
        if (_isCompanyEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Course is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Field of Study *',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: locationController,
          focusNode: locationFocusNode,
          onChanged: (value) {
            if (_isLocationEmpty && value.isNotEmpty) {
              setState(() => _isLocationEmpty = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'Ex: Carpentry',
            hintStyle: const TextStyle(
                color: Colors.grey
            ),
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
                color: _isLocationEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isLocationEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                width: 2,
              ),
            ),
          ),
        ),
        if (_isLocationEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Field of study is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Years Attended *',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start Year',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  _buildYearPicker(
                      selectedYear: startYear,
                      isError: _isStartDateEmpty || _isDateRangeInvalid,
                      onYearSelected: (year) {
                        setState(() {
                          startYear = year;
                          _isStartDateEmpty = false;
                          _isDateRangeInvalid = false;
                        });
                      }
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'End Year',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  _buildYearPicker(
                      selectedYear: endYear,
                      isError: _isEndDateEmpty || _isDateRangeInvalid,
                      onYearSelected: (year) {
                        setState(() {
                          endYear = year;
                          _isEndDateEmpty = false;
                          _isDateRangeInvalid = false;
                        });
                      }
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (_isStartDateEmpty)
              Expanded(
                child: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Start year is required',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            if (_isEndDateEmpty)
              Expanded(
                child: const Padding(
                  padding: EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    'End year is required',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            if (_isDateRangeInvalid)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Start year cannot be after end year',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }

  Widget _buildYearPicker({
    required String selectedYear,
    required Function(String) onYearSelected,
    bool isError = false
  }) {
    return InkWell(
      onTap: () {
        _showYearPicker(onYearSelected);
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                width: 1.5,
                color: isError
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
            )
        ),
        child: Center(
          child: Text(
            selectedYear,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                color: selectedYear == 'Year'
                    ? Theme.of(context).hintColor
                    : null
            ),
          ),
        ),
      ),
    );
  }

  void _showYearPicker(Function(String) onYearSelected) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = DateTime.now().year;
        int initialIndex = 25;

        return CupertinoAlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 32.0,
              scrollController: FixedExtentScrollController(
                initialItem: initialIndex,
              ),
              onSelectedItemChanged: (int index) {
                selectedYear = DateTime.now().year - 50 + index;
              },
              children: List.generate(51, (index) {
                int year = DateTime.now().year - 50 + index;
                return Center(
                  child: Text(
                    year.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              }),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
                onYearSelected(selectedYear.toString());
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                )
            )
        ),
        const SizedBox(width: 24),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E6BF5),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          child: Text(
              'Save',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              )
          ),
        ),
      ],
    );
  }
}