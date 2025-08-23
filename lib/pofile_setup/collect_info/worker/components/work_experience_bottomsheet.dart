import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workie/widgets/simple_textfeild.dart';

class WorkExperienceBottomsheet extends StatefulWidget {
  final VoidCallback closeBottomSheet;

  const WorkExperienceBottomsheet({
    super.key,
    required this.closeBottomSheet
  });

  @override
  State<WorkExperienceBottomsheet> createState() => _WorkExperienceBottomsheetState();
}

class _WorkExperienceBottomsheetState extends State<WorkExperienceBottomsheet> {

  String endYear = 'Year';
  String startYear = 'Year';
  String endMonth = 'Month';
  String startMonth = 'Month';

  bool _isChecked = false;
  final TextEditingController titleController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void _toggleCheck() {
    setState(() {
      _isChecked = !_isChecked;
    });
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
              'Add Work Experience',
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(),
            const SizedBox(height: 30),
            _buildCompanyField(),
            const SizedBox(height: 30),
            _buildLocationField(),
            const SizedBox(height: 20),
            _buildCurrentWorkCheckbox(),
            const SizedBox(height: 30),
            _buildStartDateSection(),
            const SizedBox(height: 20),
            _buildEndDateSection(),
            const SizedBox(height: 36),
            _buildBottomActionButtons(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title *',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        const SizedBox(height: 4),
        SimpleTextfield(
            controller: titleController,
            hintText: 'Ex: Carpenter specialize in Cupboard Making',
            obscureText: false,
            paddingHorizontal: 0,
            maxLines: 1,
            focusBorderColor: Theme.of(context).colorScheme.inverseSurface
        ),
      ],
    );
  }

  Widget _buildCompanyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company *',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        const SizedBox(height: 4),
        SimpleTextfield(
            controller: titleController,
            hintText: 'Ex: WooddieCraft Pvt. LTD',
            obscureText: false,
            paddingHorizontal: 0,
            maxLines: 1,
            focusBorderColor: Theme.of(context).colorScheme.inverseSurface
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        const SizedBox(height: 4),
        SimpleTextfield(
            controller: titleController,
            hintText: 'Ex: Ambalangoda',
            obscureText: false,
            paddingHorizontal: 0,
            maxLines: 1,
            focusBorderColor: Theme.of(context).colorScheme.inverseSurface
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
          'I am currently working on this role',
          style: Theme.of(context).textTheme.bodyLarge,
        )
      ],
    );
  }

  Widget _buildCustomCheckbox() {
    return InkWell(
      onTap: (){
        _toggleCheck();
      },
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                width: _isChecked? 1.5 : 2,
                color: _isChecked? Colors.grey : Colors.white
            )
        ),
        child: !_isChecked
            ? Icon(Icons.check, size: 16, color: Colors.white,)
            : null,
      ),
    );
  }

  Widget _buildStartDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Date *',
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
                  onMonthSelected: (month) {
                    setState(() {
                      startMonth = month;
                    });
                  }
              ),
            ),
            const SizedBox(width: 24),
            Flexible(
              flex: 1,
              child: _buildYearPicker(
                  selectedYear: startYear,
                  onYearSelected: (year) {
                    setState(() {
                      startYear = year;
                    });
                  }
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildEndDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'End Date *',
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
                  onMonthSelected: (month) {
                    setState(() {
                      endMonth = month;
                    });
                  }
              ),
            ),
            const SizedBox(width: 24),
            Flexible(
              flex: 1,
              child: _buildYearPicker(
                  selectedYear: endYear,
                  onYearSelected: (year) {
                    setState(() {
                      endYear = year;
                    });
                  }
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildMonthPicker({
    required String selectedMonth,
    required Function(String) onMonthSelected
  }) {
    return InkWell(
      onTap: (){
        _showMonthPicker(onMonthSelected);
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                width: 1.5,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedMonth,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.normal
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearPicker({
    required String selectedYear,
    required Function(String) onYearSelected
  }) {
    return InkWell(
      onTap: () {
        _showYearPicker(onYearSelected);
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                width: 1.5,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedYear,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.normal
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
          title: Text('Select Month'),
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
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Select'),
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
        int selectedYear = DateTime.now().year;
        return CupertinoAlertDialog(
          title: Text('Select Year'),
          content: SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 32.0,
              onSelectedItemChanged: (int index) {
                selectedYear = DateTime.now().year - 50 + index;
              },
              children: List.generate(100, (index) {
                int year = DateTime.now().year - 50 + index;
                return Center(
                  child: Text(
                    year.toString(),
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Select'),
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
          onPressed: (){},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E6BF5),
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            shape: RoundedRectangleBorder(
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