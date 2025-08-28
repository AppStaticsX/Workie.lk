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
            const SizedBox(height: 24),
            Text(
              'Which kind of jobs are you looking for here?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No problem, you can update these details later.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inverseSurface,
                height: 1.3
              ),
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1),
            const SizedBox(height: 20),

            ExpandableSelectionWidget(
              title: 'Masonry & Construction Work',
              options: const [
                'Brick & Block Work',
                'Concrete Slabs / Foundations',
                'Plastering & Finishing',
                'Boundary Walls & Garden Walls',
                'Renovation & Repair Masonry',
                'Other - Masonry & Construction',
              ],
              minSelections: 1,
              maxSelections: 3,
              isDisabled: activeCategoryTitle != null && activeCategoryTitle != 'Masonry & Construction Work',
              selectedOptions: categorySelections['Masonry & Construction Work'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Masonry & Construction Work', selectedOptions);
              },
            ),

            ExpandableSelectionWidget(
              title: 'Carpentry & Wood Work',
              options: const [
                'Door & Window Fitting',
                'Furniture Making & Repair',
                'Roof & Ceiling Wood Work',
                'Partitions & Cupboards',
                'Polishing & Finishing',
                'Other - Carpentry & Wood Work',
              ],
              minSelections: 1,
              maxSelections: 3,
              isDisabled: activeCategoryTitle != null && activeCategoryTitle != 'Carpentry & Wood Work',
              selectedOptions: categorySelections['Carpentry & Wood Work'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Carpentry & Wood Work', selectedOptions);
              },
            ),

            ExpandableSelectionWidget(
              title: 'Welding & Metal Fabrication',
              options: const [
                'Gates & Grills',
                'Steel & Iron Structures',
                'Aluminium Fabrication',
                'Repair Welding',
                'Roofing Frames',
                'Other - Welding & Metal Fabrication',
              ],
              minSelections: 1,
              maxSelections: 3,
              isDisabled: activeCategoryTitle != null && activeCategoryTitle != 'Welding & Metal Fabrication',
              selectedOptions: categorySelections['Welding & Metal Fabrication'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Welding & Metal Fabrication', selectedOptions);
              },
            ),

            ExpandableSelectionWidget(
              title: 'Painting & Finishing Work',
              options: const [
                'Wall & Ceiling Painting',
                'Interior Painting',
                'Exterior Painting',
                'Polishing & Varnishing',
                'Decorative Painting',
                'Other - Painting & Finishing',
              ],
              minSelections: 1,
              maxSelections: 3,
              isDisabled: activeCategoryTitle != null && activeCategoryTitle != 'Painting & Finishing Work',
              selectedOptions: categorySelections['Painting & Finishing Work'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Painting & Finishing Work', selectedOptions);
              },
            ),

            ExpandableSelectionWidget(
              title: 'Tile & Flooring Work',
              options: const [
                'Floor Tiling',
                'Bathroom & Kitchen Tiling',
                'Wall Tiling',
                'Tile Repair & Replacement',
                'Marble / Granite Flooring',
                'Other - Tile & Flooring Work',
              ],
              minSelections: 1,
              maxSelections: 3,
              isDisabled: activeCategoryTitle != null && activeCategoryTitle != 'Tile & Flooring Work',
              selectedOptions: categorySelections['Tile & Flooring Work'] ?? [],
              onSelectionChanged: (selectedOptions) {
                _onSelectionChanged('Tile & Flooring Work', selectedOptions);
              },
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}