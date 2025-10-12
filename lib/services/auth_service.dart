import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'background_notification_service.dart';
import 'post_notification_service.dart';
import 'socket_service.dart';

class AuthService {
  // Replace with your actual base URL
  // static const String baseUrl = 'http://localhost:5000/api/auth'; // Local backend for testing
  static const String baseUrl = 'https://workie-lk-backend.onrender.com/api/auth'; // Production backend

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid', // Add this scope for idToken
    ],
  );

  /// Google Sign-In and backend authentication
  Future<Map<String, dynamic>> signInWithGoogleAccessToken() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Sign in aborted by user'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Send the token to your backend - Updated to match backend expectations
      final response = await http.post(
        Uri.parse('$baseUrl/google-signin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'accessToken': googleAuth.accessToken, // Backend primarily uses accessToken
          'idToken': googleAuth.idToken, // Keep as fallback
          'userInfo': {
            'email': googleUser.email,
            'displayName': googleUser.displayName,
            'photoUrl': googleUser.photoUrl,
            'id': googleUser.id,
          }
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (responseData['data']?['token'] != null) {
          await storeToken(responseData['data']['token']);
        }
        if (responseData['data']?['user']?['_id'] != null) {
          await storeUserId(responseData['data']['user']['_id']);
        }
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Google sign-in failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      return {
        'success': false,
        'message': 'Google sign-in failed: ${e.toString()}',
        'error': 'unknown'
      };
    }
  }

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
    
    // Notify background service that user logged in
    BackgroundNotificationService.notifyUserChanged();
    
    // Refresh current user ID in post notification service after successful authentication
    try {
      await PostNotificationService.refreshCurrentUser();
      if (kDebugMode) print('✅ PostNotificationService refreshed after login');
    } catch (e) {
      if (kDebugMode) print('⚠️ Could not refresh PostNotificationService after login: $e');
    }
  }

  /// Store user ID
  Future<void> storeUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('USER_ID', userId);
    
    // Update socket service with new user ID
    try {
      await SocketService.instance.updateUserId(userId);
      if (kDebugMode) print('✅ SocketService updated with new user ID');
    } catch (e) {
      if (kDebugMode) print('⚠️ Could not update SocketService user ID: $e');
    }
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
    
    // Clear user data from post notification service
    try {
      PostNotificationService.clearUserData();
      if (kDebugMode) print('✅ PostNotificationService user data cleared');
    } catch (e) {
      if (kDebugMode) print('⚠️ Could not clear PostNotificationService data: $e');
    }
    
    // Clear user ID from socket service
    try {
      await SocketService.instance.updateUserId(null);
      if (kDebugMode) print('✅ SocketService user ID cleared');
    } catch (e) {
      if (kDebugMode) print('⚠️ Could not clear SocketService user ID: $e');
    }
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
          'message': responseData['message'] ?? 'Registration successful',
          'emailSent': responseData['emailSent'] ?? true
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
        // Call logout endpoint with proper Authorization header
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
      
      // Notify background service that user logged out
      BackgroundNotificationService.notifyUserChanged();
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
      ).timeout(const Duration(seconds: 10)); // Changed from 10 minutes to 10 seconds

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

  /// Send password reset email (sends PIN according to backend)
  Future<Map<String, dynamic>> sendResetPasswordEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Reset PIN sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send reset PIN',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'error': 'unknown'
      };
    }
  }

  /// Verify reset PIN (updated method name to be more accurate)
  Future<Map<String, dynamic>> verifyResetCode(String email, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset-pin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'pin': pin.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'PIN verified successfully',
          'resetToken': responseData['resetToken'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid or expired PIN',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'error': 'unknown'
      };
    }
  }

  /// Reset password with token
  Future<Map<String, dynamic>> resetPassword(String resetToken, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reset-password/$resetToken'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'password': newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Store the new token if provided
        if (responseData['data']?['token'] != null) {
          await storeToken(responseData['data']['token']);
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Password reset successful',
          'token': responseData['data']?['token'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to reset password',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'error': 'unknown'
      };
    }
  }

  /// Change password for logged in user (NEW METHOD)
  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final String? token = await getStoredToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'error': 'auth'
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to change password',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'error': 'unknown'
      };
    }
  }

  /// Verify email OTP code
  Future<Map<String, dynamic>> verifyEmailOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'otp': otp.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'error': 'unknown'
      };
    }
  }

  /// Resend email OTP
  Future<Map<String, dynamic>> resendEmailOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to resend code',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'error': 'unknown'
      };
    }
  }
}