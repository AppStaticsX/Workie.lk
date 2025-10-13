import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../services/hive_service.dart';
import '../../services/work_category_service.dart';


class WorkCategoriesPage extends StatefulWidget {
  const WorkCategoriesPage({super.key});

  @override
  State<WorkCategoriesPage> createState() => _WorkCategoriesPageState();
}

class _WorkCategoriesPageState extends State<WorkCategoriesPage> {
  List<String> _currentCategories = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Sample available categories - you can expand this list
  final List<String> _availableCategories = [
    'Plumbing',
    'Electrical Work',
    'Carpentry',
    'Painting',
    'Cleaning Services',
    'Gardening',
    'Computer Repair',
    'Mobile Repair',
    'Tutoring',
    'Photography',
    'Graphic Design',
    'Web Development',
    'Content Writing',
    'Translation',
    'Delivery Services',
    'Home Repair',
    'AC Repair',
    'Appliance Repair',
    'Interior Design',
    'Event Planning',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentCategories();
  }

  Future<void> _loadCurrentCategories() async {
    try {
      setState(() => _isLoading = true);
      
      // Try to get categories from the backend first
      final backendCategories = await WorkCategoryService.getWorkCategoriesFromProfile();
      
      if (backendCategories != null && backendCategories.isNotEmpty) {
        setState(() {
          _currentCategories = backendCategories;
        });
      } else {
        // Fallback to Hive storage
        final hiveSelections = await HiveService.getAllCategorySelections();
        setState(() {
          _currentCategories = hiveSelections.keys.toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCategories() async {
    try {
      setState(() => _isSaving = true);
      
      final success = await WorkCategoryService.saveWorkCategoriesFromSelections(
        Map.fromEntries(_currentCategories.map((category) => MapEntry(category, <String>[]))),
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Work categories saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save work categories'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving categories: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_currentCategories.contains(category)) {
        _currentCategories.remove(category);
      } else {
        _currentCategories.add(category);
      }
    });
  }

  void _showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: Text(
            'Add Custom Category',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
            decoration: InputDecoration(
              hintText: 'Enter category name',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: const Color(0xFF4E6BF5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: const Color(0xFF4E6BF5), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                final categoryName = controller.text.trim();
                if (categoryName.isNotEmpty && !_currentCategories.contains(categoryName)) {
                  setState(() {
                    _currentCategories.add(categoryName);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Add',
                style: TextStyle(color: const Color(0xFF4E6BF5), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: const Color(0xFF4E6BF5),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Iconsax.arrow_left_copy, color: Colors.white),
        ),
        title: Text(
          'Work Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showAddCategoryDialog,
            icon: Icon(Iconsax.add_copy, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF4E6BF5),
            ),
          )
        : Column(
            children: [
              // Current Categories Section
              if (_currentCategories.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.tertiary,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Selected Categories (${_currentCategories.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _currentCategories.map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4E6BF5).withOpacity(0.1),
                              border: Border.all(color: const Color(0xFF4E6BF5)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.tick_circle_copy,
                                  size: 16,
                                  color: const Color(0xFF4E6BF5),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: const Color(0xFF4E6BF5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _toggleCategory(category),
                                  child: Icon(
                                    Iconsax.close_circle_copy,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Available Categories Section
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.tertiary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Available Categories',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _availableCategories.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          ),
                          itemBuilder: (context, index) {
                            final category = _availableCategories[index];
                            final isSelected = _currentCategories.contains(category);
                            
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isSelected ? const Color(0xFF4E6BF5) : Colors.grey).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Iconsax.briefcase_copy,
                                  color: isSelected ? const Color(0xFF4E6BF5) : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                category,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                ),
                              ),
                              trailing: isSelected
                                ? Icon(
                                    Iconsax.tick_circle_copy,
                                    color: const Color(0xFF4E6BF5),
                                  )
                                : Icon(
                                    Iconsax.add_circle_copy,
                                    color: Colors.grey,
                                  ),
                              onTap: () => _toggleCategory(category),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Save Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.tertiary,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCategories,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E6BF5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Saving...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Save Categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                ),
              ),
            ],
          ),
    );
  }
}