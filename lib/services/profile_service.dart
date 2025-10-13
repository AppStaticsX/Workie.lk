import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../secrets/app_secrets.dart';

class ProfileService {
  static const String _baseUrl = SERVER.serverURL;
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

  // Generic HTTP request helper
  static Future<Map<String, dynamic>?> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token == null) {
          throw Exception('Authentication token not found');
        }
      }

      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (requiresAuth) 'Authorization': 'Bearer ${await _getAuthToken()}',
      };

      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: json.encode(body));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: json.encode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Request failed');
      }
    } catch (e) {
      if (kDebugMode) print('HTTP request error: $e');
      return null;
    }
  }

  // Upload profile picture to Cloudinary
  static Future<Map<String, dynamic>?> uploadProfilePicture({
    File? imageFile,
    Uint8List? imageBytes,
    required String fileName,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      if (imageFile == null && imageBytes == null) {
        throw Exception('No image provided');
      }

      final uri = Uri.parse('$_baseUrl/api/media/profile-picture');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      // Add the image file based on platform
      if (kIsWeb && imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'profilePicture',
          imageBytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (response.statusCode == 200) {
        if (kDebugMode) print('Profile picture upload response: $responseData');
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to upload profile picture');
      }
    } catch (e) {
      if (kDebugMode) print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Upload cover photo to Cloudinary
  static Future<Map<String, dynamic>?> uploadCoverPhoto({
    File? imageFile,
    Uint8List? imageBytes,
    required String fileName,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      if (imageFile == null && imageBytes == null) {
        throw Exception('No image provided');
      }

      final uri = Uri.parse('$_baseUrl/api/media/cover-photo');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      // Add the image file based on platform
      if (kIsWeb && imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'coverPhoto',
          imageBytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'coverPhoto',
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (response.statusCode == 200) {
        if (kDebugMode) print('Cover photo upload response: $responseData');
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to upload cover photo');
      }
    } catch (e) {
      if (kDebugMode) print('Error uploading cover photo: $e');
      return null;
    }
  }

  // Calculate age from date of birth
  static int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    
    // Check if birthday hasn't occurred this year yet
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    
    // Ensure age is within valid range (18-100 as per backend model)
    return age.clamp(18, 100);
  }

  // Save personal details to profile and upload profile picture if provided
  static Future<Map<String, dynamic>?> savePersonalDetailsToProfile({
    required String userId,
    required DateTime dateOfBirth,
    required String streetAddress,
    required String city,
    required String postalCode,
    required String phoneNumber,
    required String province,
    File? profileImage,
    Uint8List? profileImageBytes,
    String? apartmentOrSuite,
  }) async {
    try {
      String? profilePictureUrl;
      // Upload profile picture if provided
      if (profileImage != null || profileImageBytes != null) {
        final uploadResult = await uploadProfilePicture(
          imageFile: profileImage,
          imageBytes: profileImageBytes,
          fileName: 'profile_picture_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        if (uploadResult != null && uploadResult['user']?['profilePicture'] != null) {
          profilePictureUrl = uploadResult['user']['profilePicture'];
        }
      }

      // Format phone number as +94XXXXXXXXX (no spaces)
      String formattedPhone = phoneNumber.trim().replaceAll(' ', '');
      if (!formattedPhone.startsWith('+94')) {
        // Remove leading 0 if present and add +94
        if (formattedPhone.startsWith('0')) {
          formattedPhone = '+94${formattedPhone.substring(1)}';
        } else if (!formattedPhone.startsWith('+')) {
          formattedPhone = '+94$formattedPhone';
        }
      }

      // Update profile fields
      final calculatedAge = _calculateAge(dateOfBirth);
      final profileData = {
        'dateOfBirth': dateOfBirth.toIso8601String().split('T')[0],
        'age': calculatedAge,
        'country': 'Sri Lanka',
        'streetAddress': streetAddress,
        'city': city,
        'province': province,
        'postalCode': postalCode,
        'phone': formattedPhone,
      };

      final profileResult = await _makeRequest(
        method: 'PUT',
        endpoint: '/api/profiles/$userId',
        body: profileData,
      );

      // Update user fields (phone, profilePicture, address)
      final userData = <String, dynamic>{
        'phone': formattedPhone,
        'address': {
          'street': streetAddress,
          'city': city,
          'state': province,
          'zipCode': postalCode,
          'country': 'Sri Lanka',
        },
      };
      
      if (profilePictureUrl != null) {
        userData['profilePicture'] = profilePictureUrl;
      }

      final userResult = await _makeRequest(
        method: 'PUT',
        endpoint: '/api/users/$userId',
        body: userData,
      );

      // Check if user update was successful
      if (userResult == null || userResult['success'] == false) {
        final errorMsg = userResult?['message'] ?? 'Failed to update user info.';
        if (kDebugMode) {
          print('User update failed: $errorMsg');
        }
        throw Exception(errorMsg);
      }

      // Return both results for reference
      return {
        'profile': profileResult,
        'user': userResult,
      };
    } catch (e) {
      if (kDebugMode) print('Error saving personal details: $e');
      return null;
    }
  }

  // Validate required fields before submission
  static bool validateProfileData({
    required String dateOfBirth,
    required String streetAddress,
    required String city,
    required String stateOrProvince,
    required String postalCode,
    required String phoneNumber,
    File? profileImage,
    Uint8List? profileImageBytes,
  }) {
    final requiredFields = [
      dateOfBirth,
      streetAddress,
      city,
      stateOrProvince,
      postalCode,
      phoneNumber,
    ];

    // Check if any required field is empty
    if (requiredFields.any((field) => field.isEmpty)) {
      return false;
    }

    // Check if profile image is provided
    return profileImage != null || profileImageBytes != null;
  }
}