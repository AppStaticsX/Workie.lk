import 'package:flutter/material.dart';
import '../../../widgets/expandebale_selection_widget.dart';

class SelectWorkPage extends StatefulWidget {
  const SelectWorkPage({super.key});

  @override
  State<SelectWorkPage> createState() => _SelectWorkPageState();
}

class _SelectWorkPageState extends State<SelectWorkPage> {
  // Track which category has selections and total selected count
  String? activeCategoryTitle;
  int totalSelectedCount = 0;

  // Track selections for each category
  Map<String, List<String>> categorySelections = {};

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

    print('Selected options in $categoryTitle: $selectedOptions');
    print('Total selections: $totalSelectedCount');
    print('Active category: $activeCategoryTitle');
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