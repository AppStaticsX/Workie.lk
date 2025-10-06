import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    if (kDebugMode) print('🧹 PostNotificationService user data cleared');
  }

  /// Initialize the post notification service
  static Future<void> initialize() async {
    if (instance._isInitialized) {
      if (kDebugMode) print('📱 PostNotificationService already initialized');
      return;
    }

    try {
      // Get current user ID
      await instance._getCurrentUserId();
      
      if (instance._currentUserId != null) {
        if (kDebugMode) print('📱 User already logged in: ${instance._currentUserId}');
        // Load user's own posts into cache
        await instance._loadOwnedPosts();
      } else {
        if (kDebugMode) print('📱 No user logged in at initialization');
      }

      // Setup socket listeners for notification events
      instance._setupSocketListeners();

      instance._isInitialized = true;
      if (kDebugMode) print('✅ PostNotificationService initialized');
    } catch (e) {
      if (kDebugMode) print('❌ Error initializing PostNotificationService: $e');
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
          if (kDebugMode) print('📱 Current user ID from JWT: $_currentUserId');
        }
      } else {
        if (kDebugMode) print('❌ No auth token found');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error getting current user ID: $e');
    }
  }

  /// Setup socket listeners for post events
  void _setupSocketListeners() {
    final socketService = SocketService.instance;

    if (kDebugMode) {
      print('📡 Setting up socket listeners for post notifications');
      print('📡 Socket service status: connected=${socketService.isConnected}');
    }

    // Listen for like notifications (only for post owners)
    socketService.addEventListener('post_like_notification', _onPostLikeNotification);

    // Listen for comment notifications (only for post owners)  
    socketService.addEventListener('post_comment_notification', _onPostCommentNotification);

    // Alternative approach: Listen to regular events and filter for notifications
    socketService.addEventListener('post_like_updated', _onPostLikeUpdated);
    socketService.addEventListener('post_comment_added', _onPostCommentAdded);

    if (kDebugMode) {
      print('✅ Socket listeners setup complete for post notifications');
      print('📡 Listening for events: post_like_notification, post_comment_notification, post_like_updated, post_comment_added');
    }
  }

  /// Alternative handler for like events - check if notification should be shown
  Future<void> _onPostLikeUpdated(dynamic data) async {
    try {
      if (kDebugMode) {
        print('🔔 ==========================================');
        print('🔔 POST LIKE NOTIFICATION EVENT RECEIVED');
        print('🔔 ==========================================');
        print('🔔 Raw event data: $data');
      }

      final userId = data['userId']?.toString(); // User who liked
      final postId = data['postId']?.toString();
      final isLiked = data['isLiked'] ?? false;

      if (kDebugMode) {
        print('🔔 Like event analysis:');
        print('  - Liker user ID: $userId');
        print('  - Post ID: $postId');
        print('  - Current user ID: $_currentUserId');
        print('  - Is liked: $isLiked');
        print('  - Service initialized: $_isInitialized');
      }

      // Validation checks
      if (!_isInitialized) {
        if (kDebugMode) print('❌ PostNotificationService not initialized, ignoring event');
        return;
      }

      if (postId == null || postId.isEmpty) {
        if (kDebugMode) print('❌ Invalid postId, ignoring event');
        return;
      }

      if (userId == null || userId.isEmpty) {
        if (kDebugMode) print('❌ Invalid userId, ignoring event');
        return;
      }

      if (_currentUserId == null) {
        if (kDebugMode) print('⚠️ Current user ID not available, attempting to refresh...');
        await _getCurrentUserId();
        
        if (_currentUserId == null) {
          if (kDebugMode) print('❌ Current user ID still not available after refresh, ignoring event');
          return;
        } else {
          if (kDebugMode) print('✅ Current user ID refreshed: $_currentUserId');
        }
      }

      // Only show notification if:
      // 1. Someone else liked it (not current user)
      // 2. It was a like (not unlike) 
      // 3. We need to check if current user owns this post
      if (userId != _currentUserId && isLiked) {
        if (kDebugMode) print('✅ Conditions met for like notification, checking post ownership...');
        _checkAndShowLikeNotification(postId, userId, data);
      } else {
        if (kDebugMode) {
          if (userId == _currentUserId) {
            print('🔔 Skipping notification - user liked their own post');
          } else if (!isLiked) {
            print('🔔 Skipping notification - post was unliked');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error handling like updated event: $e');
    }
  }

  /// Check if we should show a like notification for this post
  Future<void> _checkAndShowLikeNotification(String postId, String? likerId, dynamic data) async {
    try {
      // Check if current user owns this post and get details
      if (!_ownedPostIds.contains(postId)) {
        final postDetails = await _getPostDetails(postId);
        if (postDetails == null || postDetails['isOwned'] != true) {
          if (kDebugMode) print('🔔 Post $postId not owned by current user, skipping notification');
          return;
        }
        // Cache this post ID for future use
        _ownedPostIds.add(postId);
      }

      // Extract liker name from likes array or use fallback methods
      String likerName = 'Someone';

      // Try to get liker name from the data
      if (data['likerName'] != null) {
        likerName = data['likerName'].toString();
      } else {
        final likes = data['likes'] as List?;
        if (likes != null) {
          // Find the liker in the likes array
          for (var like in likes) {
            if (like['userId']?.toString() == likerId) {
              final userInfo = like['userInfo'];
              if (userInfo != null) {
                final firstName = userInfo['firstName']?.toString() ?? '';
                final lastName = userInfo['lastName']?.toString() ?? '';
                if (firstName.isNotEmpty || lastName.isNotEmpty) {
                  likerName = '$firstName $lastName'.trim();
                  if (kDebugMode) print('🔔 Extracted liker name: $likerName');
                }
              }
              break;
            }
          }
        }
      }

      if (kDebugMode && likerName == 'Someone') {
        print('⚠️ Could not extract liker name, using fallback');
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

      if (kDebugMode) {
        print('🔔 Showing like notification for owned post: $postId');
        print('🔔 Liker: $likerName');
        print('🔔 Content: ${postContent.length > 50 ? postContent.substring(0, 50) + '...' : postContent}');
      }

      await NotificationService.showPostLikeNotification(
        likerName: likerName,
        postContent: postContent,
        postId: postId,
      );

      if (kDebugMode) print('✅ Like notification displayed');
    } catch (e) {
      if (kDebugMode) print('❌ Error showing like notification: $e');
    }
  }

  /// Alternative handler for comment events - check if notification should be shown  
  Future<void> _onPostCommentAdded(dynamic data) async {
    try {
      if (kDebugMode) print('🔔 Post comment added event received: $data');

      final commenterUserId = data['commenterUserId']?.toString(); // User who commented
      final postId = data['postId']?.toString();

      if (kDebugMode) {
        print('🔔 Comment event analysis:');
        print('  - Commenter user ID: $commenterUserId');
        print('  - Post ID: $postId');
        print('  - Current user ID: $_currentUserId');
      }

      // Check if current user ID is available, refresh if needed
      if (_currentUserId == null) {
        if (kDebugMode) print('⚠️ Current user ID not available for comment notification, attempting to refresh...');
        await _getCurrentUserId();
        
        if (_currentUserId == null) {
          if (kDebugMode) print('❌ Current user ID still not available after refresh, ignoring comment event');
          return;
        } else {
          if (kDebugMode) print('✅ Current user ID refreshed for comment notification: $_currentUserId');
        }
      }

      // Only show notification if someone else commented (not current user)
      if (commenterUserId != _currentUserId && postId != null) {
        _checkAndShowCommentNotification(postId, commenterUserId, data);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error handling comment added event: $e');
    }
  }

  /// Check if we should show a comment notification for this post
  Future<void> _checkAndShowCommentNotification(String postId, String? commenterId, dynamic data) async {
    try {
      // Check if current user owns this post and get details
      if (!_ownedPostIds.contains(postId)) {
        final postDetails = await _getPostDetails(postId);
        if (postDetails == null || postDetails['isOwned'] != true) {
          if (kDebugMode) print('🔔 Post $postId not owned by current user, skipping notification');
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
            if (kDebugMode) print('🔔 Extracted commenter name: $commenterName');
          }
        }
      }

      if (kDebugMode && commenterName == 'Someone') {
        print('⚠️ Could not extract commenter name, using fallback');
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

      if (kDebugMode) {
        print('🔔 Showing comment notification for owned post: $postId');
        print('🔔 Commenter: $commenterName');
        print('🔔 Comment: ${commentText.length > 50 ? commentText.substring(0, 50) + '...' : commentText}');
        print('🔔 Content: ${postContent.length > 50 ? postContent.substring(0, 50) + '...' : postContent}');
      }

      await NotificationService.showPostCommentNotification(
        commenterName: commenterName,
        commentText: commentText,
        postContent: postContent,
        postId: postId,
      );

      if (kDebugMode) print('✅ Comment notification displayed');
    } catch (e) {
      if (kDebugMode) print('❌ Error showing comment notification: $e');
    }
  }

  /// Load current user's posts into cache for notification filtering
  Future<void> _loadOwnedPosts() async {
    try {
      if (_currentUserId == null) return;

      // For now, we'll just log that we're loading posts
      // In production, you'd load the user's posts and cache their IDs
      if (kDebugMode) print('🔔 Loading owned posts for user: $_currentUserId');

      // TODO: Load actual user posts from API
      // final posts = await PostDataService.getUserPosts(userId: _currentUserId);
      // _ownedPostIds.addAll(posts.map((post) => post['id'].toString()));

      if (kDebugMode) print('🔔 Owned posts loaded into cache');
    } catch (e) {
      if (kDebugMode) print('❌ Error loading owned posts: $e');
    }
  }

  /// Check if current user owns a specific post and get post content
  Future<Map<String, dynamic>?> _getPostDetails(String postId) async {
    try {
      if (_currentUserId == null) {
        if (kDebugMode) print('❌ No current user ID available for post ownership check');
        return null;
      }

      if (kDebugMode) print('🔔 Fetching post details for: $postId (current user: $_currentUserId)');

      // Try to get auth token for the API call
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        // Make API call to get post details
        final postDetailsUrl = 'https://workie-lk-backend.onrender.com/api/posts/single/$postId';

        if (kDebugMode) print('🔔 Making API call to: $postDetailsUrl');

        try {
          final response = await http.get(
            Uri.parse(postDetailsUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));

          if (kDebugMode) print('🔔 API response status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (kDebugMode) print('🔔 API response data: $data');

            if (data['success'] == true && data['data'] != null) {
              final post = data['data'];
              final postOwnerId = post['userId']?['_id']?.toString() ?? post['userId']?.toString();
              final isOwned = postOwnerId == _currentUserId;

              if (kDebugMode) {
                print('🔔 Post ownership analysis:');
                print('  - Post owner ID: $postOwnerId');
                print('  - Current user ID: $_currentUserId');
                print('  - User owns post: $isOwned');
              }

              return {
                'isOwned': isOwned,
                'content': post['content']?.toString() ?? 'your post',
                'userId': postOwnerId,
              };
            } else {
              if (kDebugMode) print('❌ API returned unsuccessful response or no data');
            }
          } else {
            if (kDebugMode) print('❌ API call failed with status: ${response.statusCode} - ${response.body}');
          }
        } catch (apiError) {
          if (kDebugMode) print('⚠️ API call failed with exception: $apiError');
        }
      } else {
        if (kDebugMode) print('❌ No auth token available for API call');
      }

      if (kDebugMode) print('❌ Could not determine post ownership, skipping notification');
      return {
        'isOwned': false, // Conservative approach - don't show notification if we can't verify ownership
        'content': 'your post',
      };
    } catch (e) {
      if (kDebugMode) print('❌ Error getting post details: $e');
      return null;
    }
  }

  /// Check if current user owns a specific post
  Future<bool> _checkIfUserOwnsPost(String postId) async {
    try {
      final details = await _getPostDetails(postId);
      return details?['isOwned'] ?? false;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking post ownership: $e');
      return false;
    }
  }

  /// Refresh current user ID - call this after user login/logout
  static Future<void> refreshCurrentUser() async {
    try {
      if (kDebugMode) print('🔄 Refreshing current user ID in PostNotificationService');
      await instance._getCurrentUserId();
      
      // Clear and reload owned posts cache for the new user
      instance._ownedPostIds.clear();
      await instance._loadOwnedPosts();
      
      if (kDebugMode) print('✅ Current user ID refreshed: ${instance._currentUserId}');
    } catch (e) {
      if (kDebugMode) print('❌ Error refreshing current user ID: $e');
    }
  }

  /// Check if the service has a valid current user ID
  static bool get hasValidCurrentUser => instance._currentUserId != null;

  /// Add a post ID to the owned posts cache (call when user creates a post)
  static void addOwnedPost(String postId) {
    instance._ownedPostIds.add(postId);
    if (kDebugMode) print('📝 Added post $postId to owned posts cache');
  }

  /// Remove a post ID from the owned posts cache (call when user deletes a post)
  static void removeOwnedPost(String postId) {
    instance._ownedPostIds.remove(postId);
    if (kDebugMode) print('🗑️ Removed post $postId from owned posts cache');
  }

  /// Handle post like notification
  void _onPostLikeNotification(dynamic data) {
    try {
      if (kDebugMode) {
        print('🔔 Raw like notification data received: $data');
        print('🔔 Data type: ${data.runtimeType}');
        if (data is Map) {
          print('🔔 Data keys: ${data.keys.toList()}');
        }
      }

      // Check if notification is for current user
      final postOwnerId = data['postOwnerId']?.toString();
      if (kDebugMode) {
        print('🔔 Post owner ID from notification: $postOwnerId');
        print('🔔 Current user ID: $_currentUserId');
        print('🔔 IDs match: ${postOwnerId == _currentUserId}');
      }

      if (postOwnerId == null || postOwnerId != _currentUserId) {
        if (kDebugMode) print('📱 Like notification not for current user, ignoring');
        return;
      }

      final likerName = data['likerName']?.toString() ?? 'Someone';
      final postContent = data['postContent']?.toString() ?? 'your post';
      final postId = data['postId']?.toString();
      final isLiked = data['isLiked'] ?? true;

      if (kDebugMode) {
        print('🔔 Like notification details:');
        print('  - Liker: $likerName');
        print('  - Post ID: $postId');
        print('  - Is Liked: $isLiked');
        print('  - Post Content: ${postContent.substring(0, postContent.length > 50 ? 50 : postContent.length)}...');
      }

      if (isLiked) {
        // Show notification for like
        if (kDebugMode) print('🔔 Attempting to show like notification...');

        NotificationService.showPostLikeNotification(
          likerName: likerName,
          postContent: postContent,
          postId: postId,
        );

        if (kDebugMode) print('✅ Like notification shown for post: $postId');
      }
      // Note: We don't show notifications for unlikes
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling like notification: $e');
        print('❌ Stack trace: ${StackTrace.current}');
      }
    }
  }

  /// Handle post comment notification
  void _onPostCommentNotification(dynamic data) {
    try {
      if (kDebugMode) {
        print('🔔 Raw comment notification data received: $data');
        print('🔔 Data type: ${data.runtimeType}');
        if (data is Map) {
          print('🔔 Data keys: ${data.keys.toList()}');
        }
      }

      // Check if notification is for current user
      final postOwnerId = data['postOwnerId']?.toString();
      if (kDebugMode) {
        print('🔔 Post owner ID from notification: $postOwnerId');
        print('🔔 Current user ID: $_currentUserId');
        print('🔔 IDs match: ${postOwnerId == _currentUserId}');
      }

      if (postOwnerId == null || postOwnerId != _currentUserId) {
        if (kDebugMode) print('📱 Comment notification not for current user, ignoring');
        return;
      }

      final commenterName = data['commenterName']?.toString() ?? 'Someone';
      final commentText = data['commentText']?.toString() ?? data['comment']?.toString() ?? 'commented on your post';
      final postContent = data['postContent']?.toString() ?? 'your post';
      final postId = data['postId']?.toString();

      if (kDebugMode) {
        print('🔔 Comment notification details:');
        print('  - Commenter: $commenterName');
        print('  - Post ID: $postId');
        print('  - Comment: ${commentText.substring(0, commentText.length > 50 ? 50 : commentText.length)}...');
        print('  - Post Content: ${postContent.substring(0, postContent.length > 50 ? 50 : postContent.length)}...');
      }

      // Show notification for comment
      if (kDebugMode) print('🔔 Attempting to show comment notification...');

      NotificationService.showPostCommentNotification(
        commenterName: commenterName,
        commentText: commentText,
        postContent: postContent,
        postId: postId,
      );

      if (kDebugMode) print('✅ Comment notification shown for post: $postId');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling comment notification: $e');
        print('❌ Stack trace: ${StackTrace.current}');
      }
    }
  }

  /// Update current user ID (call when user logs in/out)
  static Future<void> updateCurrentUserId() async {
    await instance._getCurrentUserId();
    if (kDebugMode) print('🔄 PostNotificationService user ID updated: ${instance._currentUserId}');
  }

  /// Test method to verify notifications work (for debugging only)
  static Future<void> testNotifications() async {
    if (kDebugMode) {
      print('🧪 Testing notifications...');

      // First test if permissions are working
      final permissionsEnabled = await NotificationService.areNotificationsEnabled();
      print('🧪 Notification permissions enabled: $permissionsEnabled');

      // Test like notification
      await NotificationService.showPostLikeNotification(
        likerName: 'Test User',
        postContent: 'This is a test post to verify notifications are working properly.',
        postId: 'test123',
      );

      if (kDebugMode) print('🧪 Test like notification sent');
    }
  }

  /// Test method to simulate socket notification events (for debugging only)
  static void testSocketNotifications() {
    if (kDebugMode) {
      print('🧪 Testing socket notification handling...');

      // Simulate a like notification event
      final likeData = {
        'postOwnerId': instance._currentUserId,
        'likerName': 'Socket Test User',
        'postContent': 'This is a simulated socket event for testing notifications.',
        'postId': 'socket_test_123',
        'isLiked': true,
      };

      instance._onPostLikeNotification(likeData);
    }
  }

  /// Test method to verify notifications are working
  static Future<void> testNotification() async {
    try {
      if (kDebugMode) print('🧪 Testing post like notification...');

      await NotificationService.showPostLikeNotification(
        likerName: 'Test User',
        postContent: 'This is a test notification to verify the notification system is working properly.',
        postId: 'test_123',
      );

      if (kDebugMode) print('✅ Test notification sent');
    } catch (e) {
      if (kDebugMode) print('❌ Test notification failed: $e');
    }
  }

  /// Simulate a like event for testing
  static void simulateLikeEvent() {
    if (kDebugMode) print('🧪 Simulating like event for testing...');

    if (instance._isInitialized) {
      final likeData = {
        'postOwnerId': instance._currentUserId,
        'likerName': 'Socket Test User',
        'postContent': 'This is a simulated socket event for testing notifications.',
        'postId': 'socket_test_123',
        'isLiked': true,
      };

      instance._onPostLikeNotification(likeData);
    }
  }

  /// Cleanup socket listeners
  static void dispose() {
    if (!instance._isInitialized) return;

    final socketService = SocketService.instance;
    socketService.removeEventListener('post_like_notification', instance._onPostLikeNotification);
    socketService.removeEventListener('post_comment_notification', instance._onPostCommentNotification);
    socketService.removeEventListener('post_like_updated', instance._onPostLikeUpdated);
    socketService.removeEventListener('post_comment_added', instance._onPostCommentAdded);

    instance._isInitialized = false;
    if (kDebugMode) print('🧹 PostNotificationService disposed');
  }
}