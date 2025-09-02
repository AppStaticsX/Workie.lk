import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workie/values/color.dart';
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
  // Track selections for multiple categories (up to 2)
  Map<String, List<String>> categorySelections = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final savedWorkSelection = await HiveService.getWorkSelection();

      if (savedWorkSelection != null) {
        categorySelections.clear();

        setState(() {
          categorySelections[savedWorkSelection.categoryTitle] =
          List<String>.from(savedWorkSelection.selectedOptions);
          _isLoading = false;
        });

        if (widget.onSelectionChanged != null) {
          widget.onSelectionChanged!(categorySelections.isNotEmpty);
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
      if (selectedOptions.isNotEmpty) {
        categorySelections[categoryTitle] = selectedOptions;
      } else {
        categorySelections.remove(categoryTitle);
      }
    });

    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(categorySelections.isNotEmpty);
    }

    _saveToHive();
  }

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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
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
              'You can select up to 2 categories. No problem, you can update these details later.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSilver,
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
              // Disable if 2 categories are already selected AND this isn't one of them
              isDisabled: categorySelections.length >= 2 &&
                  !categorySelections.containsKey('Masonry & Construction Work'),
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
              isDisabled: categorySelections.length >= 2 &&
                  !categorySelections.containsKey('Carpentry & Wood Work'),
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
              isDisabled: categorySelections.length >= 2 &&
                  !categorySelections.containsKey('Welding & Metal Fabrication'),
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
              isDisabled: categorySelections.length >= 2 &&
                  !categorySelections.containsKey('Painting & Finishing Work'),
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
              isDisabled: categorySelections.length >= 2 &&
                  !categorySelections.containsKey('Tile & Flooring Work'),
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