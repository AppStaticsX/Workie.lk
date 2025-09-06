import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import '../services/auth_service.dart';

class ProfileService {
  static const String baseUrl = 'https://workie-lk-backend.onrender.com/api';
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB limit

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
      // Validate file size
      int fileSize = 0;
      if (imageFile != null) {
        fileSize = await imageFile.length();
      } else if (imageBytes != null) {
        fileSize = imageBytes.length;
      }

      if (fileSize > maxFileSize) {
        return {
          'success': false,
          'message': 'File size too large. Maximum allowed size is ${maxFileSize ~/ (1024 * 1024)}MB'
        };
      }

      if (fileSize == 0) {
        return {'success': false, 'message': 'No image provided or file is empty'};
      }

      final authService = AuthService();
      final token = await authService.getStoredToken();

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Authentication token not found'};
      }

      final dio = Dio();

      // Configure Dio with longer timeouts for file upload
      dio.options.connectTimeout = const Duration(seconds: 60);
      dio.options.receiveTimeout = const Duration(seconds: 60);
      dio.options.sendTimeout = const Duration(seconds: 60);

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

      // Detect MIME type
      String? mimeType;
      String contentType = 'image/jpeg'; // default

      if (imageFile != null) {
        mimeType = lookupMimeType(imageFile.path);
      } else if (imageBytes != null) {
        // Try to detect from bytes (basic detection)
        if (imageBytes.length > 3) {
          if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
            mimeType = 'image/jpeg';
          } else if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50 && imageBytes[2] == 0x4E && imageBytes[3] == 0x47) {
            mimeType = 'image/png';
          }
        }
      }

      if (mimeType != null) {
        contentType = mimeType;
      }

      FormData formData;

      if (kIsWeb && imageBytes != null) {
        formData = FormData.fromMap({
          'profilePicture': MultipartFile.fromBytes(
            imageBytes,
            filename: fileName,
            contentType: DioMediaType.parse(contentType),
          ),
        });
      } else if (imageFile != null) {
        formData = FormData.fromMap({
          'profilePicture': await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: DioMediaType.parse(contentType),
          ),
        });
      } else {
        return {'success': false, 'message': 'No image provided'};
      }

      final uploadUrl = '$baseUrl/media/profile-picture';
      if (kDebugMode) {
        print('Uploading to: $uploadUrl');
        print('Token: ${token.substring(0, 20)}...');
        print('Content Type: $contentType');
        print('File Size: ${fileSize} bytes');
      }

      final response = await dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        onSendProgress: (sent, total) {
          if (kDebugMode) {
            print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
          }
        },
      );

      if (kDebugMode) {
        print('Response received: ${response.statusCode}');
        print('Response data: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle the response structure from your backend
        String? profilePictureUrl;

        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;

          // Based on your backend, it returns: user.profilePicture
          if (data['user']?['profilePicture'] != null) {
            profilePictureUrl = data['user']['profilePicture'];
          }
        }

        return {
          'success': true,
          'data': response.data,
          'profilePictureUrl': profilePictureUrl,
          'message': 'Profile picture uploaded successfully!'
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Route not found. Please check if Cloudinary is configured on the backend.',
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
          'message': 'Upload endpoint not found. Please check if Cloudinary configuration exists on the backend.'
        };
      } else if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Please log in again.'
        };
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