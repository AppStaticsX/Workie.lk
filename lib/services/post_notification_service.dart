import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'notification_service.dart';
import 'socket_service.dart';

/// Service to handle post-related notifications (likes, comments)
class PostNotificationService {
  static final PostNotificationService _instance = PostNotificationService._internal();
  factory PostNotificationService() => _instance;
  PostNotificationService._internal();

  static PostNotificationService get instance => _instance;

  bool _isInitialized = false;
  String? _currentUserId;
  Set<String> _ownedPostIds = {}; // Cache of post IDs owned by current user

  /// Clear user session data - for use by AuthService
  static void clearUserData() {
    instance._currentUserId = null;
    instance._ownedPostIds.clear();
  }

  /// Initialize the post notification service
  static Future<void> initialize() async {
    if (instance._isInitialized) {
      return;
    }

    try {
      // Get current user ID
      await instance._getCurrentUserId();
      
      if (instance._currentUserId != null) {
        // Load user's own posts into cache
        await instance._loadOwnedPosts();
      }

      // Setup socket listeners for notification events
      instance._setupSocketListeners();

      instance._isInitialized = true;
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Get current user ID from JWT token (same method as SocketService)
  Future<void> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          _currentUserId = payload['id'];
        }
      }
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Setup socket listeners for post events
  void _setupSocketListeners() {
    final socketService = SocketService.instance;

    // Listen for like notifications (only for post owners)
    socketService.addEventListener('post_like_notification', _onPostLikeNotification);

    // Listen for comment notifications (only for post owners)  
    socketService.addEventListener('post_comment_notification', _onPostCommentNotification);
  }







  /// Check if we should show a comment notification for this post
  Future<void> _checkAndShowCommentNotification(String postId, String? commenterId, dynamic data) async {
    try {
      // Check if current user owns this post and get details
      if (!_ownedPostIds.contains(postId)) {
        final postDetails = await _getPostDetails(postId);
        if (postDetails == null || postDetails['isOwned'] != true) {
          return;
        }
        // Cache this post ID for future use
        _ownedPostIds.add(postId);
      }

      // Extract commenter name from various sources
      String commenterName = 'Someone';

      // Try to get commenter name from the data
      if (data['commenterName'] != null) {
        commenterName = data['commenterName'].toString();
      } else {
        final comment = data['comment'];
        if (comment != null && comment['userInfo'] != null) {
          final userInfo = comment['userInfo'];
          final firstName = userInfo['firstName']?.toString() ?? '';
          final lastName = userInfo['lastName']?.toString() ?? '';
          if (firstName.isNotEmpty || lastName.isNotEmpty) {
            commenterName = '$firstName $lastName'.trim();
          }
        }
      }

      // Extract comment text from various sources
      String commentText = 'commented on your post';
      if (data['commentText'] != null) {
        commentText = data['commentText'].toString();
      } else if (data['comment'] != null) {
        if (data['comment']['comment'] != null) {
          commentText = data['comment']['comment'].toString();
        } else if (data['comment'].toString() != 'Instance of \'Map<String, dynamic>\'') {
          commentText = data['comment'].toString();
        }
      }

      // Get post content from various sources
      String postContent = 'your post';
      if (data['postContent'] != null) {
        postContent = data['postContent'].toString();
      } else {
        // Try to get content from post details or use a generic message
        final postDetails = await _getPostDetails(postId);
        if (postDetails != null && postDetails['content'] != null) {
          postContent = postDetails['content'].toString();
        }
      }

      await NotificationService.showPostCommentNotification(
        commenterName: commenterName,
        commentText: commentText,
        postContent: postContent,
        postId: postId,
      );
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Load current user's posts into cache for notification filtering
  Future<void> _loadOwnedPosts() async {
    try {
      if (_currentUserId == null) return;

      // TODO: Load actual user posts from API
      // final posts = await PostDataService.getUserPosts(userId: _currentUserId);
      // _ownedPostIds.addAll(posts.map((post) => post['id'].toString()));
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Check if current user owns a specific post and get post content
  Future<Map<String, dynamic>?> _getPostDetails(String postId) async {
    try {
      if (_currentUserId == null) {
        return null;
      }

      // Try to get auth token for the API call
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        // Make API call to get post details
        final postDetailsUrl = 'https://workie-lk-backend.onrender.com/api/posts/single/$postId';

        try {
          final response = await http.get(
            Uri.parse(postDetailsUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data['success'] == true && data['data'] != null) {
              final post = data['data'];
              final postOwnerId = post['userId']?['_id']?.toString() ?? post['userId']?.toString();
              final isOwned = postOwnerId == _currentUserId;

              return {
                'isOwned': isOwned,
                'content': post['content']?.toString() ?? 'your post',
                'userId': postOwnerId,
              };
            }
          }
        } catch (apiError) {
          // Handle API error silently
        }
      }

      return {
        'isOwned': false, // Conservative approach - don't show notification if we can't verify ownership
        'content': 'your post',
      };
    } catch (e) {
      return null;
    }
  }

  /// Check if current user owns a specific post
  Future<bool> _checkIfUserOwnsPost(String postId) async {
    try {
      final details = await _getPostDetails(postId);
      return details?['isOwned'] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Refresh current user ID - call this after user login/logout
  static Future<void> refreshCurrentUser() async {
    try {
      await instance._getCurrentUserId();
      
      // Clear and reload owned posts cache for the new user
      instance._ownedPostIds.clear();
      await instance._loadOwnedPosts();
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Check if the service has a valid current user ID
  static bool get hasValidCurrentUser => instance._currentUserId != null;

  /// Add a post ID to the owned posts cache (call when user creates a post)
  static void addOwnedPost(String postId) {
    instance._ownedPostIds.add(postId);
  }

  /// Remove a post ID from the owned posts cache (call when user deletes a post)
  static void removeOwnedPost(String postId) {
    instance._ownedPostIds.remove(postId);
  }

  /// Handle post like notification
  void _onPostLikeNotification(dynamic data) {
    try {
      // Check if notification is for current user
      final postOwnerId = data['postOwnerId']?.toString();

      if (postOwnerId == null || postOwnerId != _currentUserId) {
        return;
      }

      final likerName = data['likerName']?.toString() ?? 'Someone';
      final postContent = data['postContent']?.toString() ?? 'your post';
      final postId = data['postId']?.toString();
      final isLiked = data['isLiked'] ?? true;

      if (isLiked) {
        // Show notification for like
        NotificationService.showPostLikeNotification(
          likerName: likerName,
          postContent: postContent,
          postId: postId,
        );
      }
      // Note: We don't show notifications for unlikes
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Handle post comment notification
  void _onPostCommentNotification(dynamic data) {
    try {
      // Check if notification is for current user
      final postOwnerId = data['postOwnerId']?.toString();

      if (postOwnerId == null || postOwnerId != _currentUserId) {
        return;
      }

      final commenterName = data['commenterName']?.toString() ?? 'Someone';
      final commentText = data['commentText']?.toString() ?? data['comment']?.toString() ?? 'commented on your post';
      final postContent = data['postContent']?.toString() ?? 'your post';
      final postId = data['postId']?.toString();

      // Show notification for comment
      NotificationService.showPostCommentNotification(
        commenterName: commenterName,
        commentText: commentText,
        postContent: postContent,
        postId: postId,
      );
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Update current user ID (call when user logs in/out)
  static Future<void> updateCurrentUserId() async {
    await instance._getCurrentUserId();
  }



  /// Cleanup socket listeners
  static void dispose() {
    if (!instance._isInitialized) return;

    final socketService = SocketService.instance;
    socketService.removeEventListener('post_like_notification', instance._onPostLikeNotification);
    socketService.removeEventListener('post_comment_notification', instance._onPostCommentNotification);

    instance._isInitialized = false;
  }
}