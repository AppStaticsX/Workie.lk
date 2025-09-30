import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        // Decode JWT to get user ID
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
          );
          return payload['id'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to add comment');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add comment: ${response.statusCode}');
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

  /// Delete a post by postId
  static Future<Map<String, dynamic>> deletePost({
    required String postId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      final uri = Uri.parse('$baseUrl/posts/$postId');
      final response = await http.delete(
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
          throw Exception(data['message'] ?? 'Failed to delete post');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Post not found');
      } else if (response.statusCode == 403) {
        throw Exception('Not authorized to delete this post');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Convert backend post data to PostCardModel format
  static Future<Map<String, dynamic>> formatPostForWidget(Map<String, dynamic> backendPost) async {
    try {
      // Get current user ID
      final currentUserId = await getCurrentUserId();

      // Handle user info - check both userInfo and userId populated data
      final userInfo = backendPost['userInfo'] ?? {};
      final userId = backendPost['userId'];

      String firstName = '';
      String lastName = '';
      String email = '';
      String profilePicture = '';
      String userTitle = '';

      if (userInfo.isNotEmpty) {
        firstName = userInfo['firstName'] ?? '';
        lastName = userInfo['lastName'] ?? '';
        email = userInfo['email'] ?? '';
        profilePicture = userInfo['profilePicture'] ?? '';
        userTitle = userInfo['title'] ?? '';

        // Try to get title from userInfo profile
        if (userInfo['profile'] != null && userInfo['profile']['title'] != null) {
          userTitle = userInfo['profile']['title'];
        }
      } else if (userId != null && userId is Map) {
        firstName = userId['firstName'] ?? '';
        lastName = userId['lastName'] ?? '';
        email = userId['email'] ?? '';
        profilePicture = userId['profilePicture'] ?? '';

        // Try to get title from userId profile
        if (userId['profile'] != null && userId['profile']['title'] != null) {
          userTitle = userId['profile']['title'];
        }
      }

      // If title is still empty, try to get it from the post's profile data
      if (userTitle.isEmpty && backendPost['profile'] != null) {
        userTitle = backendPost['profile']['title'] ?? '';
      }

      // If title is still empty, try to get it from userProfile field
      if (userTitle.isEmpty && backendPost['userProfile'] != null) {
        userTitle = backendPost['userProfile']['title'] ?? '';
      }

      // Default title based on user type if still empty
      if (userTitle.isEmpty) {
        final userType = userInfo['userType'] ?? userId?['userType'];
        if (userType == 'worker') {
          userTitle = 'Skilled Worker';
        } else if (userType == 'employer') {
          userTitle = 'Employer';
        } else {
          userTitle = 'Workie User';
        }
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

      // Handle comments and check if current user commented
      final commentsList = backendPost['comments'] ?? [];
      List<Map<String, dynamic>> formattedComments = [];
      bool hasUserCommented = false;

      for (var comment in commentsList) {
        final commentUserInfo = comment['userInfo'] ?? {};
        final commentUserId = comment['userId'];

        // Check if this comment is by the current user
        if (currentUserId != null) {
          if (commentUserId != null && commentUserId.toString() == currentUserId.toString()) {
            hasUserCommented = true;
          } else if (commentUserInfo['userId'] != null &&
              commentUserInfo['userId'].toString() == currentUserId.toString()) {
            hasUserCommented = true;
          }
        }

        formattedComments.add({
          'userId': commentUserId, // Include userId in formatted comment
          'commentedUserProfileImgUrl': commentUserInfo['profilePicture'] ?? '',
          'commentedUserName': '${commentUserInfo['firstName'] ?? ''} ${commentUserInfo['lastName'] ?? ''}'.trim(),
          'comment': comment['comment'] ?? '',
          'ísVerified': false,
          'timestamp': _formatTimestamp(comment['commentedAt']),
          'userInfo': commentUserInfo, // Include full userInfo
        });
      }

      // Handle likes and check if current user liked
      final likesList = backendPost['likes'] ?? [];
      bool isLikedByCurrentUser = false;

      if (currentUserId != null && likesList.isNotEmpty) {
        isLikedByCurrentUser = likesList.any((like) =>
        like['userId'].toString() == currentUserId.toString()
        );
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
        'userTitle': userTitle,//'Professional Carpenter Specializing in Custom Furniture & Woodcraft',
        'timeAgo': _formatTimestamp(backendPost['createdAt']),
        'isVerified': true,
        'content': content,
        'mediaUrls': mediaItems,
        'hashtags': <String>['CustomFurniture', 'Woodworking', 'Woodcraft', 'CarpentryLife'],
        'initialLikeCount': backendPost['engagement']?['likesCount'] ?? backendPost['likes']?.length ?? 0,
        'commentCount': backendPost['engagement']?['commentsCount'] ?? backendPost['comments']?.length ?? 0,
        'shareCount': backendPost['engagement']?['sharesCount'] ?? backendPost['shares']?.length ?? 0,
        'comments': formattedComments,
        'isLikedByCurrentUser': isLikedByCurrentUser,
        'hasUserCommented': hasUserCommented, // Add this flag
        'likes': List<Map<String, dynamic>>.from(likesList),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting post: $e');
      }
      // Return a default formatted post in case of error
      return {
        'id': backendPost['_id'] ?? '',
        'profileImageUrl': 'https://via.placeholder.com/150',
        'userName': 'Unknown User',
        'userTitle': 'Professional Carpenter Specializing in Custom Furniture & Woodcraft',
        'timeAgo': '0m',
        'isVerified': true,
        'content': backendPost['content'] ?? 'No content',
        'mediaUrls': <MediaItem>[],
        'hashtags': <String>['CustomFurniture', 'Woodworking', 'Woodcraft', 'CarpentryLife'],
        'initialLikeCount': 0,
        'commentCount': 0,
        'shareCount': 0,
        'comments': <Map<String, dynamic>>[],
        'isLikedByCurrentUser': false,
        'hasUserCommented': false, // Add this
        'likes': <Map<String, dynamic>>[],
      };
    }
  }

  /// Format backend post data to PostCardModel format for saved posts (throws on error)
  static Future<Map<String, dynamic>> formatSavedPostForWidget(Map<String, dynamic> backendPost) async {
    try {
      // Validate that we have essential post data
      if (backendPost == null || backendPost.isEmpty) {
        throw Exception('Post data is null or empty');
      }

      if (backendPost['_id'] == null || backendPost['_id'].toString().isEmpty) {
        throw Exception('Post ID is missing or empty');
      }

      // Get current user ID
      final currentUserId = await getCurrentUserId();

      // Handle user info - check both userInfo and userId populated data
      final userInfo = backendPost['userInfo'] ?? {};
      final userId = backendPost['userId'];

      String firstName = '';
      String lastName = '';
      String email = '';
      String profilePicture = '';
      String userTitle = '';

      if (userInfo.isNotEmpty) {
        firstName = userInfo['firstName'] ?? '';
        lastName = userInfo['lastName'] ?? '';
        email = userInfo['email'] ?? '';
        profilePicture = userInfo['profilePicture'] ?? '';
        userTitle = userInfo['title'] ?? '';

        // Try to get title from userInfo profile
        if (userInfo['profile'] != null && userInfo['profile']['title'] != null) {
          userTitle = userInfo['profile']['title'];
        }
      } else if (userId != null && userId is Map) {
        firstName = userId['firstName'] ?? '';
        lastName = userId['lastName'] ?? '';
        email = userId['email'] ?? '';
        profilePicture = userId['profilePicture'] ?? '';

        // Try to get title from userId profile
        if (userId['profile'] != null && userId['profile']['title'] != null) {
          userTitle = userId['profile']['title'];
        }
      }

      // Validate that we have basic user info
      if (firstName.isEmpty && lastName.isEmpty && userInfo.isEmpty && userId == null) {
        throw Exception('No valid user information found in post');
      }

      // If title is still empty, try to get it from the post's profile data
      if (userTitle.isEmpty && backendPost['profile'] != null) {
        userTitle = backendPost['profile']['title'] ?? '';
      }

      // If title is still empty, try to get it from userProfile field
      if (userTitle.isEmpty && backendPost['userProfile'] != null) {
        userTitle = backendPost['userProfile']['title'] ?? '';
      }

      // Default title based on user type if still empty
      if (userTitle.isEmpty) {
        final userType = userInfo['userType'] ?? userId?['userType'];
        if (userType == 'worker') {
          userTitle = 'Skilled Worker';
        } else if (userType == 'employer') {
          userTitle = 'Employer';
        } else {
          userTitle = 'Workie User';
        }
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

      // Handle comments and check if current user commented
      final commentsList = backendPost['comments'] ?? [];
      List<Map<String, dynamic>> formattedComments = [];
      bool hasUserCommented = false;

      for (var comment in commentsList) {
        final commentUserInfo = comment['userInfo'] ?? {};
        final commentUserId = comment['userId'];

        // Check if this comment is by the current user
        if (currentUserId != null) {
          if (commentUserId != null && commentUserId.toString() == currentUserId.toString()) {
            hasUserCommented = true;
          } else if (commentUserInfo['userId'] != null &&
              commentUserInfo['userId'].toString() == currentUserId.toString()) {
            hasUserCommented = true;
          }
        }

        formattedComments.add({
          'userId': commentUserId,
          'commentedUserProfileImgUrl': commentUserInfo['profilePicture'] ?? '',
          'commentedUserName': '${commentUserInfo['firstName'] ?? ''} ${commentUserInfo['lastName'] ?? ''}'.trim(),
          'comment': comment['comment'] ?? '',
          'ísVerified': false,
          'timestamp': _formatTimestamp(comment['commentedAt']),
          'userInfo': commentUserInfo,
        });
      }

      // Handle likes and check if current user liked
      final likesList = backendPost['likes'] ?? [];
      bool isLikedByCurrentUser = false;

      if (currentUserId != null && likesList.isNotEmpty) {
        isLikedByCurrentUser = likesList.any((like) =>
        like['userId'].toString() == currentUserId.toString()
        );
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
        'userTitle': userTitle,
        'timeAgo': _formatTimestamp(backendPost['createdAt']),
        'isVerified': true,
        'content': content,
        'mediaUrls': mediaItems,
        'hashtags': hashtags.isNotEmpty ? hashtags : <String>['CustomFurniture', 'Woodworking', 'Woodcraft', 'CarpentryLife'],
        'initialLikeCount': backendPost['engagement']?['likesCount'] ?? backendPost['likes']?.length ?? 0,
        'commentCount': backendPost['engagement']?['commentsCount'] ?? backendPost['comments']?.length ?? 0,
        'shareCount': backendPost['engagement']?['sharesCount'] ?? backendPost['shares']?.length ?? 0,
        'comments': formattedComments,
        'isLikedByCurrentUser': isLikedByCurrentUser,
        'hasUserCommented': hasUserCommented,
        'likes': List<Map<String, dynamic>>.from(likesList),
      };
    } catch (e) {
      // Re-throw the exception instead of returning default template
      throw Exception('Failed to format saved post: $e');
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

  /// Search posts by content
  static Future<List<Map<String, dynamic>>> searchPostsByContent(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse('$baseUrl/posts/search?content=${Uri.encodeComponent(query)}');
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
          throw Exception(data['message'] ?? 'Failed to search posts');
        }
      } else {
        throw Exception('Failed to search posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get multiple posts by their IDs
  static Future<List<Map<String, dynamic>>> getPostsByIds(List<String> postIds) async {
    try {
      if (postIds.isEmpty) {
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      // Create a comma-separated string of post IDs
      final idsString = postIds.join(',');
      final uri = Uri.parse('$baseUrl/posts/batch?ids=$idsString');

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
          throw Exception(data['message'] ?? 'Failed to fetch posts by IDs');
        }
      } else if (response.statusCode == 404) {
        // If batch endpoint doesn't exist, return empty list
        // The caller can fall back to individual requests
        throw Exception('Batch endpoint not available');
      } else {
        throw Exception('Failed to fetch posts by IDs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get a single post by its ID
  static Future<Map<String, dynamic>?> getPostById(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      final uri = Uri.parse('$baseUrl/posts/$postId');
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
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch post');
        }
      } else if (response.statusCode == 404) {
        return null; // Post not found
      } else {
        throw Exception('Failed to fetch post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}