import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class ProfileService {
  static const String baseUrl = 'https://workie-lk-backend.onrender.com/api';

  // Test if the backend server is running
  static Future<Map<String, dynamic>> testServerHealth() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get('$baseUrl/health');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Server returned ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Health check failed: $e'};
    }
  }

  // Test media route specifically
  static Future<Map<String, dynamic>> testMediaRoute() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get('$baseUrl/media/test');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Media route returned ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Media route test failed: $e'};
    }
  }

  // Upload profile picture to Cloudinary via your backend
  static Future<Map<String, dynamic>> uploadProfilePicture({
    File? imageFile,
    Uint8List? imageBytes,
    required String fileName,
  }) async {
    try {
      // First test if server is running
      if (kDebugMode) {
        print('Testing server health...');
        final healthResult = await testServerHealth();
        print('Health check result: $healthResult');

        print('Testing media route...');
        final mediaResult = await testMediaRoute();
        print('Media route test result: $mediaResult');
      }

      final authService = AuthService();
      final token = await authService.getStoredToken();

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Authentication token not found'};
      }

      // Test authentication
      final isAuth = await authService.isAuthenticated();
      if (!isAuth) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final dio = Dio();

      // Configure Dio with timeouts
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      // Add request interceptor for debugging
      if (kDebugMode) {
        dio.interceptors.add(InterceptorsWrapper(
          onRequest: (options, handler) {
            print('Request: ${options.method} ${options.uri}');
            print('Headers: ${options.headers}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            print('Response: ${response.statusCode}');
            print('Response data: ${response.data}');
            handler.next(response);
          },
          onError: (error, handler) {
            print('Error: ${error.type}');
            print('Error message: ${error.message}');
            print('Error response: ${error.response?.data}');
            handler.next(error);
          },
        ));
      }

      FormData formData;

      if (kIsWeb && imageBytes != null) {
        formData = FormData.fromMap({
          'profilePicture': MultipartFile.fromBytes(
            imageBytes,
            filename: fileName,
            contentType: DioMediaType('image', 'jpeg'),
          ),
        });
      } else if (imageFile != null) {
        formData = FormData.fromMap({
          'profilePicture': await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: DioMediaType('image', 'jpeg'),
          ),
        });
      } else {
        return {'success': false, 'message': 'No image provided'};
      }

      final uploadUrl = '$baseUrl/media/profile-picture';
      if (kDebugMode) {
        print('Uploading to: $uploadUrl');
        print('Token: ${token.substring(0, 20)}...');
      }

      final response = await dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'profilePictureUrl': response.data['user']['profilePicture'],
          'message': 'Profile picture uploaded successfully!'
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Route not found. Please check if the backend server is running.',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': response.data?['message'] ?? 'Upload failed',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Dio error: ${e.type}');
        print('Dio message: ${e.message}');
        print('Dio response: ${e.response?.data}');
        print('Dio response status: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 404) {
        return {
          'success': false,
          'message': 'Route not found. The backend server might not be running or the endpoint doesn\'t exist.'
        };
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {'success': false, 'message': 'Connection timeout. Please check your internet connection.'};
      } else if (e.type == DioExceptionType.connectionError) {
        return {'success': false, 'message': 'Cannot connect to server. Please check if the backend is running.'};
      } else {
        return {'success': false, 'message': 'Upload failed: ${e.message}'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Profile picture upload error: $e');
      }
      return {
        'success': false,
        'message': 'Unexpected error occurred: $e',
      };
    }
  }
}