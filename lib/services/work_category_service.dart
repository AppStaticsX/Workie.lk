import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'hive_service.dart';

class WorkCategoryService {
  static const String _baseUrl = 'https://workie-lk-backend.onrender.com';
  static const String _authTokenKey = 'auth_token';

  // Get auth token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      if (kDebugMode) print('Error getting auth token: $e');
      return null;
    }
  }

  // Get current user ID from SharedPreferences
  static Future<String?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('USER_ID');
    } catch (e) {
      if (kDebugMode) print('Error getting current user ID: $e');
      return null;
    }
  }

  /// Save work categories to the backend profile
  /// 
  /// This method retrieves all work selections from Hive storage and sends only
  /// the category titles (not the selected options) to the backend API.
  /// 
  /// Returns true if the categories were saved successfully, false otherwise.
  static Future<bool> saveWorkCategoriesToProfile() async {
    try {
      // Get the current user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) print('Error: User ID not found');
        return false;
      }

      // Get the auth token
      final token = await _getAuthToken();
      if (token == null) {
        if (kDebugMode) print('Error: Auth token not found');
        return false;
      }

      // Get all category selections from Hive
      final categorySelections = await HiveService.getAllCategorySelections();
      if (categorySelections.isEmpty) {
        if (kDebugMode) print('Error: No category selections found in Hive');
        return false;
      }

      // Extract only category titles (keys) from the selections
      final List<String> workerCategories = categorySelections.keys.toList();

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'workerCategories': workerCategories,
      };

      if (kDebugMode) {
        print('Saving work categories for user: $userId');
        print('Categories: $workerCategories');
        print('Number of categories: ${workerCategories.length}');
      }

      // Make the API request
      final uri = Uri.parse('$_baseUrl/api/profiles/$userId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (kDebugMode) {
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (kDebugMode) print('Work categories saved successfully to profile');
          return true;
        } else {
          if (kDebugMode) print('API returned success: false - ${responseData['message']}');
          return false;
        }
      } else {
        final errorData = json.decode(response.body);
        if (kDebugMode) {
          print('Failed to save work categories: ${response.statusCode}');
          print('Error message: ${errorData['message']}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Error saving work categories to profile: $e');
      return false;
    }
  }

  /// Save specific work categories to profile
  /// 
  /// This method allows you to directly specify the category titles to save
  /// without relying on Hive storage. Only saves category titles, not selected options.
  /// 
  /// [userId] - The user ID to update the profile for
  /// [categoryTitles] - List of category titles to save
  /// 
  /// Returns true if the categories were saved successfully, false otherwise.
  static Future<bool> saveSpecificWorkCategories({
    required String userId,
    required List<String> categoryTitles,
  }) async {
    try {
      // Get the auth token
      final token = await _getAuthToken();
      if (token == null) {
        if (kDebugMode) print('Error: Auth token not found');
        return false;
      }

      // Prepare the request body with only category titles
      final Map<String, dynamic> requestBody = {
        'workerCategories': categoryTitles,
      };

      if (kDebugMode) {
        print('Saving specific work categories for user: $userId');
        print('Categories: $categoryTitles');
      }

      // Make the API request
      final uri = Uri.parse('$_baseUrl/api/profiles/$userId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (kDebugMode) {
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (kDebugMode) print('Specific work categories saved successfully to profile');
          return true;
        } else {
          if (kDebugMode) print('API returned success: false - ${responseData['message']}');
          return false;
        }
      } else {
        final errorData = json.decode(response.body);
        if (kDebugMode) {
          print('Failed to save specific work categories: ${response.statusCode}');
          print('Error message: ${errorData['message']}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Error saving specific work categories to profile: $e');
      return false;
    }
  }

  /// Get work categories from the user's profile
  /// 
  /// Returns the list of work categories if successful, null otherwise.
  static Future<List<String>?> getWorkCategoriesFromProfile() async {
    try {
      // Get the current user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) print('Error: User ID not found');
        return null;
      }

      // Get the auth token
      final token = await _getAuthToken();
      if (token == null) {
        if (kDebugMode) print('Error: Auth token not found');
        return null;
      }

      // Make the API request
      final uri = Uri.parse('$_baseUrl/api/profiles/$userId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Get categories API Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final profileData = responseData['data'];
          final workerCategories = profileData['workerCategories'];
          
          if (workerCategories != null && workerCategories is List) {
            if (kDebugMode) print('Retrieved work categories: $workerCategories');
            return List<String>.from(workerCategories);
          }
        }
      } else {
        final errorData = json.decode(response.body);
        if (kDebugMode) {
          print('Failed to get work categories: ${response.statusCode}');
          print('Error message: ${errorData['message']}');
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting work categories from profile: $e');
      return null;
    }
  }

  /// Update work categories by merging with existing categories
  /// 
  /// This method retrieves existing categories and merges them with new ones
  /// to avoid overwriting previously saved categories.
  /// 
  /// [newCategoryTitles] - List of new category titles to add
  /// 
  /// Returns true if the categories were updated successfully, false otherwise.
  static Future<bool> updateWorkCategories({
    required List<String> newCategoryTitles,
  }) async {
    try {
      // Get existing categories
      final existingCategories = await getWorkCategoriesFromProfile() ?? [];
      
      // Merge categories (avoid duplicates)
      final Set<String> mergedCategories = {...existingCategories, ...newCategoryTitles};
      
      // Get current user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) print('Error: User ID not found');
        return false;
      }
      
      // Save merged categories
      return await saveSpecificWorkCategories(
        userId: userId,
        categoryTitles: mergedCategories.toList(),
      );
    } catch (e) {
      if (kDebugMode) print('Error updating work categories: $e');
      return false;
    }
  }

  /// Save multiple work categories from current selection state
  /// 
  /// This method extracts category titles from the current selection map
  /// and saves only the category titles to the backend.
  /// 
  /// [categorySelections] - Map of category titles to their selected options
  /// 
  /// Returns true if the categories were saved successfully, false otherwise.
  static Future<bool> saveWorkCategoriesFromSelections(Map<String, List<String>> categorySelections) async {
    try {
      // Get the current user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) print('Error: User ID not found');
        return false;
      }

      // Extract only category titles (keys) from the selections
      final List<String> categoryTitles = categorySelections.keys.toList();

      if (categoryTitles.isEmpty) {
        if (kDebugMode) print('No categories to save');
        return false;
      }

      // Save the category titles
      return await saveSpecificWorkCategories(
        userId: userId,
        categoryTitles: categoryTitles,
      );
    } catch (e) {
      if (kDebugMode) print('Error saving work categories from selections: $e');
      return false;
    }
  }
}