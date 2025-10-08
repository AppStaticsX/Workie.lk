import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientPostService {
  static const String _baseUrl = 'https://workie-lk-backend.onrender.com/api/jobs';
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

  // Create headers for API requests
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Map Flutter category names to backend enum values
  static String _mapCategoryToBackend(String? category) {
    if (category == null) return 'other';
    
    final categoryMap = {
      'Masonry': 'repair-services',
      'Carpentry': 'carpentry',
      'Welding & Metal Fabrication': 'repair-services',
      'Painting & Finishing': 'painting',
      'Tile & Flooring': 'repair-services',
      'Plumbing': 'plumbing',
    };
    
    return categoryMap[category] ?? 'other';
  }

  // Map payment type to budget type
  static String _mapPaymentTypeToBudgetType(String? paymentType) {
    if (paymentType == null) return 'fixed';
    
    switch (paymentType.toLowerCase()) {
      case 'per hour':
        return 'hourly';
      case 'per day':
        return 'fixed';
      default:
        return 'fixed';
    }
  }

  /// Create a new job post
  static Future<Map<String, dynamic>> createJobPost({
    required String jobTitle,
    required String? jobCategory,
    required String jobDescription,
    required String location,
    String? startDate,
    String? endDate,
    String? estimatedDays,
    required String? paymentType,
    required String budget,
    String? workersNeeded,
    required String clientName,
    required String phoneNumber,
    String? whatsappNumber,
    String? email,
    bool materialsProvided = false,
    String? materialsNotes,
    String? jobUrgency,
    List<String>? skills,
    List<String>? requirements,
  }) async {
    try {
      // Check authentication
      if (!(await isAuthenticated())) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      final headers = await _getHeaders();
      
      // Parse budget amount
      double budgetAmount;
      try {
        budgetAmount = double.parse(budget.replaceAll(RegExp(r'[^\d.]'), ''));
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid budget amount',
        };
      }

      // Prepare job data according to backend schema
      final jobData = {
        'title': jobTitle,
        'description': jobDescription,
        'category': _mapCategoryToBackend(jobCategory),
        'budget': {
          'amount': budgetAmount,
          'currency': 'LKR',
          'type': _mapPaymentTypeToBudgetType(paymentType),
        },
        'location': {
          'address': location,
          'city': location.contains(',') ? location.split(',').last.trim() : location.trim(),
        },
        'requirements': <String>[...?requirements],
        'skills': <String>[...?skills],
        'urgency': jobUrgency?.toLowerCase() ?? 'medium',
        'experienceLevel': 'any',
        'isRemote': false,
        'maxApplicants': workersNeeded != null ? int.tryParse(workersNeeded) ?? 50 : 50,
      };

      // Add duration if provided
      if (startDate != null || endDate != null || estimatedDays != null) {
        final durationMap = <String, dynamic>{};
        
        if (startDate != null && startDate.isNotEmpty) {
          try {
            final parts = startDate.split('/');
            if (parts.length == 3) {
              final date = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
              durationMap['startDate'] = date.toIso8601String();
            }
          } catch (e) {
            if (kDebugMode) print('Error parsing start date: $e');
          }
        }
        
        if (endDate != null && endDate.isNotEmpty) {
          try {
            final parts = endDate.split('/');
            if (parts.length == 3) {
              final date = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
              durationMap['endDate'] = date.toIso8601String();
            }
          } catch (e) {
            if (kDebugMode) print('Error parsing end date: $e');
          }
        }
        
        if (estimatedDays != null && estimatedDays.isNotEmpty) {
          durationMap['estimated'] = '$estimatedDays days';
        }
        
        durationMap['isFlexible'] = true;
        jobData['duration'] = durationMap;
      }

      // Add materials information to requirements if provided
      final requirementsList = jobData['requirements'] as List<String>;
      if (materialsProvided && materialsNotes != null && materialsNotes.isNotEmpty) {
        requirementsList.add('Materials provided: $materialsNotes');
      } else if (!materialsProvided) {
        requirementsList.add('Materials not provided - worker should arrange');
      }

      if (kDebugMode) {
        print('Sending job data: ${jsonEncode(jobData)}');
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: jsonEncode(jobData),
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Job posted successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to post job',
          'error': responseData['error'],
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating job post: $e');
      }
      
      // Handle specific error types
      if (e is SocketException) {
        return {
          'success': false,
          'message': 'No internet connection. Please check your network.',
        };
      } else if (e is TimeoutException) {
        return {
          'success': false,
          'message': 'Request timeout. Please try again.',
        };
      } else if (e is FormatException) {
        return {
          'success': false,
          'message': 'Invalid response format from server.',
        };
      }
      
      return {
        'success': false,
        'message': 'An error occurred while posting the job. Please try again.',
        'error': e.toString(),
      };
    }
  }

  /// Upload images for a job
  static Future<Map<String, dynamic>> uploadJobImages({
    required String jobId,
    required List<File> imageFiles,
    List<String>? descriptions,
  }) async {
    try {
      // Check authentication
      if (!(await isAuthenticated())) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      final token = await _getAuthToken();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/$jobId/images'),
      );

      // Add authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add image files
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final multipartFile = await http.MultipartFile.fromPath(
          'jobImages',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      // Add descriptions if provided
      if (descriptions != null) {
        for (int i = 0; i < descriptions.length; i++) {
          request.fields['descriptions'] = descriptions[i];
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (kDebugMode) {
        print('Image upload response status: ${response.statusCode}');
        print('Image upload response body: $responseBody');
      }

      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Images uploaded successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to upload images',
          'error': responseData['error'],
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading job images: $e');
      }
      
      return {
        'success': false,
        'message': 'An error occurred while uploading images. Please try again.',
        'error': e.toString(),
      };
    }
  }

  /// Get job by ID
  static Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$jobId'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch job details',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching job: $e');
      }
      
      return {
        'success': false,
        'message': 'An error occurred while fetching job details.',
        'error': e.toString(),
      };
    }
  }

  /// Get user's posted jobs
  static Future<Map<String, dynamic>> getUserJobs({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Check authentication
      if (!(await isAuthenticated())) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      final headers = await _getHeaders();
      
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$_baseUrl/user/my-jobs').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: headers);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch user jobs',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user jobs: $e');
      }
      
      return {
        'success': false,
        'message': 'An error occurred while fetching your jobs.',
        'error': e.toString(),
      };
    }
  }

  /// Update job status
  static Future<Map<String, dynamic>> updateJobStatus({
    required String jobId,
    required String status,
  }) async {
    try {
      // Check authentication
      if (!(await isAuthenticated())) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      final headers = await _getHeaders();
      
      final response = await http.put(
        Uri.parse('$_baseUrl/$jobId'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Job status updated successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update job status',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating job status: $e');
      }
      
      return {
        'success': false,
        'message': 'An error occurred while updating job status.',
        'error': e.toString(),
      };
    }
  }

  /// Delete job (soft delete)
  static Future<Map<String, dynamic>> deleteJob(String jobId) async {
    try {
      // Check authentication
      if (!(await isAuthenticated())) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/$jobId'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Job deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete job',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting job: $e');
      }
      
      return {
        'success': false,
        'message': 'An error occurred while deleting the job.',
        'error': e.toString(),
      };
    }
  }
}