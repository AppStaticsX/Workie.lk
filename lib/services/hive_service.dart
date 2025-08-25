// hive_service.dart
import 'package:hive/hive.dart';
import '../hive_db/work_selection_model.dart';

class HiveService {
  static const String _workSelectionBoxName = 'work_selections';
  static const String _workSelectionKey = 'user_work_selection';

  // Initialize Hive and register adapters
  static Future<void> initHive() async {
    // Register the adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WorkSelectionAdapter());
    }
  }

  // Save work selection to Hive
  static Future<void> saveWorkSelection(String categoryTitle, List<String> selectedOptions) async {
    try {
      final box = await Hive.openBox<WorkSelection>(_workSelectionBoxName);

      final workSelection = WorkSelection(
        categoryTitle: categoryTitle,
        selectedOptions: selectedOptions,
      );

      await box.put(_workSelectionKey, workSelection);
      await box.close();
    } catch (e) {
      print('Error saving work selection: $e');
    }
  }

  // Get work selection from Hive
  static Future<WorkSelection?> getWorkSelection() async {
    try {
      final box = await Hive.openBox<WorkSelection>(_workSelectionBoxName);
      final workSelection = box.get(_workSelectionKey);
      await box.close();
      return workSelection;
    } catch (e) {
      print('Error getting work selection: $e');
      return null;
    }
  }

  // Check if work selection exists
  static Future<bool> hasWorkSelection() async {
    try {
      final box = await Hive.openBox<WorkSelection>(_workSelectionBoxName);
      final hasData = box.containsKey(_workSelectionKey);
      await box.close();
      return hasData;
    } catch (e) {
      print('Error checking work selection: $e');
      return false;
    }
  }

  // Clear work selection
  static Future<void> clearWorkSelection() async {
    try {
      final box = await Hive.openBox<WorkSelection>(_workSelectionBoxName);
      await box.delete(_workSelectionKey);
      await box.close();
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
      }
    } catch (e) {
      print('Error saving category selections: $e');
    }
  }
}