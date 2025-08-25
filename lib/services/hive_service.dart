// Fixed hive_service.dart
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

      print('Hive initialized successfully');
    } catch (e) {
      print('Error initializing Hive: $e');
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
      print('Work selection saved: $categoryTitle with ${selectedOptions.length} options');
    } catch (e) {
      print('Error saving work selection: $e');
      rethrow;
    }
  }

  // Get work selection from Hive
  static Future<WorkSelection?> getWorkSelection() async {
    try {
      final box = await _getBox();
      final workSelection = box.get(_workSelectionKey);
      print('Retrieved work selection: ${workSelection?.categoryTitle} with ${workSelection?.selectedOptions.length ?? 0} options');
      return workSelection;
    } catch (e) {
      print('Error getting work selection: $e');
      return null;
    }
  }

  // Check if work selection exists
  static Future<bool> hasWorkSelection() async {
    try {
      final box = await _getBox();
      final hasData = box.containsKey(_workSelectionKey);
      print('Has work selection: $hasData');
      return hasData;
    } catch (e) {
      print('Error checking work selection: $e');
      return false;
    }
  }

  // Clear work selection
  static Future<void> clearWorkSelection() async {
    try {
      final box = await _getBox();
      await box.delete(_workSelectionKey);
      print('Work selection cleared');
    } catch (e) {
      print('Error clearing work selection: $e');
    }
  }

  // Save category selections (for internal state management)
  static Future<void> saveCategorySelections(Map<String, List<String>> categorySelections) async {
    try {
      // Find the active category (one with selections)
      String? activeCategory;
      List<String> selectedOptions = [];

      for (var entry in categorySelections.entries) {
        if (entry.value.isNotEmpty) {
          activeCategory = entry.key;
          selectedOptions = entry.value;
          break;
        }
      }

      if (activeCategory != null && selectedOptions.isNotEmpty) {
        await saveWorkSelection(activeCategory, selectedOptions);
        print('Category selections saved for: $activeCategory');
      } else {
        // If no selections, clear the saved data
        await clearWorkSelection();
        print('No selections found, cleared saved data');
      }
    } catch (e) {
      print('Error saving category selections: $e');
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
      print('Error closing boxes: $e');
    }
  }

  // Debug method to print all data in the box
  static Future<void> debugPrintAllData() async {
    try {
      final box = await _getBox();
      print('=== DEBUG: All data in work_selections box ===');
      print('Keys: ${box.keys.toList()}');

      for (var key in box.keys) {
        final value = box.get(key);
        print('Key: $key, Value: ${value?.categoryTitle}, Options: ${value?.selectedOptions}');
      }
      print('=== END DEBUG ===');
    } catch (e) {
      print('Error in debug print: $e');
    }
  }
}