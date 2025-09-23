import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/media_item_model.dart';

class CurrentUserPostsService {
  static const String baseUrl = 'https://workie-lk-backend.onrender.com/api';

  /// Get current user's ID from JWT token
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

  /// Get current user's posts with pagination
  static Future<Map<String, dynamic>> getCurrentUserPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      // Get current user ID
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('Unable to get current user ID');
      }

      final uri = Uri.parse('$baseUrl/posts/user/$currentUserId?page=$page&limit=$limit');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'posts': List<Map<String, dynamic>>.from(data['data'] ?? []),
            'pagination': data['pagination'] ?? {},
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch current user posts');
        }
      } else {
        throw Exception('Failed to fetch current user posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get current user's posts formatted for widgets
  static Future<List<Map<String, dynamic>>> getCurrentUserPostsFormatted({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await getCurrentUserPosts(page: page, limit: limit);
      final posts = result['posts'] as List<Map<String, dynamic>>;
      
      List<Map<String, dynamic>> formattedPosts = [];
      
      for (var post in posts) {
        final formattedPost = await formatPostForWidget(post);
        formattedPosts.add(formattedPost);
      }
      
      return formattedPosts;
    } catch (e) {
      throw Exception('Error formatting current user posts: $e');
    }
  }

  /// Get total posts count for current user
  static Future<int> getCurrentUserPostsCount() async {
    try {
      final result = await getCurrentUserPosts(page: 1, limit: 1);
      final pagination = result['pagination'] as Map<String, dynamic>;
      return pagination['total'] ?? 0;
    } catch (e) {
      print('Error getting current user posts count: $e');
      return 0;
    }
  }

  /// Delete current user's post
  static Future<Map<String, dynamic>> deletePost(String postId) async {
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
      } else {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Convert backend post data to widget format (same logic as PostDataService)
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
      } else if (userId != null && userId is Map) {
        firstName = userId['firstName'] ?? '';
        lastName = userId['lastName'] ?? '';
        email = userId['email'] ?? '';
        profilePicture = userId['profilePicture'] ?? '';
        userTitle = userId['title'] ?? '';
      }

      // Default title if empty
      if (userTitle.isEmpty) {
        userTitle = 'Workie User';
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
        'privacy': backendPost['privacy'] ?? 'public',
        'location': backendPost['location'] ?? '',
        'createdAt': backendPost['createdAt'],
        'updatedAt': backendPost['updatedAt'],
        'isEdited': backendPost['isEdited'] ?? false,
      };
    } catch (e) {
      print('Error formatting current user post: $e');
      // Return a default formatted post in case of error
      return {
        'id': backendPost['_id'] ?? '',
        'profileImageUrl': 'https://via.placeholder.com/150',
        'userName': 'Current User',
        'userTitle': 'Workie User',
        'timeAgo': 'Just Now',
        'isVerified': true,
        'content': backendPost['content'] ?? 'No content',
        'mediaUrls': <MediaItem>[],
        'hashtags': <String>['MyPost'],
        'initialLikeCount': 0,
        'commentCount': 0,
        'shareCount': 0,
        'comments': <Map<String, dynamic>>[],
        'isLikedByCurrentUser': false,
        'hasUserCommented': false,
        'likes': <Map<String, dynamic>>[],
        'privacy': 'public',
        'location': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isEdited': false,
      };
    }
  }

  /// Format timestamp to relative time
  static String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return 'Just Now';

      DateTime dateTime;
      if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Just Now';
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
        return 'Just Now';
      }
    } catch (e) {
      return 'Just Now';
    }
  }

  /// Get current user's posts by privacy level
  static Future<List<Map<String, dynamic>>> getCurrentUserPostsByPrivacy({
    required String privacy, // 'public', 'friends', 'private'
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final allPosts = await getCurrentUserPostsFormatted(page: page, limit: limit);
      
      // Filter posts by privacy level
      final filteredPosts = allPosts.where((post) => 
        post['privacy'] == privacy
      ).toList();
      
      return filteredPosts;
    } catch (e) {
      throw Exception('Error filtering posts by privacy: $e');
    }
  }

  /// Get current user's posts with media only
  static Future<List<Map<String, dynamic>>> getCurrentUserMediaPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final allPosts = await getCurrentUserPostsFormatted(page: page, limit: limit);
      
      // Filter posts that have media
      final mediaPosts = allPosts.where((post) {
        final mediaUrls = post['mediaUrls'] as List<MediaItem>?;
        return mediaUrls != null && mediaUrls.isNotEmpty;
      }).toList();
      
      return mediaPosts;
    } catch (e) {
      throw Exception('Error getting current user media posts: $e');
    }
  }
}