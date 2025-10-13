import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../secrets/app_secrets.dart';

class TitleService {
  static const String baseUrl = '${SERVER.serverURL}/api';

  /// Save or update user's work title
  static Future<Map<String, dynamic>> saveTitle({
    required String title,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('USER_ID');

      if (token == null || userId == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please log in again.',
        };
      }

      final uri = Uri.parse('$baseUrl/profiles/$userId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Title saved successfully',
          'data': data['data'],
        };
      } else {
        // Try to parse error response
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to save title',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Server error (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  /// Get user's current profile data
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('USER_ID');

      if (token == null || userId == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final uri = Uri.parse('$baseUrl/profiles/$userId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to get profile',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Server error (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }

  /// Validate title before saving
  static String? validateTitle(String title) {
    if (title.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    if (title.length > 99) {
      return 'Title cannot exceed 99 characters';
    }
    if (title.length < 10) {
      return 'Title should be at least 10 characters';
    }
    return null; // Valid
  }
}