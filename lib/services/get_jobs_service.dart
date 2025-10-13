import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../secrets/app_secrets.dart';

class GetJobsService {
  static const String _baseUrl = '${SERVER.serverURL}/api/jobs';
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

  /// Get all jobs with filtering, sorting, and pagination
  /// 
  /// Parameters:
  /// - [page]: Page number for pagination (default: 1)
  /// - [limit]: Number of jobs per page (default: 10)
  /// - [category]: Filter by job category
  /// - [city]: Filter by city
  /// - [minBudget]: Minimum budget amount
  /// - [maxBudget]: Maximum budget amount
  /// - [status]: Job status (default: 'open')
  /// - [urgency]: Job urgency level
  /// - [sortBy]: Field to sort by (default: 'createdAt')
  /// - [sortOrder]: Sort order 'asc' or 'desc' (default: 'desc')
  /// - [search]: Search term for title, description, or skills
  /// 
  /// Returns a Map containing success status, job data, and pagination info
  static Future<Map<String, dynamic>> getAllJobs({
    int page = 1,
    int limit = 10,
    String? category,
    String? city,
    double? minBudget,
    double? maxBudget,
    String status = 'open',
    String? urgency,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    String? search,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'status': status,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (category != null) queryParams['category'] = category;
      if (city != null) queryParams['city'] = city;
      if (minBudget != null) queryParams['minBudget'] = minBudget.toString();
      if (maxBudget != null) queryParams['maxBudget'] = maxBudget.toString();
      if (urgency != null) queryParams['urgency'] = urgency;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      if (kDebugMode) {
        print('Getting jobs from: $uri');
      }

      final response = await http.get(uri, headers: headers);

      if (kDebugMode) {
        print('Get jobs response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return {
            'success': true,
            'jobs': responseData['data']['jobs'],
            'pagination': responseData['data']['pagination'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch jobs',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: Failed to fetch jobs',
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error getting jobs: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Get a single job by ID
  /// 
  /// Parameters:
  /// - [jobId]: The ID of the job to fetch
  /// 
  /// Returns a Map containing success status and job data
  static Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$_baseUrl/$jobId');
      
      if (kDebugMode) {
        print('Getting job by ID from: $uri');
      }

      final response = await http.get(uri, headers: headers);

      if (kDebugMode) {
        print('Get job by ID response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return {
            'success': true,
            'job': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Job not found',
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Job not found',
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: Failed to fetch job',
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error getting job by ID: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Get current user's jobs (posted jobs for clients, applied/assigned jobs for workers)
  /// 
  /// Parameters:
  /// - [status]: Filter by job status
  /// - [page]: Page number for pagination (default: 1)
  /// - [limit]: Number of jobs per page (default: 10)
  /// 
  /// Returns a Map containing success status, job data, and pagination info
  static Future<Map<String, dynamic>> getMyJobs({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      if (!(await isAuthenticated())) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      final headers = await _getHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$_baseUrl/user/my-jobs').replace(queryParameters: queryParams);
      
      if (kDebugMode) {
        print('Getting my jobs from: $uri');
      }

      final response = await http.get(uri, headers: headers);

      if (kDebugMode) {
        print('Get my jobs response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return {
            'success': true,
            'jobs': responseData['data']['jobs'],
            'pagination': responseData['data']['pagination'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch my jobs',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: Failed to fetch my jobs',
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error getting my jobs: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Get applications for a specific job (for job owners)
  /// 
  /// Parameters:
  /// - [jobId]: The ID of the job to get applications for
  /// 
  /// Returns a Map containing success status and applications data
  static Future<Map<String, dynamic>> getJobApplications(String jobId) async {
    try {
      if (!(await isAuthenticated())) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      final headers = await _getHeaders();
      final uri = Uri.parse('$_baseUrl/$jobId/applications');
      
      if (kDebugMode) {
        print('Getting job applications from: $uri');
      }

      final response = await http.get(uri, headers: headers);

      if (kDebugMode) {
        print('Get job applications response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return {
            'success': true,
            'applications': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch applications',
          };
        }
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Access denied. You can only view applications for your own jobs.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Job not found',
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: Failed to fetch applications',
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error getting job applications: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Get jobs by category
  /// 
  /// Parameters:
  /// - [category]: The job category to filter by
  /// - [page]: Page number for pagination (default: 1)
  /// - [limit]: Number of jobs per page (default: 10)
  /// - [city]: Optional city filter
  /// - [minBudget]: Optional minimum budget filter
  /// - [maxBudget]: Optional maximum budget filter
  /// 
  /// Returns a Map containing success status, job data, and pagination info
  static Future<Map<String, dynamic>> getJobsByCategory(
    String category, {
    int page = 1,
    int limit = 10,
    String? city,
    double? minBudget,
    double? maxBudget,
  }) async {
    return getAllJobs(
      page: page,
      limit: limit,
      category: category,
      city: city,
      minBudget: minBudget,
      maxBudget: maxBudget,
    );
  }

  /// Search jobs by query
  /// 
  /// Parameters:
  /// - [searchQuery]: The search term
  /// - [page]: Page number for pagination (default: 1)
  /// - [limit]: Number of jobs per page (default: 10)
  /// - [category]: Optional category filter
  /// - [city]: Optional city filter
  /// 
  /// Returns a Map containing success status, job data, and pagination info
  static Future<Map<String, dynamic>> searchJobs(
    String searchQuery, {
    int page = 1,
    int limit = 10,
    String? category,
    String? city,
  }) async {
    return getAllJobs(
      page: page,
      limit: limit,
      search: searchQuery,
      category: category,
      city: city,
    );
  }

  /// Get jobs by location (city)
  /// 
  /// Parameters:
  /// - [city]: The city to filter by
  /// - [page]: Page number for pagination (default: 1)
  /// - [limit]: Number of jobs per page (default: 10)
  /// - [category]: Optional category filter
  /// 
  /// Returns a Map containing success status, job data, and pagination info
  static Future<Map<String, dynamic>> getJobsByLocation(
    String city, {
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    return getAllJobs(
      page: page,
      limit: limit,
      city: city,
      category: category,
    );
  }

  /// Get jobs by budget range
  /// 
  /// Parameters:
  /// - [minBudget]: Minimum budget amount
  /// - [maxBudget]: Maximum budget amount
  /// - [page]: Page number for pagination (default: 1)
  /// - [limit]: Number of jobs per page (default: 10)
  /// - [category]: Optional category filter
  /// - [city]: Optional city filter
  /// 
  /// Returns a Map containing success status, job data, and pagination info
  static Future<Map<String, dynamic>> getJobsByBudgetRange(
    double minBudget,
    double maxBudget, {
    int page = 1,
    int limit = 10,
    String? category,
    String? city,
  }) async {
    return getAllJobs(
      page: page,
      limit: limit,
      minBudget: minBudget,
      maxBudget: maxBudget,
      category: category,
      city: city,
    );
  }

  /// Get jobs by urgency level
  /// 
  /// Parameters:
  /// - [urgency]: The urgency level ('low', 'medium', 'high', 'urgent')
  /// - [page]: Page number for pagination (default: 1)
  /// - [limit]: Number of jobs per page (default: 10)
  /// - [category]: Optional category filter
  /// - [city]: Optional city filter
  /// 
  /// Returns a Map containing success status, job data, and pagination info
  static Future<Map<String, dynamic>> getJobsByUrgency(
    String urgency, {
    int page = 1,
    int limit = 10,
    String? category,
    String? city,
  }) async {
    return getAllJobs(
      page: page,
      limit: limit,
      urgency: urgency,
      category: category,
      city: city,
    );
  }

  /// Refresh jobs data (alias for getAllJobs with no filters)
  /// 
  /// Returns a Map containing success status, job data, and pagination info
  static Future<Map<String, dynamic>> refreshJobs({
    int page = 1,
    int limit = 10,
  }) async {
    return getAllJobs(page: page, limit: limit);
  }
}