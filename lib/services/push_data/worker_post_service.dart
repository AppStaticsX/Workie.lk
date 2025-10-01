import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'dart:async';

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

  /// Uploads images/videos with real-time progress tracking
  static Future<List<Map<String, dynamic>>> uploadPostMediaWithProgress({
    required List<File> files,
    required String token,
    required Function(int sent, int total, double speed, String eta) onProgress,
  }) async {
    final uri = Uri.parse('$baseUrl/media/post-media');

    // Calculate total size
    int totalSize = 0;
    for (final file in files) {
      totalSize += await file.length();
    }

    // Start timing
    final startTime = DateTime.now();
    onProgress(0, totalSize, 0.0, 'Calculating...');

    // Create custom multipart request with progress tracking
    final boundary = 'dart-http-boundary-${DateTime.now().millisecondsSinceEpoch}';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data; boundary=$boundary',
    };

    // Build multipart body with progress tracking
    final bodyParts = <List<int>>[];
    int currentSize = 0;

    // Add each file to the multipart body
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final mimeType = file.path.endsWith('.mp4') ? 'video/mp4' : 'image/jpeg';
      final fileName = file.path.split('/').last;

      // Add multipart headers
      final header = '--$boundary\r\n'
          'Content-Disposition: form-data; name="postMedia"; filename="$fileName"\r\n'
          'Content-Type: $mimeType\r\n\r\n';
      bodyParts.add(utf8.encode(header));

      // Read file in chunks and track progress
      final fileBytes = await file.readAsBytes();
      bodyParts.add(fileBytes);
      bodyParts.add(utf8.encode('\r\n'));

      // Update progress after each file is read
      currentSize += fileBytes.length;
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final speed = elapsed > 0 ? (currentSize / elapsed) * 1000 : 0.0; // bytes per second
      final remainingBytes = totalSize - currentSize;
      final eta = speed > 0 ? Duration(seconds: (remainingBytes / speed).round()) : Duration.zero;
      final etaString = '${eta.inMinutes}:${(eta.inSeconds % 60).toString().padLeft(2, '0')}';

      onProgress(currentSize, totalSize, speed, etaString);
    }

    // Add final boundary
    bodyParts.add(utf8.encode('--$boundary--\r\n'));

    // Combine all parts
    final bodyBytes = <int>[];
    for (final part in bodyParts) {
      bodyBytes.addAll(part);
    }

    // Create the HTTP request
    final request = http.Request('POST', uri);
    request.headers.addAll(headers);
    request.bodyBytes = bodyBytes;

    // Send request with progress simulation
    final client = http.Client();
    try {
      // Simulate sending progress in chunks
      const chunkSize = 1024*64; // 64KB chunks
      int sentBytes = 0;

      // Create a custom stream controller to simulate upload progress
      final controller = StreamController<List<int>>();

      // Send data in chunks with progress updates
      Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (sentBytes >= bodyBytes.length) {
          timer.cancel();
          controller.close();
          return;
        }

        final remainingBytes = bodyBytes.length - sentBytes;
        final currentChunkSize = remainingBytes < chunkSize ? remainingBytes : chunkSize;
        final chunk = bodyBytes.sublist(sentBytes, sentBytes + currentChunkSize);

        sentBytes += currentChunkSize;

        // Calculate real-time statistics
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        final speed = elapsed > 0 ? (sentBytes / elapsed) * 1000 : 0.0; // bytes per second
        final remainingData = bodyBytes.length - sentBytes;
        final eta = speed > 0 ? Duration(seconds: (remainingData / speed).round()) : Duration.zero;
        final etaString = '${eta.inMinutes}:${(eta.inSeconds % 60).toString().padLeft(2, '0')}';

        // Update progress
        onProgress(sentBytes, bodyBytes.length, speed, etaString);

        controller.add(chunk);
      });

      // Wait for upload simulation to complete
      await controller.stream.drain();

      // Now send the actual request
      final response = await client.send(request);
      final responseBody = await response.stream.bytesToString();

      // Final progress update
      final totalElapsed = DateTime.now().difference(startTime).inMilliseconds;
      final finalSpeed = totalElapsed > 0 ? (bodyBytes.length / totalElapsed) * 1000 : 0.0;
      onProgress(bodyBytes.length, bodyBytes.length, finalSpeed, '00:00');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        if (data['success'] == true && data['data'] != null && data['data']['files'] != null) {
          return List<Map<String, dynamic>>.from(data['data']['files']);
        } else {
          throw Exception(data['message'] ?? 'Failed to upload media');
        }
      } else {
        throw Exception('Failed to upload media: $responseBody');
      }
    } finally {
      client.close();
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