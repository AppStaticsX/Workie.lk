import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/education_model.dart';

/// Service class for handling education data operations with the backend API
/// 
/// This service provides methods to:
/// - Save education data to user profile
/// - Upload education certificates
/// - Retrieve user education information
/// - Validate education data before submission
/// 
/// Used primarily when the "Add Personal Info" button is clicked in the profile setup flow
class EducationDataService {
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

  /// Save education data to user profile
  /// This method is called when the "Add Personal Info" button is clicked
  static Future<Map<String, dynamic>?> saveEducationData({
    required List<EducationModel> educationList,
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

      // Convert education models to backend format
      List<Map<String, dynamic>> educationData = [];
      
      for (EducationModel education in educationList) {
        Map<String, dynamic> educationEntry = {
          'institution': education.school,
          'degree': education.course,
          'field': education.fieldOfStudy,
          'startDate': _parseYearToDate(education.startYear),
          'isCurrent': education.isCurrentEducation,
        };

        // Add end date if not current
        if (!education.isCurrentEducation && education.endYear != null) {
          educationEntry['endDate'] = _parseYearToDate(education.endYear!);
        }

        educationData.add(educationEntry);
      }

      // Prepare request body
      final requestBody = {
        'education': educationData,
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
        print('Education save response status: ${response.statusCode}');
        print('Education save response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Education data saved successfully',
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to save education data',
          'error': errorData,
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error saving education data: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Upload education certificate file
  static Future<Map<String, dynamic>?> uploadCertificate({
    required File certificateFile,
    required String fileName,
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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload/certificate'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'certificate',
          certificateFile.path,
          filename: fileName,
          contentType: _getMediaType(fileName),
        ),
      );

      // Add additional fields
      request.fields['userId'] = userId;
      request.fields['type'] = 'education-certificate';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Certificate upload response status: ${response.statusCode}');
        print('Certificate upload response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Certificate uploaded successfully',
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to upload certificate',
          'error': errorData,
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error uploading certificate: $e');
      return {
        'success': false,
        'message': 'Failed to upload certificate: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Get user's education data
  static Future<List<EducationModel>?> getUserEducationData() async {
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
        
        if (profileData['education'] != null) {
          List<dynamic> educationList = profileData['education'];
          return educationList.map((edu) => _convertBackendToModel(edu)).toList();
        }
        
        return [];
      } else {
        if (kDebugMode) print('Failed to get education data: ${response.body}');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error getting education data: $e');
      return null;
    }
  }

  /// Validate education data before saving
  static String? validateEducationData(List<EducationModel> educationList) {
    if (educationList.isEmpty) {
      return 'Please add at least one education entry';
    }

    for (int i = 0; i < educationList.length; i++) {
      final education = educationList[i];
      
      if (education.school.trim().isEmpty) {
        return 'School/Institute is required for entry ${i + 1}';
      }
      
      if (education.course.trim().isEmpty) {
        return 'Course/Degree is required for entry ${i + 1}';
      }
      
      if (education.fieldOfStudy.trim().isEmpty) {
        return 'Field of study is required for entry ${i + 1}';
      }
      
      if (education.startYear.trim().isEmpty || education.startYear == 'Year') {
        return 'Start year is required for entry ${i + 1}';
      }

      // Validate year format
      final startYear = int.tryParse(education.startYear);
      if (startYear == null || startYear < 1950 || startYear > DateTime.now().year + 10) {
        return 'Invalid start year for entry ${i + 1}';
      }

      // Validate end year if provided
      if (!education.isCurrentEducation && education.endYear != null) {
        if (education.endYear!.trim().isEmpty || education.endYear == 'Year') {
          return 'End year is required for entry ${i + 1}';
        }
        
        final endYear = int.tryParse(education.endYear!);
        if (endYear == null || endYear < startYear) {
          return 'Invalid end year for entry ${i + 1}';
        }
      }
    }

    return null; // All validations passed
  }

  // Helper Methods

  /// Convert year string to ISO date string
  static String _parseYearToDate(String year) {
    try {
      final yearInt = int.parse(year);
      return DateTime(yearInt, 1, 1).toIso8601String();
    } catch (e) {
      return DateTime.now().toIso8601String();
    }
  }

  /// Get media type for file upload
  static MediaType _getMediaType(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  /// Convert backend education data to EducationModel
  static EducationModel _convertBackendToModel(Map<String, dynamic> backendData) {
    return EducationModel(
      school: backendData['institution'] ?? '',
      course: backendData['degree'] ?? '',
      fieldOfStudy: backendData['field'] ?? '',
      startYear: _extractYearFromDate(backendData['startDate']),
      endYear: backendData['isCurrent'] == true 
          ? null 
          : _extractYearFromDate(backendData['endDate']),
      // Note: Certificate files would need to be handled separately
      // as they're not part of the basic education data structure
    );
  }

  /// Extract year from ISO date string
  static String _extractYearFromDate(dynamic dateValue) {
    if (dateValue == null) return 'Year';
    
    try {
      DateTime date = DateTime.parse(dateValue.toString());
      return date.year.toString();
    } catch (e) {
      return 'Year';
    }
  }

  /// Save multiple education entries with certificate uploads
  static Future<Map<String, dynamic>?> saveEducationDataWithCertificates({
    required List<EducationModel> educationList,
  }) async {
    try {
      // First validate all education data
      final validationError = validateEducationData(educationList);
      if (validationError != null) {
        return {
          'success': false,
          'message': validationError,
        };
      }

      // Upload certificates first (if any)
      List<EducationModel> updatedEducationList = [];
      
      for (EducationModel education in educationList) {
        if (education.hasCertificate) {
          final uploadResult = await uploadCertificate(
            certificateFile: education.certificateFile!,
            fileName: education.certificateFileName!,
          );
          
          if (uploadResult?['success'] != true) {
            return {
              'success': false,
              'message': 'Failed to upload certificate for ${education.school}: ${uploadResult?['message']}',
            };
          }
          
          // Create updated education entry with certificate URL
          // Note: You might need to update EducationModel to include certificate URL
          updatedEducationList.add(education);
        } else {
          updatedEducationList.add(education);
        }
      }

      // Then save education data
      return await saveEducationData(educationList: updatedEducationList);
      
    } catch (e) {
      if (kDebugMode) print('Error in saveEducationDataWithCertificates: $e');
      return {
        'success': false,
        'message': 'An error occurred while saving education data: ${e.toString()}',
      };
    }
  }
}