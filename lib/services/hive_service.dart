import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../hive_db/work_selection_model.dart';

class HiveService {
  static const String _workSelectionBoxName = 'work_selections';
  static const String _workSelectionKey = 'user_work_selection';
  
  // Post ID storage constants
  static const String _savedPostsBoxName = 'saved_posts';
  static const String _savedPostsListKey = 'saved_posts_list';

  // Keep a reference to the opened boxes
  static Box<WorkSelection>? _workSelectionBox;
  static Box? _savedPostsBox;

  // Initialize Hive and register adapters
  static Future<void> initHive() async {
    try {
      // Register the adapter only if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(WorkSelectionAdapter());
      }

      // Open the boxes and keep them open
      if (_workSelectionBox == null || !_workSelectionBox!.isOpen) {
        _workSelectionBox = await Hive.openBox<WorkSelection>(_workSelectionBoxName);
      }
      
      if (_savedPostsBox == null || !_savedPostsBox!.isOpen) {
        _savedPostsBox = await Hive.openBox(_savedPostsBoxName);
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

  // Get the saved posts box (open it if not already open)
  static Future<Box> _getSavedPostsBox() async {
    if (_savedPostsBox == null || !_savedPostsBox!.isOpen) {
      await initHive();
    }
    return _savedPostsBox!;
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

  static Future<bool> savePostId(String postId) async {
    try {
      final box = await _getSavedPostsBox();
      
      // Get existing saved posts list
      List<String> savedPosts = getSavedPostsSync(box);
      
      // Check if post is already saved
      if (savedPosts.contains(postId)) {
        if (kDebugMode) {
          print('Post $postId is already saved');
        }
        return false; // Already saved
      }
      
      // Add new post ID to the beginning of the list (most recent first)
      savedPosts.insert(0, postId);
      
      // Save updated list
      await box.put(_savedPostsListKey, savedPosts);
      
      if (kDebugMode) {
        print('Saved post ID: $postId');
        print('Total saved posts: ${savedPosts.length}');
      }
      
      return true; // Successfully saved
    } catch (e) {
      if (kDebugMode) {
        print('Error saving post ID: $e');
      }
      return false;
    }
  }

  /// Remove a post ID from the saved posts list
  static Future<bool> removePostId(String postId) async {
    try {
      final box = await _getSavedPostsBox();
      
      // Get existing saved posts list
      List<String> savedPosts = getSavedPostsSync(box);
      
      // Check if post exists in the list
      if (!savedPosts.contains(postId)) {
        if (kDebugMode) {
          print('Post $postId is not in saved posts');
        }
        return false; // Not found
      }
      
      // Remove the post ID
      savedPosts.remove(postId);
      
      // Save updated list
      await box.put(_savedPostsListKey, savedPosts);
      
      if (kDebugMode) {
        print('Removed post ID: $postId');
        print('Total saved posts: ${savedPosts.length}');
      }
      
      return true; // Successfully removed
    } catch (e) {
      if (kDebugMode) {
        print('Error removing post ID: $e');
      }
      return false;
    }
  }

  /// Get all saved post IDs
  static Future<List<String>> getSavedPostIds() async {
    try {
      final box = await _getSavedPostsBox();
      return getSavedPostsSync(box);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting saved post IDs: $e');
      }
      return [];
    }
  }

  /// Check if a specific post ID is saved
  static Future<bool> isPostSaved(String postId) async {
    try {
      final box = await _getSavedPostsBox();
      final savedPosts = getSavedPostsSync(box);
      return savedPosts.contains(postId);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if post is saved: $e');
      }
      return false;
    }
  }

  /// Get the count of saved posts
  static Future<int> getSavedPostsCount() async {
    try {
      final savedPosts = await getSavedPostIds();
      return savedPosts.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting saved posts count: $e');
      }
      return 0;
    }
  }

  /// Clear all saved posts
  static Future<void> clearAllSavedPosts() async {
    try {
      final box = await _getSavedPostsBox();
      await box.delete(_savedPostsListKey);
      
      if (kDebugMode) {
        print('Cleared all saved posts');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing saved posts: $e');
      }
    }
  }

  /// Toggle post save status (save if not saved, remove if saved)
  static Future<bool> togglePostSave(String postId) async {
    try {
      final isCurrentlySaved = await isPostSaved(postId);
      
      if (isCurrentlySaved) {
        await removePostId(postId);
        return false; // Now unsaved
      } else {
        await savePostId(postId);
        return true; // Now saved
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling post save status: $e');
      }
      return false;
    }
  }

  /// Get recent saved post IDs with limit
  static Future<List<String>> getRecentSavedPostIds({int limit = 10}) async {
    try {
      final allSavedPosts = await getSavedPostIds();
      
      if (allSavedPosts.length <= limit) {
        return allSavedPosts;
      }
      
      return allSavedPosts.sublist(0, limit);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recent saved post IDs: $e');
      }
      return [];
    }
  }

  /// Helper method to get saved posts synchronously from box
  static List<String> getSavedPostsSync(Box box) {
    try {
      final savedPostsData = box.get(_savedPostsListKey);
      
      if (savedPostsData == null) {
        return [];
      }
      
      // Handle both List<String> and List<dynamic>
      if (savedPostsData is List<String>) {
        return savedPostsData;
      } else if (savedPostsData is List) {
        return savedPostsData.map((item) => item.toString()).toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error in getSavedPostsSync: $e');
      }
      return [];
    }
  }

  // Close all boxes (call this when app is closing)
  static Future<void> closeBoxes() async {
    try {
      if (_workSelectionBox != null && _workSelectionBox!.isOpen) {
        await _workSelectionBox!.close();
        _workSelectionBox = null;
      }
      
      if (_savedPostsBox != null && _savedPostsBox!.isOpen) {
        await _savedPostsBox!.close();
        _savedPostsBox = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error closing boxes: $e');
      }
    }
  }

  // Debug method to print all data in both boxes
  static Future<void> debugPrintAllData() async {
    try {
      // Work Selection Box Debug
      final workBox = await _getBox();
      if (kDebugMode) {
        print('=== Work Selection Hive Data ===');
        print('Total keys in work selection box: ${workBox.keys.length}');
      }

      for (var key in workBox.keys) {
        final value = workBox.get(key);
        if (kDebugMode) {
          if (value is WorkSelection) {
            print('Key: $key, Category: ${value.categoryTitle}, Options: ${value.selectedOptions}');
          } else {
            print('Key: $key, Value: $value');
          }
        }
      }

      // Also print the parsed category selections
      final allSelections = await getAllCategorySelections();
      if (kDebugMode) {
        print('=== Parsed Category Selections ===');
        print('Number of categories: ${allSelections.length}');
        allSelections.forEach((category, options) {
          print('Category: $category, Options: $options');
        });
      }

      // Saved Posts Box Debug
      try {
        final savedPostsBox = await _getSavedPostsBox();
        final savedPosts = await getSavedPostIds();
        
        if (kDebugMode) {
          print('=== Saved Posts Hive Data ===');
          print('Total keys in saved posts box: ${savedPostsBox.keys.length}');
          print('Number of saved posts: ${savedPosts.length}');
          
          if (savedPosts.isNotEmpty) {
            print('Saved post IDs:');
            for (int i = 0; i < savedPosts.length; i++) {
              print('  ${i + 1}. ${savedPosts[i]}');
            }
          } else {
            print('No saved posts found');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error accessing saved posts box: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in debug print: $e');
      }
    }
  }
}