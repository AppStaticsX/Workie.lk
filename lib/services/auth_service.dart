import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Replace with your actual base URL
  static const String baseUrl = 'https://workie-lk-backend.onrender.com/api/auth';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Check if user is authenticated by validating stored token
  Future<bool> isAuthenticated() async {
    try {
      final String? token = await getStoredToken();

      if (token == null || token.isEmpty) {
        return false;
      }

      return await validateToken(token);
    } catch (e) {
      //print('Authentication check error: $e');
      return false;
    }
  }

  /// Validate token with backend
  Future<bool> validateToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'token': token,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Update user data
          await _updateUserData(responseData['data']);
          return true;
        }
      }

      // Token is invalid, clear stored data
      await clearAuthData();
      return false;

    } on SocketException {
      // Network error - assume authenticated to avoid forcing re-login on network issues
      //print('Network error during token validation');
      return true; // or false, depending on your preference
    } on TimeoutException {
      //print('Token validation timeout');
      return true; // or false, depending on your preference
    } catch (e) {
      //print('Token validation error: $e');
      await clearAuthData();
      return false;
    }
  }

  /// Get stored authentication token
  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Get stored user ID
  Future<String?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('USER_ID');
  }

  /// Store authentication token
  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Store user ID
  Future<void> storeUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('USER_ID', userId);
  }

  /// Update user data from validation response
  Future<void> _updateUserData(Map<String, dynamic> data) async {
    if (data['user']?['_id'] != null) {
      await storeUserId(data['user']['_id']);
    }
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('USER_ID');
  }

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Store authentication data
        if (responseData['data']?['token'] != null) {
          await storeToken(responseData['data']['token']);
        }

        if (responseData['data']?['user']?['_id'] != null) {
          await storeUserId(responseData['data']['user']['_id']);
        }

        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message']
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'statusCode': response.statusCode
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
        'error': 'network'
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please try again.',
        'error': 'timeout'
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid server response. Please try again.',
        'error': 'format'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
        'error': 'unknown'
      };
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String userType = 'worker',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.trim(),
          'password': password,
          'userType': userType,
          'phone': phone?.trim() ?? "",
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        // Store authentication data
        if (responseData['data']?['token'] != null) {
          await storeToken(responseData['data']['token']);
        }

        if (responseData['data']?['user']?['_id'] != null) {
          await storeUserId(responseData['data']['user']['_id']);
        }

        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Registration successful'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
          'statusCode': response.statusCode
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
        'error': 'network'
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please try again.',
        'error': 'timeout'
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid server response. Please try again.',
        'error': 'format'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
        'error': 'unknown'
      };
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final String? token = await getStoredToken();

      if (token != null) {
        // Optional: Call logout endpoint
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      //print('Logout API call failed: $e');
    } finally {
      // Always clear local data
      await clearAuthData();
    }
  }

  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final String? token = await getStoredToken();

      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }

      return null;
    } catch (e) {
      //print('Get current user error: $e');
      return null;
    }
  }

  Future<bool> sendResetPasswordEmail(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      // Optionally, check response body for success
      return true;
    } else {
      // Optionally, handle error
      return false;
    }
  }
}