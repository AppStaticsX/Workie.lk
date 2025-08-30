import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workie/models/work_experience_model.dart';

class WorkExperienceBottomsheet extends StatefulWidget {
  final VoidCallback closeBottomSheet;
  final Function(WorkExperienceModel) onSave;
  final WorkExperienceModel? initialData;

  const WorkExperienceBottomsheet({
    super.key,
    required this.closeBottomSheet,
    required this.onSave,
    this.initialData,
  });

  @override
  State<WorkExperienceBottomsheet> createState() => _WorkExperienceBottomsheetState();
}

class _WorkExperienceBottomsheetState extends State<WorkExperienceBottomsheet> {
  String endYear = 'Year';
  String startYear = 'Year';
  String endMonth = 'Month';
  String startMonth = 'Month';

  bool _isTitleEmpty = false;
  bool _isCompanyEmpty = false;
  bool _isLocationEmpty = false;
  bool _isStartDateEmpty = false;
  bool _isEndDateEmpty = false;
  bool _isDateRangeInvalid = false;
  bool _hasErrors = false;
  bool _isChecked = false;

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

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _populateFields(WorkExperienceModel experience) {
    titleController.text = experience.title;
    companyController.text = experience.company;
    locationController.text = experience.location;
    startMonth = experience.startMonth;
    startYear = experience.startYear;
    _isChecked = experience.isCurrentWork;

    if (!experience.isCurrentWork && experience.endMonth != null && experience.endYear != null) {
      endMonth = experience.endMonth!;
      endYear = experience.endYear!;
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

  void _toggleCheck() {
    setState(() {
      _isChecked = !_isChecked;
      if (_isChecked) {
        _isEndDateEmpty = false;
        _isDateRangeInvalid = false;
        endMonth = 'Month';
        endYear = 'Year';
      }
    });
  }

  void _validateInput() {
    setState(() {
      _isTitleEmpty = titleController.text.isEmpty;
      _isCompanyEmpty = companyController.text.isEmpty;
      _isLocationEmpty = locationController.text.isEmpty;
      _isStartDateEmpty = startMonth == 'Month' || startYear == 'Year';
      _isEndDateEmpty = !_isChecked && (endMonth == 'Month' || endYear == 'Year');
      _isDateRangeInvalid = false;

      if (!_isStartDateEmpty && !_isEndDateEmpty && !_isChecked) {
        _isDateRangeInvalid = _isEndDateBeforeStartDate();
      }

      _hasErrors = _isTitleEmpty || _isCompanyEmpty || _isLocationEmpty ||
          _isStartDateEmpty || _isEndDateEmpty || _isDateRangeInvalid;
    });

    if (_isTitleEmpty && titleController.text.isNotEmpty) {
      setState(() => _isTitleEmpty = false);
    }
    if (_isCompanyEmpty && companyController.text.isNotEmpty) {
      setState(() => _isCompanyEmpty = false);
    }
    if (_isLocationEmpty && locationController.text.isNotEmpty) {
      setState(() => _isLocationEmpty = false);
    }
  }

  bool _isEndDateBeforeStartDate() {
    if (startMonth == 'Month' || startYear == 'Year' ||
        endMonth == 'Month' || endYear == 'Year') {
      return false;
    }

    List<String> monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    int startMonthIndex = monthNames.indexOf(startMonth) + 1;
    int startYearInt = int.parse(startYear);
    int endMonthIndex = monthNames.indexOf(endMonth) + 1;
    int endYearInt = int.parse(endYear);

    DateTime startDate = DateTime(startYearInt, startMonthIndex);
    DateTime endDate = DateTime(endYearInt, endMonthIndex);

    return endDate.isBefore(startDate);
  }

  void _handleSave() {
    _validateInput();

    if (!_hasErrors) {
      final workExperience = WorkExperienceModel(
        title: titleController.text,
        company: companyController.text,
        location: locationController.text,
        startMonth: startMonth,
        startYear: startYear,
        endMonth: _isChecked ? null : endMonth,
        endYear: _isChecked ? null : endYear,
        isCurrentWork: _isChecked,
      );

      widget.onSave(workExperience);
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
              'Add Your Work Experience',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold
              )
          ),
          IconButton(
              onPressed: () {
                _dismissKeyboard();
                widget.closeBottomSheet();
              },
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
                  const SizedBox(height: 20),
                  _buildCurrentWorkCheckbox(),
                  const SizedBox(height: 30),
                  _buildStartDateSection(),
                  const SizedBox(height: 20),
                  if (!_isChecked) _buildEndDateSection(),
                  if (!_isChecked) const SizedBox(height: 36),
                  if (_isChecked) const SizedBox(height: 16),
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
          'Your Job Title *',
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
            hintText: 'Ex: Mason skilled in house foundation work',
            hintStyle: TextStyle(
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
        if (_isTitleEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Job title is required',
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
          'Where You Worked *',
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
            hintText: 'Ex: Organization or Company',
            hintStyle: TextStyle(
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
        if (_isCompanyEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Workplace is required',
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
          'Workplace Location *',
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
            hintText: 'Ex: Colombo, Galle, Kandy',
            hintStyle: TextStyle(
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
        if (_isLocationEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Workplace location is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentWorkCheckbox() {
    return Row(
      children: [
        _buildCustomCheckbox(),
        const SizedBox(width: 12),
        Text(
          'I am currently working in here.',
          style: Theme.of(context).textTheme.bodyLarge,
        )
      ],
    );
  }

  Widget _buildCustomCheckbox() {
    return InkWell(
      onTap: _toggleCheck,
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              width: _isChecked? 1.5 : 2,
              color: _isChecked? Theme.of(context).primaryColor : Colors.grey
          ),
          color: _isChecked ? Theme.of(context).primaryColor : Colors.transparent,
        ),
        child: _isChecked
            ? const Icon(Icons.check, size: 16, color: Colors.white,)
            : null,
      ),
    );
  }

  Widget _buildStartDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work Started *',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: _buildMonthPicker(
                  selectedMonth: startMonth,
                  isError: _isStartDateEmpty || _isDateRangeInvalid,
                  onMonthSelected: (month) {
                    setState(() {
                      startMonth = month;
                      _isStartDateEmpty = false;
                      _isDateRangeInvalid = false;
                    });
                  }
              ),
            ),
            const SizedBox(width: 24),
            Flexible(
              flex: 1,
              child: _buildYearPicker(
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
            )
          ],
        ),
        if (_isStartDateEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Start date is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        if (_isDateRangeInvalid)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Start date cannot be after end date',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEndDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work Ended *',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: _buildMonthPicker(
                  selectedMonth: endMonth,
                  isError: _isEndDateEmpty || _isDateRangeInvalid,
                  onMonthSelected: (month) {
                    setState(() {
                      endMonth = month;
                      _isEndDateEmpty = false;
                      _isDateRangeInvalid = false;
                    });
                  }
              ),
            ),
            const SizedBox(width: 24),
            Flexible(
              flex: 1,
              child: _buildYearPicker(
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
            )
          ],
        ),
        if (_isEndDateEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'End date is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        if (_isDateRangeInvalid)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'End date cannot be before start date',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMonthPicker({
    required String selectedMonth,
    required Function(String) onMonthSelected,
    bool isError = false
  }) {
    return InkWell(
      onTap: (){
        _showMonthPicker(onMonthSelected);
        _dismissKeyboard();

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedMonth,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: selectedMonth == 'Month'
                      ? Theme.of(context).hintColor
                      : null
              ),
            ),
          ],
        ),
      ),
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
        _dismissKeyboard();
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedYear,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: selectedYear == 'Year'
                      ? Theme.of(context).hintColor
                      : null
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(Function(String) onMonthSelected) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> monthNames = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];

        int selectedMonthIndex = DateTime.now().month - 1;

        return CupertinoAlertDialog(
          title: const Text('Select Month'),
          content: SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 32.0,
              scrollController: FixedExtentScrollController(
                initialItem: selectedMonthIndex,
              ),
              onSelectedItemChanged: (int index) {
                selectedMonthIndex = index;
              },
              children: List.generate(12, (index) {
                return Center(
                  child: Text(
                    monthNames[index],
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
                onMonthSelected(monthNames[selectedMonthIndex]);
              },
            ),
          ],
        );
      },
    );
  }

  void _showYearPicker(Function(String) onYearSelected) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final currentYear = DateTime.now().year;
        int selectedYear = currentYear; // Initialize with current year
        final startYear = currentYear - 50;
        final endYear = currentYear + 5; // Extended range to include future years
        final totalYears = endYear - startYear + 1;
        final initialIndex = 50; // Current year is at index 50

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
                selectedYear = startYear + index;
              },
              children: List.generate(totalYears, (index) {
                int year = startYear + index;
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
              _dismissKeyboard();
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
          onPressed: () {
            _handleSave();
            _dismissKeyboard();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E6BF5),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
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