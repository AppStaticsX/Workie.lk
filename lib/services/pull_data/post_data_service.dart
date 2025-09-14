import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/media_item_model.dart';

class PostDataService {
  static const String baseUrl = 'https://workie-lk-backend.onrender.com/api';

  /// Get feed posts for home page
  static Future<List<Map<String, dynamic>>> getFeedPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse('$baseUrl/posts/feed?page=$page&limit=$limit');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch posts');
        }
      } else {
        throw Exception('Failed to fetch posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get posts by specific user
  static Future<List<Map<String, dynamic>>> getUserPosts({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      final uri = Uri.parse('$baseUrl/posts/user/$userId?page=$page&limit=$limit');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch user posts');
        }
      } else {
        throw Exception('Failed to fetch user posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get video posts for video feed
  static Future<List<Map<String, dynamic>>> getVideoPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/posts/videos?page=$page&limit=$limit');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch video posts');
        }
      } else {
        throw Exception('Failed to fetch video posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Like or unlike a post
  static Future<Map<String, dynamic>> toggleLike({
    required String postId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      final uri = Uri.parse('$baseUrl/posts/$postId/like');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to toggle like');
        }
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Add comment to a post
  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String comment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      final uri = Uri.parse('$baseUrl/posts/$postId/comments');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to add comment');
        }
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get comments for a post
  static Future<List<Map<String, dynamic>>> getComments({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/posts/$postId/comments?page=$page&limit=$limit');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null && data['data']['comments'] != null) {
          return List<Map<String, dynamic>>.from(data['data']['comments']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch comments');
        }
      } else {
        throw Exception('Failed to fetch comments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Convert backend post data to PostCardModel format
  static Map<String, dynamic> formatPostForWidget(Map<String, dynamic> backendPost) {
    try {
      // Handle user info - check both userInfo and userId populated data
      final userInfo = backendPost['userInfo'] ?? {};
      final userId = backendPost['userId'];

      String firstName = '';
      String lastName = '';
      String email = '';
      String profilePicture = '';

      if (userInfo.isNotEmpty) {
        firstName = userInfo['firstName'] ?? '';
        lastName = userInfo['lastName'] ?? '';
        email = userInfo['email'] ?? '';
        profilePicture = userInfo['profilePicture'] ?? '';
      } else if (userId != null && userId is Map) {
        firstName = userId['firstName'] ?? '';
        lastName = userId['lastName'] ?? '';
        email = userId['email'] ?? '';
        profilePicture = userId['profilePicture'] ?? '';
      }

      // Handle media
      final mediaList = backendPost['media'] ?? [];
      List<MediaItem> mediaItems = [];

      for (var media in mediaList) {
        final mediaType = media['fileType'] == 'video' ? MediaType.video : MediaType.image;
        mediaItems.add(MediaItem(
          url: media['url'] ?? media['secureUrl'] ?? '',
          type: mediaType,
        ));
      }

      // Handle comments
      final commentsList = backendPost['comments'] ?? [];
      List<Map<String, dynamic>> formattedComments = [];

      for (var comment in commentsList) {
        final commentUserInfo = comment['userInfo'] ?? {};
        formattedComments.add({
          'commentedUserProfileImgUrl': commentUserInfo['profilePicture'] ?? '',
          'commentedUserName': '${commentUserInfo['firstName'] ?? ''} ${commentUserInfo['lastName'] ?? ''}'.trim(),
          'comment': comment['comment'] ?? '',
          'ísVerified': false, // You can add verification logic here
          'timestamp': _formatTimestamp(comment['commentedAt']),
        });
      }

      // Handle hashtags
      List<String> hashtags = [];
      final content = backendPost['content'] ?? '';
      final hashtagRegex = RegExp(r'#\w+');
      final matches = hashtagRegex.allMatches(content);
      for (var match in matches) {
        hashtags.add(match.group(0)!);
      }

      return {
        'id': backendPost['_id'] ?? '',
        'profileImageUrl': profilePicture.isNotEmpty
            ? profilePicture
            : 'https://via.placeholder.com/150',
        'userName': '$firstName $lastName'.trim().isNotEmpty
            ? '$firstName $lastName'.trim()
            : 'Unknown User',
        'userTitle': 'Professional Carpenter Specializing in Custom Furniture & Woodcraft', // You can get this from user profile later
        'timeAgo': _formatTimestamp(backendPost['createdAt']),
        'isVerified': true, // You can add verification logic here
        'content': content,
        'mediaUrls': mediaItems,
        'hashtags': <String>['CustomFurniture', 'Woodworking', 'Woodcraft', 'CarpentryLife'],
        'initialLikeCount': backendPost['engagement']?['likesCount'] ?? backendPost['likes']?.length ?? 0,
        'commentCount': backendPost['engagement']?['commentsCount'] ?? backendPost['comments']?.length ?? 0,
        'shareCount': backendPost['engagement']?['sharesCount'] ?? backendPost['shares']?.length ?? 0,
        'comments': formattedComments,
      };
    } catch (e) {
      print('Error formatting post: $e');
      // Return a default formatted post in case of error
      return {
        'id': backendPost['_id'] ?? '',
        'profileImageUrl': 'https://via.placeholder.com/150',
        'userName': 'Unknown User',
        'userTitle': 'Worker',
        'timeAgo': '0m',
        'isVerified': true,
        'content': backendPost['content'] ?? 'No content',
        'mediaUrls': <MediaItem>[],
        'hashtags': <String>['CustomFurniture', 'Woodworking', 'Woodcraft', 'CarpentryLife'],
        'initialLikeCount': 0,
        'commentCount': 0,
        'shareCount': 0,
        'comments': <Map<String, dynamic>>[],
      };
    }
  }

  /// Format timestamp to relative time
  static String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return '0m';

      DateTime dateTime;
      if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return '0m';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return '1m';
      }
    } catch (e) {
      return '0m';
    }
  }
}