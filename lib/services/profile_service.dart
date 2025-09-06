import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class ProfileService {
  static const String baseUrl = 'https://workie-lk-backend.onrender.com/api'; // Using your existing backend URL

  // Upload profile picture to Cloudinary via your backend
  static Future<Map<String, dynamic>> uploadProfilePicture({
    File? imageFile,
    Uint8List? imageBytes,
    required String fileName,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getStoredToken(); // Use getStoredToken instead of getToken

      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final dio = Dio();

      FormData formData;

      if (kIsWeb && imageBytes != null) {
        // For web platform
        formData = FormData.fromMap({
          'profilePicture': MultipartFile.fromBytes(
            imageBytes,
            filename: fileName,
            contentType: DioMediaType.parse('image/jpeg'),
          ),
        });
      } else if (imageFile != null) {
        // For mobile platforms
        formData = FormData.fromMap({
          'profilePicture': await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
          ),
        });
      } else {
        return {'success': false, 'message': 'No image provided'};
      }

      final response = await dio.post(
        '$baseUrl/media/profile-picture',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'profilePictureUrl': response.data['user']['profilePicture'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Upload failed',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Profile picture upload error: $e');
      }
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  // Save complete profile data
  static Future<Map<String, dynamic>> saveCompleteProfile({
    required String profilePictureUrl,
    required String birthDate,
    required String streetAddress,
    String? apartmentSuite,
    required String city,
    required String stateProvince,
    required String postalCode,
    required String phoneNumber,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getStoredToken(); // Use getStoredToken

      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'profilePicture': profilePictureUrl,
          'dateOfBirth': birthDate,
          'address': {
            'street': streetAddress,
            'apartment': apartmentSuite,
            'city': city,
            'state': stateProvince,
            'postalCode': postalCode,
          },
          'phoneNumber': phoneNumber,
          'profileCompleted': true,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
          'message': 'Profile saved successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to save profile',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Profile save error: $e');
      }
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  // Combined method to upload image and save complete profile
  static Future<Map<String, dynamic>> completeProfileSetup({
    File? imageFile,
    Uint8List? imageBytes,
    required String fileName,
    required String birthDate,
    required String streetAddress,
    String? apartmentSuite,
    required String city,
    required String stateProvince,
    required String postalCode,
    required String phoneNumber,
  }) async {
    try {
      // Step 1: Upload profile picture
      final uploadResult = await uploadProfilePicture(
        imageFile: imageFile,
        imageBytes: imageBytes,
        fileName: fileName,
      );

      if (!uploadResult['success']) {
        return uploadResult;
      }

      final profilePictureUrl = uploadResult['profilePictureUrl'];

      // Step 2: Save complete profile
      final saveResult = await saveCompleteProfile(
        profilePictureUrl: profilePictureUrl,
        birthDate: birthDate,
        streetAddress: streetAddress,
        apartmentSuite: apartmentSuite,
        city: city,
        stateProvince: stateProvince,
        postalCode: postalCode,
        phoneNumber: phoneNumber,
      );

      return saveResult;
    } catch (e) {
      if (kDebugMode) {
        print('Complete profile setup error: $e');
      }
      return {
        'success': false,
        'message': 'Failed to complete profile setup',
      };
    }
  }
}