import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../services/hive_service.dart';
import '../../../widgets/expandebale_selection_widget.dart';

class SelectWorkPage extends StatefulWidget {
  final void Function(bool hasSelection)? onSelectionChanged;

  const SelectWorkPage({super.key, this.onSelectionChanged});

  @override
  State<SelectWorkPage> createState() => _SelectWorkPageState();
}

// Updated _loadSavedData method for select_work_page.dart

class _SelectWorkPageState extends State<SelectWorkPage> {
  // Track which category has selections and total selected count
  String? activeCategoryTitle;
  int totalSelectedCount = 0;

  // Track selections for each category
  Map<String, List<String>> categorySelections = {};

  // Add loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Load saved data from Hive when page initializes
  Future<void> _loadSavedData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final savedWorkSelection = await HiveService.getWorkSelection();

      if (savedWorkSelection != null) {

        // Clear existing selections first
        categorySelections.clear();

        // Set the loaded data
        setState(() {
          activeCategoryTitle = savedWorkSelection.categoryTitle;
          categorySelections[savedWorkSelection.categoryTitle] =
          List<String>.from(savedWorkSelection.selectedOptions);
          totalSelectedCount = savedWorkSelection.selectedOptions.length;
          _isLoading = false;
        });

        // Notify parent about existing selection
        if (widget.onSelectionChanged != null) {
          widget.onSelectionChanged!(totalSelectedCount > 0);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSelectionChanged(String categoryTitle, List<String> selectedOptions) {

    setState(() {
      // Clear all other category selections (since only one can be active)
      categorySelections.clear();

      // Set the new selections
      if (selectedOptions.isNotEmpty) {
        categorySelections[categoryTitle] = selectedOptions;
        activeCategoryTitle = categoryTitle;
        totalSelectedCount = selectedOptions.length;
      } else {
        activeCategoryTitle = null;
        totalSelectedCount = 0;
      }
    });
    // Notify parent if at least one selection exists
    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(totalSelectedCount > 0);
    }

    // Save to Hive whenever selection changes
    _saveToHive();
  }

  // Save current selections to Hive
  Future<void> _saveToHive() async {
    try {
      await HiveService.saveCategorySelections(categorySelections);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving to Hive: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is being loaded
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
            const Divider(thickness: 1),
            const SizedBox(height: 20),

            ExpandableSelectionWidget(
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
              selectedOptions: categorySelections['Accounting & Consulting'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Accounting & Consulting', selectedOptions);
              },
            ),

            ExpandableSelectionWidget(
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
              selectedOptions: categorySelections['Admin Support'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Admin Support', selectedOptions);
              },
            ),

            ExpandableSelectionWidget(
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
              selectedOptions: categorySelections['Customer Service'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Customer Service', selectedOptions);
              },
            ),

            ExpandableSelectionWidget(
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
              selectedOptions: categorySelections['Design & Creative'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Design & Creative', selectedOptions);
              },
            ),

            ExpandableSelectionWidget(
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
              selectedOptions: categorySelections['Engineering & Architecture'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Engineering & Architecture', selectedOptions);
              },
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}