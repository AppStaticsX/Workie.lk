import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../secrets/app_secrets.dart';

class NicVerificationService {
  static const String baseUrl = '${SERVER.serverURL}/api'; // Update with your backend URL

  /// Upload NIC verification documents (front and back photos)
  static Future<Map<String, dynamic>> uploadNicDocuments({
    required File frontImage,
    required File backImage,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/media/verification-documents');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add files to request
      final frontFile = await http.MultipartFile.fromPath(
        'idPhotoFront',
        frontImage.path,
      );

      final backFile = await http.MultipartFile.fromPath(
        'idPhotoBack',
        backImage.path,
      );

      request.files.add(frontFile);
      request.files.add(backFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Documents uploaded successfully'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Upload failed',
          'error': responseData['error']
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString()
      };
    }
  }

  /// Upload single NIC document (either front or back)
  static Future<Map<String, dynamic>> uploadSingleNicDocument({
    required File image,
    required String documentType, // 'front' or 'back'
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/media/single-post-file');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add file to request
      final imageFile = await http.MultipartFile.fromPath(
        'postFile',
        image.path,
      );

      request.files.add(imageFile);

      // Add metadata
      request.fields['fileType'] = 'image';
      request.fields['folder'] = 'verification-documents';
      request.fields['documentType'] = documentType;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'url': responseData['url'],
          'publicId': responseData['public_id'],
          'message': responseData['message'] ?? 'Document uploaded successfully'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Upload failed',
          'error': responseData['error']
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString()
      };
    }
  }

  /// Verify NIC documents with backend validation
  /*static Future<Map<String, dynamic>> verifyNicDocuments({
    required String frontImageUrl,
    required String backImageUrl,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/nic-verification');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'idPhotoFrontUrl': frontImageUrl,
          'idPhotoBackUrl': backImageUrl,
          'verificationType': 'nic',
          'status': 'pending'
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'NIC verification submitted successfully'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Verification failed',
          'error': responseData['error']
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString()
      };
    }
  }*/

  /// Get verification status
  /*static Future<Map<String, dynamic>> getVerificationStatus({
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/verification-status');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Status retrieved successfully'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get status',
          'error': responseData['error']
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString()
      };
    }
  }*/
}