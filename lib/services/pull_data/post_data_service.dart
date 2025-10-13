import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../socket_service.dart';
import '../../models/media_item_model.dart';
import 'get_user_data.dart';

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

      // Emit optimistic update via socket if connected
      final socketService = SocketService.instance;
      final currentUserId = await getCurrentUserId();
      
      if (socketService.isConnected && currentUserId != null) {
        // We could emit a local optimistic update here if needed
        if (kDebugMode) {
          print('📱 Sending like update for post: $postId via socket');
        }
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
          if (kDebugMode) {
            print('✅ Like toggle successful for post: $postId');
          }
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to toggle like');
        }
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling like: $e');
      }
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

      // Log comment submission via socket if connected
      final socketService = SocketService.instance;
      final currentUserId = await getCurrentUserId();
      
      if (socketService.isConnected && currentUserId != null) {
        if (kDebugMode) {
          print('📱 Sending comment for post: $postId via socket');
        }
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
          if (kDebugMode) {
            print('✅ Comment added successfully for post: $postId');
          }
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to add comment');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding comment: $e');
      }
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
  static Future<Map<String, dynamic>> formatPostForWidget(Map<String, dynamic> backendPost) async {
    try {
      // Validate essential post data
      if (backendPost['_id'] == null) {
        throw Exception('Invalid post data: missing post ID');
      }
      
      final postId = backendPost['_id'].toString();
      if (kDebugMode) {
        print('📝 Formatting post for widget: $postId');
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

      // Get content
      final content = backendPost['content'] ?? '';
      
      // Handle hashtags - use hashtags from database if available
      List<String> hashtags = [];
      
      // First check if hashtags are provided directly from the database
      if (backendPost['hashtags'] != null && backendPost['hashtags'] is List) {
        hashtags = List<String>.from(backendPost['hashtags']);
      } else {
        // Fallback to extracting hashtags from content
        final hashtagRegex = RegExp(r'#\w+');
        final matches = hashtagRegex.allMatches(content);
        for (var match in matches) {
          hashtags.add(match.group(0)!);
        }
      }

      final userData = await GetUserDataService.getCurrentUserData();

      final formattedPost = {
        'id': backendPost['_id'] ?? '',
        'profileImageUrl': profilePicture.isNotEmpty
            ? profilePicture
            : 'https://via.placeholder.com/150',
        'userName': '$firstName $lastName'.trim().isNotEmpty
            ? '$firstName $lastName'.trim()
            : 'Unknown User',
        'userTitle': userTitle,//'Professional Carpenter Specializing in Custom Furniture & Woodcraft',
        'timeAgo': _formatTimestamp(backendPost['createdAt']),
        'isVerified': userData?.isVerified,
        'content': content,
        'mediaUrls': mediaItems,
        'hashtags': hashtags,
        'initialLikeCount': backendPost['engagement']?['likesCount'] ?? backendPost['likes']?.length ?? 0,
        'commentCount': backendPost['engagement']?['commentsCount'] ?? backendPost['comments']?.length ?? 0,
        'shareCount': backendPost['engagement']?['sharesCount'] ?? backendPost['shares']?.length ?? 0,
        'comments': formattedComments,
        'isLikedByCurrentUser': isLikedByCurrentUser,
        'hasUserCommented': hasUserCommented, // Add this flag
        'likes': List<Map<String, dynamic>>.from(likesList),
      };
      
      // Validate formatted post ID
      if (formattedPost['id'] == null || formattedPost['id'].toString().isEmpty) {
        throw Exception('Formatted post missing valid ID');
      }
      
      if (kDebugMode) {
        print('✅ Successfully formatted post: ${formattedPost['id']}');
      }
      
      return formattedPost;
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
        'hashtags': <String>[],
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
      if (backendPost.isEmpty) {
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

      // Get content
      final content = backendPost['content'] ?? '';
      
      // Handle hashtags - use hashtags from database if available
      List<String> hashtags = [];
      
      // First check if hashtags are provided directly from the database
      if (backendPost['hashtags'] != null && backendPost['hashtags'] is List) {
        hashtags = List<String>.from(backendPost['hashtags']);
      } else {
        // Fallback to extracting hashtags from content
        final hashtagRegex = RegExp(r'#\w+');
        final matches = hashtagRegex.allMatches(content);
        for (var match in matches) {
          hashtags.add(match.group(0)!);
        }
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
        'hashtags': hashtags,
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

  /// Update/Edit a post
  static Future<Map<String, dynamic>> updatePost({
    required String postId,
    String? content,
    List<Map<String, dynamic>>? media,
    List<String>? hashtags,
    String? privacy,
    String? location,
    List<String>? taggedUsers,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      // Log post update via socket if connected
      final socketService = SocketService.instance;
      final currentUserId = await getCurrentUserId();
      
      if (socketService.isConnected && currentUserId != null) {
        if (kDebugMode) {
          print('📱 Sending post update for: $postId via socket');
        }
      }

      final uri = Uri.parse('$baseUrl/posts/$postId');
      final body = <String, dynamic>{};
      
      if (content != null) body['content'] = content;
      if (media != null) body['media'] = media;
      if (hashtags != null) body['hashtags'] = hashtags;
      if (privacy != null) body['privacy'] = privacy;
      if (location != null) body['location'] = location;
      if (taggedUsers != null) body['taggedUsers'] = taggedUsers;

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          if (kDebugMode) {
            print('✅ Post update successful for: $postId');
          }
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to update post');
        }
      } else {
        throw Exception('Failed to update post: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating post: $e');
      }
      throw Exception('Network error: $e');
    }
  }

  /// Delete a post
  static Future<Map<String, dynamic>> deletePost({
    required String postId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      // Log post deletion via socket if connected
      final socketService = SocketService.instance;
      final currentUserId = await getCurrentUserId();
      
      if (socketService.isConnected && currentUserId != null) {
        if (kDebugMode) {
          print('📱 Sending post deletion for: $postId via socket');
        }
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
          if (kDebugMode) {
            print('✅ Post deletion successful for: $postId');
          }
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to delete post');
        }
      } else {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting post: $e');
      }
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
          return Map<String, dynamic>.from(data['data']);
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

  /// Extract user ID from post data
  static String? getUserIdFromPostData(Map<String, dynamic> postData) {
    try {
      // Check different possible fields for user ID
      if (postData['userId'] != null) {
        // If userId is a string or object with _id
        if (postData['userId'] is String) {
          return postData['userId'];
        } else if (postData['userId'] is Map && postData['userId']['_id'] != null) {
          return postData['userId']['_id'].toString();
        }
      }

      // Check userInfo field
      if (postData['userInfo'] != null && postData['userInfo']['userId'] != null) {
        return postData['userInfo']['userId'].toString();
      }

      // Check if there's a direct _id in userInfo
      if (postData['userInfo'] != null && postData['userInfo']['_id'] != null) {
        return postData['userInfo']['_id'].toString();
      }

      // Check author field (sometimes posts might have this)
      if (postData['author'] != null) {
        if (postData['author'] is String) {
          return postData['author'];
        } else if (postData['author'] is Map && postData['author']['_id'] != null) {
          return postData['author']['_id'].toString();
        }
      }

      if (kDebugMode) {
        print('⚠️ Could not extract user ID from post data');
        print('Available keys: ${postData.keys.toList()}');
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error extracting user ID from post data: $e');
      }
      return null;
    }
  }

  /// Get user profile data by user ID and extract title
  static Future<String?> getUserTitleByUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (kDebugMode) {
          print('❌ Authentication token not found');
        }
        return null;
      }

      final uri = Uri.parse('$baseUrl/profiles/$userId');
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
          final profileData = data['data'];
          
          // Extract title from profile data
          String? title;
          
          // Check direct title field
          if (profileData['title'] != null && profileData['title'].toString().isNotEmpty) {
            title = profileData['title'].toString();
          }
          
          // Check profile object within profile data
          else if (profileData['profile'] != null && profileData['profile']['title'] != null) {
            title = profileData['profile']['title'].toString();
          }
          
          if (kDebugMode) {
            print('✅ Retrieved title for user $userId: $title');
          }
          
          return title;
        } else {
          if (kDebugMode) {
            print('⚠️ No profile data found for user: $userId');
          }
          return null;
        }
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print('⚠️ Profile not found for user: $userId');
        }
        return null;
      } else {
        if (kDebugMode) {
          print('❌ Failed to fetch profile for user $userId: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user title for user $userId: $e');
      }
      return null;
    }
  }

  /// Get user title from post data by extracting user ID and fetching profile
  static Future<String?> getUserTitleFromPostData(Map<String, dynamic> postData) async {
    try {
      // First extract user ID from post data
      final userId = getUserIdFromPostData(postData);
      
      if (userId == null) {
        if (kDebugMode) {
          print('⚠️ Cannot get user title: User ID not found in post data');
        }
        return null;
      }

      // Then fetch user title using the user ID
      final title = await getUserTitleByUserId(userId);
      
      if (title != null) {
        if (kDebugMode) {
          print('✅ Successfully retrieved user title from post data: $title');
        }
        return title;
      } else {
        if (kDebugMode) {
          print('⚠️ No title found for user ID: $userId');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user title from post data: $e');
      }
      return null;
    }
  }
}