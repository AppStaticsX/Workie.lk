import 'package:flutter/material.dart';
import '../../../services/hive_service.dart';
import '../../../widgets/expandebale_selection_widget.dart';

class SelectWorkPage extends StatefulWidget {
  final void Function(bool hasSelection)? onSelectionChanged;

  const SelectWorkPage({super.key, this.onSelectionChanged});

  @override
  State<SelectWorkPage> createState() => _SelectWorkPageState();
}

class _SelectWorkPageState extends State<SelectWorkPage> {
  // Track which category has selections and total selected count
  String? activeCategoryTitle;
  int totalSelectedCount = 0;

  // Track selections for each category
  Map<String, List<String>> categorySelections = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Load saved data from Hive when page initializes
  Future<void> _loadSavedData() async {
    try {
      final savedWorkSelection = await HiveService.getWorkSelection();
      if (savedWorkSelection != null) {
        setState(() {
          activeCategoryTitle = savedWorkSelection.categoryTitle;
          categorySelections[savedWorkSelection.categoryTitle] = savedWorkSelection.selectedOptions;
          totalSelectedCount = savedWorkSelection.selectedOptions.length;
        });

        // Notify parent about existing selection
        if (widget.onSelectionChanged != null) {
          widget.onSelectionChanged!(totalSelectedCount > 0);
        }

        print('Loaded saved work selection: ${savedWorkSelection.categoryTitle}');
        print('Loaded options: ${savedWorkSelection.selectedOptions}');
      }
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  void _onSelectionChanged(String categoryTitle, List<String> selectedOptions) {
    setState(() {
      categorySelections[categoryTitle] = selectedOptions;

      // Calculate total selections across all categories
      totalSelectedCount = categorySelections.values
          .fold(0, (sum, selections) => sum + selections.length);

      // Determine active category (the one with selections)
      activeCategoryTitle = null;
      for (var entry in categorySelections.entries) {
        if (entry.value.isNotEmpty) {
          activeCategoryTitle = entry.key;
          break;
        }
      }
    });

    // Notify parent if at least one selection exists
    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(totalSelectedCount > 0);
    }

    // Save to Hive whenever selection changes
    _saveToHive();

    print('Selected options in $categoryTitle: $selectedOptions');
    print('Total selections: $totalSelectedCount');
    print('Active category: $activeCategoryTitle');
  }

  // Save current selections to Hive
  Future<void> _saveToHive() async {
    try {
      await HiveService.saveCategorySelections(categorySelections);
    } catch (e) {
      print('Error saving to Hive: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Text(
              'Great, so what kind of work are you here to do?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Don\'t worry, you can change these choices later on.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inverseSurface
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              thickness: 1,
            ),
            const SizedBox(height: 20),
            ExpandableSelectionWidget(
              key: ValueKey('Accounting & Consulting'),
              title: 'Accounting & Consulting',
              options: const [
                'Personal & Professional Coaching',
                'Accounting & Bookkeeping',
                'Financial Planning',
                'Recruiting & Human Resources',
                'Management Consulting & Analysis',
                'Other - Accounting & Consulting',
              ],
              minSelections: 1,
              maxSelections: 3,
              isDisabled: activeCategoryTitle != null && activeCategoryTitle != 'Accounting & Consulting',
              initialSelectedOptions: categorySelections['Accounting & Consulting'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Accounting & Consulting', selectedOptions);
              },
            ),
            ExpandableSelectionWidget(
              key: ValueKey('Admin Support'),
              title: 'Admin Support',
              options: const [
                'Virtual Assistant',
                'Data Entry',
                'Web Research',
                'Transcription',
                'Customer Support',
                'Other - Admin Support',
              ],
              minSelections: 1,
              maxSelections: 3,
              isDisabled: activeCategoryTitle != null && activeCategoryTitle != 'Admin Support',
              initialSelectedOptions: categorySelections['Admin Support'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Admin Support', selectedOptions);
              },
            ),
            ExpandableSelectionWidget(
              key: ValueKey('Customer Service'),
              title: 'Customer Service',
              options: const [
                'Phone Support',
                'Email Support',
                'Live Chat Support',
                'Technical Support',
                'Social Media Support',
                'Other - Customer Service',
              ],
              minSelections: 1,
              maxSelections: 3,
              isDisabled: activeCategoryTitle != null && activeCategoryTitle != 'Customer Service',
              initialSelectedOptions: categorySelections['Customer Service'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Customer Service', selectedOptions);
              },
            ),
            ExpandableSelectionWidget(
              key: ValueKey('Design & Creative'),
              title: 'Design & Creative',
              options: const [
                'Graphic Design',
                'Web Design',
                'Logo Design',
                'Video Editing',
                'Photography',
                'Other - Design & Creative',
              ],
              minSelections: 1,
              maxSelections: 3,
              isDisabled: activeCategoryTitle != null && activeCategoryTitle != 'Design & Creative',
              initialSelectedOptions: categorySelections['Design & Creative'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Design & Creative', selectedOptions);
              },
            ),
            ExpandableSelectionWidget(
              key: ValueKey('Engineering & Architecture'),
              title: 'Engineering & Architecture',
              options: const [
                'Software Development',
                'Web Development',
                'Mobile App Development',
                'DevOps & Cloud',
                'Data Science',
                'Other - Engineering & Architecture',
              ],
              minSelections: 1,
              maxSelections: 3,
              isDisabled: activeCategoryTitle != null && activeCategoryTitle != 'Engineering & Architecture',
              initialSelectedOptions: categorySelections['Engineering & Architecture'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Engineering & Architecture', selectedOptions);
              },
            ),
            const SizedBox(height: 50), // Add some bottom padding
          ],
        ),
      ),
    );
  }
}