import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../hive_db/work_selection_model.dart';

class HiveService {
  static const String _workSelectionBoxName = 'work_selections';
  static const String _workSelectionKey = 'user_work_selection';

  // Keep a reference to the opened box
  static Box<WorkSelection>? _workSelectionBox;

  // Initialize Hive and register adapters
  static Future<void> initHive() async {
    try {
      // Register the adapter only if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(WorkSelectionAdapter());
      }

      // Open the box and keep it open
      if (_workSelectionBox == null || !_workSelectionBox!.isOpen) {
        _workSelectionBox = await Hive.openBox<WorkSelection>(_workSelectionBoxName);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get the work selection box (open it if not already open)
  static Future<Box<WorkSelection>> _getBox() async {
    if (_workSelectionBox == null || !_workSelectionBox!.isOpen) {
      await initHive();
    }
    return _workSelectionBox!;
  }

  // Save work selection to Hive
  static Future<void> saveWorkSelection(String categoryTitle, List<String> selectedOptions) async {
    try {
      final box = await _getBox();

      final workSelection = WorkSelection(
        categoryTitle: categoryTitle,
        selectedOptions: selectedOptions,
      );

      await box.put(_workSelectionKey, workSelection);
    } catch (e) {
      rethrow;
    }
  }

  // Get work selection from Hive
  static Future<WorkSelection?> getWorkSelection() async {
    try {
      final box = await _getBox();
      final workSelection = box.get(_workSelectionKey);
      return workSelection;
    } catch (e) {
      return null;
    }
  }

  // Check if work selection exists
  static Future<bool> hasWorkSelection() async {
    try {
      final box = await _getBox();
      
      // Check for new format (category_0, category_1, etc.)
      for (var key in box.keys) {
        if (key.toString().startsWith('category_')) {
          return true;
        }
      }
      
      // Check old format for backward compatibility
      final hasData = box.containsKey(_workSelectionKey);
      return hasData;
    } catch (e) {
      return false;
    }
  }

  // Clear work selection
  static Future<void> clearWorkSelection() async {
    try {
      await _clearAllCategorySelections();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing work selection: $e');
      }
    }
  }

  // Save category selections (for internal state management)
  static Future<void> saveCategorySelections(Map<String, List<String>> categorySelections) async {
    try {
      final box = await _getBox();
      
      // Clear all existing category selections first
      await _clearAllCategorySelections();
      
      // Save each category with a unique key
      int categoryIndex = 0;
      for (var entry in categorySelections.entries) {
        if (entry.value.isNotEmpty) {
          final workSelection = WorkSelection(
            categoryTitle: entry.key,
            selectedOptions: entry.value,
          );
          
          // Use unique keys for each category: 'category_0', 'category_1', etc.
          final key = 'category_$categoryIndex';
          await box.put(key, workSelection);
          categoryIndex++;
        }
      }
      
      if (kDebugMode) {
        print('Saved $categoryIndex categories to Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving category selections: $e');
      }
    }
  }

  // Helper method to clear all category selections
  static Future<void> _clearAllCategorySelections() async {
    try {
      final box = await _getBox();
      
      // Remove all category keys (category_0, category_1, etc.)
      final keysToRemove = <String>[];
      for (var key in box.keys) {
        if (key.toString().startsWith('category_')) {
          keysToRemove.add(key.toString());
        }
      }
      
      for (var key in keysToRemove) {
        await box.delete(key);
      }
      
      // Also remove the old single key for backward compatibility
      await box.delete(_workSelectionKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing category selections: $e');
      }
    }
  }

  // Get all category selections
  static Future<Map<String, List<String>>> getAllCategorySelections() async {
    try {
      final box = await _getBox();
      final Map<String, List<String>> categorySelections = {};
      
      // Get all categories (category_0, category_1, etc.)
      for (var key in box.keys) {
        if (key.toString().startsWith('category_')) {
          final workSelection = box.get(key) as WorkSelection?;
          if (workSelection != null) {
            categorySelections[workSelection.categoryTitle] = workSelection.selectedOptions;
          }
        }
      }
      
      // If no new format found, try the old format for backward compatibility
      if (categorySelections.isEmpty) {
        final oldWorkSelection = box.get(_workSelectionKey) as WorkSelection?;
        if (oldWorkSelection != null) {
          categorySelections[oldWorkSelection.categoryTitle] = oldWorkSelection.selectedOptions;
        }
      }
      
      return categorySelections;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all category selections: $e');
      }
      return {};
    }
  }

  // Close all boxes (call this when app is closing)
  static Future<void> closeBoxes() async {
    try {
      if (_workSelectionBox != null && _workSelectionBox!.isOpen) {
        await _workSelectionBox!.close();
        _workSelectionBox = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error closing boxes: $e');
      }
    }
  }

  // Debug method to print all data in the box
  static Future<void> debugPrintAllData() async {
    try {
      final box = await _getBox();

      if (kDebugMode) {
        print('=== All Hive Data ===');
        print('Total keys in box: ${box.keys.length}');
      }

      for (var key in box.keys) {
        final value = box.get(key);
        if (kDebugMode) {
          if (value is WorkSelection) {
            print('Key: $key, Category: ${value.categoryTitle}, Options: ${value.selectedOptions}');
          } else {
            print('Key: $key, Value: $value');
          }
        }
      }

      // Also print the new format data
      final allSelections = await getAllCategorySelections();
      if (kDebugMode) {
        print('=== Parsed Category Selections ===');
        print('Number of categories: ${allSelections.length}');
        allSelections.forEach((category, options) {
          print('Category: $category, Options: $options');
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in debug print: $e');
      }
    }
  }
}