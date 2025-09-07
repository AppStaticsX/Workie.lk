import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String baseUrl = 'https://workie-lk-backend.onrender.com';

  // Get auth token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth token: $e');
      }
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

      final uri = Uri.parse('$baseUrl/api/media/profile-picture');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add the image file
      if (kIsWeb && imageBytes != null) {
        // For web platform
        request.files.add(http.MultipartFile.fromBytes(
          'profilePicture',
          imageBytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else if (imageFile != null) {
        // For mobile platforms
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        throw Exception('No image provided');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Profile picture upload response: $responseData');
        }
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to upload profile picture');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile picture: $e');
      }
      return null;
    }
  }

  // Create or update user profile
  static Future<Map<String, dynamic>?> createOrUpdateProfile({
    required String userId,
    required String dateOfBirth,
    required String streetAddress,
    required String city,
    required String stateOrProvince,
    required String postalCode,
    required String phoneNumber,
    String? apartmentOrSuite,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/api/profiles/$userId');

      final profileData = {
        'personalInfo': {
          'dateOfBirth': dateOfBirth,
          'phoneNumber': phoneNumber,
        },
        'address': {
          'streetAddress': streetAddress,
          'apartmentOrSuite': apartmentOrSuite,
          'city': city,
          'stateOrProvince': stateOrProvince,
          'postalCode': postalCode,
        },
        'isProfileComplete': true,
        'profileCompletedAt': DateTime.now().toIso8601String(),
      };

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(profileData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      return null;
    }
  }

  // Update user personal information (WITHOUT touching profile picture fields)
  static Future<Map<String, dynamic>?> updateUserInfo({
    required String userId,
    required String phoneNumber,
    required Map<String, String> address,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/api/users/$userId');

      final userData = {
        'phone': phoneNumber,
        'address': address,
      };
      // DO NOT include profilePicture or profilePicturePublicId here
      // as they are already correctly saved by the media upload route

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(userData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update user info');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user info: $e');
      }
      return null;
    }
  }

  // Complete profile setup
  static Future<bool> completeProfileSetup({
    required String userId,
    required String dateOfBirth,
    required String streetAddress,
    required String city,
    required String stateOrProvince,
    required String postalCode,
    required String phoneNumber,
    String? apartmentOrSuite,
    File? profileImage,
    Uint8List? profileImageBytes,
  }) async {
    try {
      // Step 1: Upload profile picture if provided
      // This already saves both profilePicture and profilePicturePublicId to the User document
      if (profileImage != null || profileImageBytes != null) {
        if (kDebugMode) {
          print('Uploading profile picture...');
        }

        final uploadResult = await uploadProfilePicture(
          imageFile: profileImage,
          imageBytes: profileImageBytes,
          fileName: 'profile_picture_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        if (uploadResult != null && uploadResult['message'] != null) {
          if (uploadResult['message'].toString().contains('successfully')) {
            if (kDebugMode) {
              print('Profile picture uploaded successfully');
              print('URL: ${uploadResult['user']?['profilePicture']}');
              print('Public ID: ${uploadResult['user']?['profilePicturePublicId']}');
            }
          }
        } else {
          if (kDebugMode) {
            print('Failed to upload profile picture');
          }
          // Continue even if profile picture upload fails
        }
      }

      // Step 2: Update user information (WITHOUT profile picture data)
      if (kDebugMode) {
        print('Updating user information...');
      }

      final userUpdateResult = await updateUserInfo(
        userId: userId,
        phoneNumber: phoneNumber,
        address: {
          'streetAddress': streetAddress,
          'apartmentOrSuite': apartmentOrSuite ?? '',
          'city': city,
          'stateOrProvince': stateOrProvince,
          'postalCode': postalCode,
        },
      );

      if (userUpdateResult == null || userUpdateResult['success'] != true) {
        throw Exception('Failed to update user information');
      }

      // Step 3: Create or update profile
      if (kDebugMode) {
        print('Creating/updating profile...');
      }

      final profileUpdateResult = await createOrUpdateProfile(
        userId: userId,
        dateOfBirth: dateOfBirth,
        streetAddress: streetAddress,
        city: city,
        stateOrProvince: stateOrProvince,
        postalCode: postalCode,
        phoneNumber: phoneNumber,
        apartmentOrSuite: apartmentOrSuite,
      );

      if (profileUpdateResult == null || profileUpdateResult['success'] != true) {
        throw Exception('Failed to create/update profile');
      }

      // Step 4: Clear local storage after successful completion
      try {
        await clearProfileSetupData();
        if (kDebugMode) {
          print('Local profile setup data cleared');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Failed to clear local data: $e');
        }
      }

      if (kDebugMode) {
        print('Profile setup completed successfully!');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error completing profile setup: $e');
      }
      return false;
    }
  }

  // Get current user ID from SharedPreferences
  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('USER_ID');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user ID: $e');
      }
      return null;
    }
  }

  // Clear profile setup data after completion
  static Future<void> clearProfileSetupData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_setup_temp_data');
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing profile setup data: $e');
      }
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
    if (dateOfBirth.isEmpty ||
        streetAddress.isEmpty ||
        city.isEmpty ||
        stateOrProvince.isEmpty ||
        postalCode.isEmpty ||
        phoneNumber.isEmpty) {
      return false;
    }

    if (profileImage == null && profileImageBytes == null) {
      return false;
    }

    return true;
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _getAuthToken();
    return token != null && token.isNotEmpty;
  }
}