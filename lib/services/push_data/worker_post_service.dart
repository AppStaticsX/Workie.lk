import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class WorkerPostService {
  static const String baseUrl = 'https://workie-lk-backend.onrender.com/api'; // Change to your backend URL

  /// Uploads images/videos to the backend and returns the uploaded file info.
  static Future<List<Map<String, dynamic>>> uploadPostMedia({
    required List<File> files,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/media/post-media');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    for (final file in files) {
      final mimeType = file.path.endsWith('.mp4') ? 'video/mp4' : 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'postMedia',
          file.path,
          contentType: mimeType == 'video/mp4'
              ? MediaType('video', 'mp4')
              : MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null && data['data']['files'] != null) {
        return List<Map<String, dynamic>>.from(data['data']['files']);
      } else {
        throw Exception(data['message'] ?? 'Failed to upload media');
      }
    } else {
      throw Exception('Failed to upload media: ${response.body}');
    }
  }

  /// Creates a new post with content and media info.
  static Future<Map<String, dynamic>> createPost({
    required String token,
    required String content,
    required List<Map<String, dynamic>> media,
    List<String>? hashtags,
    String? privacy,
    String? location,
    List<String>? taggedUsers,
  }) async {
    final uri = Uri.parse('$baseUrl/posts');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content': content,
        'media': media,
        'hashtags': hashtags ?? [],
        'privacy': privacy ?? 'public',
        'location': location ?? '',
        'taggedUsers': taggedUsers ?? [],
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 201 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to create post');
    }
  }
}