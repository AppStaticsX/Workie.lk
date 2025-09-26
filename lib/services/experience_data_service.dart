import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_experience_model.dart';

/// Service class for handling work experience data operations with the backend API
/// 
/// This service provides methods to:
/// - Save work experience data to user profile
/// - Retrieve user work experience information
/// - Validate work experience data before submission
/// 
/// Used primarily when the "Add Education" button is clicked in the profile setup flow
class ExperienceDataService {
  static const String _baseUrl = 'https://workie-lk-backend.onrender.com/api';
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'USER_ID';

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
  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      if (kDebugMode) print('Error getting current user ID: $e');
      return null;
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Save work experience data to user profile
  /// This method is called when the "Add Education" button is clicked
  static Future<Map<String, dynamic>?> saveExperienceData({
    required List<WorkExperienceModel> experienceList,
  }) async {
    try {
      // Check authentication
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Convert work experience models to backend format
      List<Map<String, dynamic>> experienceData = [];
      
      for (WorkExperienceModel experience in experienceList) {
        Map<String, dynamic> experienceEntry = {
          'title': experience.title,
          'company': experience.company,
          'location': experience.location,
          'startDate': _parseMonthYearToDate(experience.startMonth, experience.startYear),
          'isCurrent': experience.isCurrentWork,
        };

        // Add end date if not current
        if (!experience.isCurrentWork && experience.endMonth != null && experience.endYear != null) {
          experienceEntry['endDate'] = _parseMonthYearToDate(experience.endMonth!, experience.endYear!);
        }

        experienceData.add(experienceEntry);
      }

      // Prepare request body
      final requestBody = {
        'experience': experienceData,
      };

      // Make API call to update profile
      final response = await http.put(
        Uri.parse('$_baseUrl/profiles/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        print('Experience save response status: ${response.statusCode}');
        print('Experience save response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Work experience saved successfully',
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to save work experience',
          'error': errorData,
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error saving work experience: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Get user's work experience data
  static Future<List<WorkExperienceModel>?> getUserExperienceData() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/profiles/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final profileData = responseData['data']['profile'];
        
        if (profileData['experience'] != null) {
          List<dynamic> experienceList = profileData['experience'];
          return experienceList.map((exp) => _convertBackendToModel(exp)).toList();
        }
        
        return [];
      } else {
        if (kDebugMode) print('Failed to get experience data: ${response.body}');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error getting experience data: $e');
      return null;
    }
  }

  /// Add a single work experience to profile
  static Future<Map<String, dynamic>?> addSingleExperience({
    required WorkExperienceModel experience,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Prepare experience data for backend
      final experienceData = {
        'title': experience.title,
        'company': experience.company,
        'location': experience.location,
        'startDate': _parseMonthYearToDate(experience.startMonth, experience.startYear),
        'isCurrent': experience.isCurrentWork,
      };

      // Add end date if not current
      if (!experience.isCurrentWork && experience.endMonth != null && experience.endYear != null) {
        experienceData['endDate'] = _parseMonthYearToDate(experience.endMonth!, experience.endYear!);
      }

      // Make API call to add experience
      final response = await http.post(
        Uri.parse('$_baseUrl/profiles/$userId/experience'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(experienceData),
      );

      if (kDebugMode) {
        print('Add experience response status: ${response.statusCode}');
        print('Add experience response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Work experience added successfully',
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to add work experience',
          'error': errorData,
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error adding work experience: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Validate work experience data before saving
  static String? validateExperienceData(List<WorkExperienceModel> experienceList) {
    if (experienceList.isEmpty) {
      return 'Please add at least one work experience entry';
    }

    for (int i = 0; i < experienceList.length; i++) {
      final experience = experienceList[i];
      
      if (experience.title.trim().isEmpty) {
        return 'Job title is required for entry ${i + 1}';
      }
      
      if (experience.company.trim().isEmpty) {
        return 'Company name is required for entry ${i + 1}';
      }
      
      if (experience.location.trim().isEmpty) {
        return 'Location is required for entry ${i + 1}';
      }
      
      if (experience.startMonth == 'Month' || experience.startYear == 'Year') {
        return 'Start date is required for entry ${i + 1}';
      }

      // Validate year format
      final startYear = int.tryParse(experience.startYear);
      if (startYear == null || startYear < 1950 || startYear > DateTime.now().year) {
        return 'Invalid start year for entry ${i + 1}';
      }

      // Validate end date if provided
      if (!experience.isCurrentWork && 
          (experience.endMonth == null || experience.endYear == null ||
           experience.endMonth == 'Month' || experience.endYear == 'Year')) {
        return 'End date is required for entry ${i + 1}';
      }

      if (!experience.isCurrentWork && experience.endMonth != null && experience.endYear != null) {
        final endYear = int.tryParse(experience.endYear!);
        if (endYear == null || endYear < startYear) {
          return 'Invalid end date for entry ${i + 1}';
        }

        // Check if end date is before start date
        if (_isEndDateBeforeStartDate(experience)) {
          return 'End date cannot be before start date for entry ${i + 1}';
        }
      }
    }

    return null; // All validations passed
  }

  // Helper Methods

  /// Convert month and year strings to ISO date string
  static String _parseMonthYearToDate(String month, String year) {
    try {
      final monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      final monthIndex = monthNames.indexOf(month) + 1;
      final yearInt = int.parse(year);
      
      return DateTime(yearInt, monthIndex, 1).toIso8601String();
    } catch (e) {
      return DateTime.now().toIso8601String();
    }
  }

  /// Check if end date is before start date
  static bool _isEndDateBeforeStartDate(WorkExperienceModel experience) {
    if (experience.startMonth == 'Month' || experience.startYear == 'Year' ||
        experience.endMonth == null || experience.endYear == null ||
        experience.endMonth == 'Month' || experience.endYear == 'Year') {
      return false;
    }

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final startMonthIndex = monthNames.indexOf(experience.startMonth) + 1;
    final startYearInt = int.parse(experience.startYear);
    final endMonthIndex = monthNames.indexOf(experience.endMonth!) + 1;
    final endYearInt = int.parse(experience.endYear!);

    final startDate = DateTime(startYearInt, startMonthIndex);
    final endDate = DateTime(endYearInt, endMonthIndex);

    return endDate.isBefore(startDate);
  }

  /// Convert backend experience data to WorkExperienceModel
  static WorkExperienceModel _convertBackendToModel(Map<String, dynamic> backendData) {
    final startDate = _extractMonthYearFromDate(backendData['startDate']);
    final endDate = backendData['isCurrent'] == true 
        ? null 
        : _extractMonthYearFromDate(backendData['endDate']);

    return WorkExperienceModel(
      title: backendData['title'] ?? '',
      company: backendData['company'] ?? '',
      location: backendData['location'] ?? '',
      startMonth: startDate['month'] ?? 'Month',
      startYear: startDate['year'] ?? 'Year',
      endMonth: endDate?['month'],
      endYear: endDate?['year'],
      isCurrentWork: backendData['isCurrent'] ?? false,
    );
  }

  /// Extract month and year from ISO date string
  static Map<String, String> _extractMonthYearFromDate(dynamic dateValue) {
    if (dateValue == null) return {'month': 'Month', 'year': 'Year'};
    
    try {
      final date = DateTime.parse(dateValue.toString());
      final monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      return {
        'month': monthNames[date.month - 1],
        'year': date.year.toString(),
      };
    } catch (e) {
      return {'month': 'Month', 'year': 'Year'};
    }
  }

  /// Save multiple work experience entries
  static Future<Map<String, dynamic>?> saveMultipleExperiences({
    required List<WorkExperienceModel> experienceList,
  }) async {
    try {
      // First validate all experience data
      final validationError = validateExperienceData(experienceList);
      if (validationError != null) {
        return {
          'success': false,
          'message': validationError,
        };
      }

      // Save experience data
      return await saveExperienceData(experienceList: experienceList);
      
    } catch (e) {
      if (kDebugMode) print('Error in saveMultipleExperiences: $e');
      return {
        'success': false,
        'message': 'An error occurred while saving work experience: ${e.toString()}',
      };
    }
  }
}