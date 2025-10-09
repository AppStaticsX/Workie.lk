import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Background service for handling notifications when app is in background
class BackgroundNotificationService {
  static const String _isolateName = 'background_notification_isolate';
  static SendPort? _isolatePort;
  static bool _isInitialized = false;

  /// Initialize the background notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Register the background isolate
      const isolateName = _isolateName;
      final port = IsolateNameServer.lookupPortByName(isolateName);

      if (port != null) {
        _isolatePort = port;
      } else {
        await _startBackgroundIsolate();
      }

      _isInitialized = true;
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Start the background isolate for handling notifications
  static Future<void> _startBackgroundIsolate() async {
    try {
      final receivePort = ReceivePort();

      await Isolate.spawn(_backgroundIsolateEntryPoint, receivePort.sendPort);

      _isolatePort = await receivePort.first;
      IsolateNameServer.registerPortWithName(_isolatePort!, _isolateName);
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Entry point for the background isolate
  @pragma('vm:entry-point')
  static void _backgroundIsolateEntryPoint(SendPort mainSendPort) async {
    try {
      final backgroundPort = ReceivePort();
      mainSendPort.send(backgroundPort.sendPort);

      // Initialize background services
      await _initializeBackgroundServices();

      // Listen for commands from main isolate
      backgroundPort.listen((message) async {
        try {
          await _handleBackgroundMessage(message);
        } catch (e) {
          // Handle error silently in production
        }
      });
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Initialize services in the background isolate
  static Future<void> _initializeBackgroundServices() async {
    try {
      // Initialize flutter local notifications plugin directly in background isolate
      await _initializeBackgroundNotifications();

      // Setup socket connection for background events
      await _setupBackgroundSocket();
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Background notification plugin instance for isolate
  static final FlutterLocalNotificationsPlugin _backgroundNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  static int _backgroundNotificationId = 1000; // Start from 1000 to avoid conflicts

  /// Initialize flutter local notifications plugin in background isolate
  static Future<void> _initializeBackgroundNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher_foreground');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsIOS,
      );

      await _backgroundNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveBackgroundNotificationResponse: _handleBackgroundNotificationTap,
      );
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Show post like notification in background isolate
  static Future<void> _showBackgroundPostLikeNotification({
    required String likerName,
    required String postContent,
    String? postId,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'post_like_channel',
        'Post Like Notifications',
        channelDescription: 'Notifications when someone likes your post',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher_foreground',
        enableLights: true,
        enableVibration: true,
        playSound: true,
        autoCancel: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      final truncatedContent = postContent.length > 50
          ? '${postContent.substring(0, 50)}...'
          : postContent;

      final title = '👍 Post Liked';
      final body = '$likerName liked your post: "$truncatedContent"';
      final payload = 'post_like:$postId';

      await _backgroundNotificationsPlugin.show(
        _backgroundNotificationId++,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Show post comment notification in background isolate
  static Future<void> _showBackgroundPostCommentNotification({
    required String commenterName,
    required String commentText,
    required String postContent,
    String? postId,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'post_comment_channel',
        'Post Comment Notifications',
        channelDescription: 'Notifications when someone comments on your post',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher_foreground',
        enableLights: true,
        enableVibration: true,
        playSound: true,
        autoCancel: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      final truncatedContent = postContent.length > 50
          ? '${postContent.substring(0, 50)}...'
          : postContent;
      
      final truncatedComment = commentText.length > 30
          ? '${commentText.substring(0, 30)}...'
          : commentText;

      final title = '💬 New Comment';
      final body = '$commenterName commented "$truncatedComment" on your post: "$truncatedContent"';
      final payload = 'post_comment:$postId';

      await _backgroundNotificationsPlugin.show(
        _backgroundNotificationId++,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Setup socket connection in background isolate
  static Future<void> _setupBackgroundSocket() async {
    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return;
      }

      // Extract user ID from token
      final parts = token.split('.');
      if (parts.length != 3) return;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final userId = payload['id'];

      // Initialize socket connection
      final socket = IO.io(
        'https://workie-lk-backend.onrender.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(10000)
            .setReconnectionAttempts(10)
            .build(),
      );

      // Setup authentication and listeners
      socket.onConnect((_) {
        socket.emit('authenticate', userId);
      });

      // Listen for like notifications
      socket.on('post_like_notification', (data) async {
        await _handleLikeNotification(data, userId);
      });

      // Listen for comment notifications  
      socket.on('post_comment_notification', (data) async {
        await _handleCommentNotification(data, userId);
      });

      socket.onDisconnect((_) {
        // Handle disconnect silently in production
      });
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Handle like notification in background
  static Future<void> _handleLikeNotification(dynamic data, String currentUserId) async {
    try {
      // Check if this notification is for the current user
      final postOwnerId = data['postOwnerId']?.toString();
      if (postOwnerId != currentUserId) return;

      final likerName = data['likerName']?.toString() ?? 'Someone';
      final postContent = data['postContent']?.toString() ?? 'your post';
      final postId = data['postId']?.toString() ?? '';

      await _showBackgroundPostLikeNotification(
        likerName: likerName,
        postContent: postContent,
        postId: postId,
      );
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Handle comment notification in background
  static Future<void> _handleCommentNotification(dynamic data, String currentUserId) async {
    try {
      // Check if this notification is for the current user
      final postOwnerId = data['postOwnerId']?.toString();
      if (postOwnerId != currentUserId) return;

      final commenterName = data['commenterName']?.toString() ?? 'Someone';
      final commentText = data['commentText']?.toString() ?? 'commented';
      final postContent = data['postContent']?.toString() ?? 'your post';
      final postId = data['postId']?.toString() ?? '';

      await _showBackgroundPostCommentNotification(
        commenterName: commenterName,
        commentText: commentText,
        postContent: postContent,
        postId: postId,
      );
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Handle messages from main isolate
  static Future<void> _handleBackgroundMessage(dynamic message) async {
    try {
      if (message is Map<String, dynamic>) {
        switch (message['type']) {
          case 'user_changed':
          // Reconnect socket with new user
            await _setupBackgroundSocket();
            break;
          case 'stop_service':
          // Stop background services
            await _stopBackgroundServices();
            break;
        }
      }
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Handle background notification taps
  @pragma('vm:entry-point')
  static void _handleBackgroundNotificationTap(NotificationResponse response) {
    // Store notification tap for when app becomes active
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('pending_notification_action', response.payload ?? '');
    });
  }

  /// Stop background services
  static Future<void> _stopBackgroundServices() async {
    try {
      // Clean up resources
      IsolateNameServer.removePortNameMapping(_isolateName);
      _isolatePort = null;
      _isInitialized = false;
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Send message to background isolate
  static void sendToBackground(Map<String, dynamic> message) {
    try {
      _isolatePort?.send(message);
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Notify background service of user change
  static void notifyUserChanged() {
    sendToBackground({'type': 'user_changed'});
  }

  /// Check for pending notification actions
  static Future<String?> checkPendingNotificationAction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final action = prefs.getString('pending_notification_action');

      if (action != null && action.isNotEmpty) {
        // Clear the pending action
        await prefs.remove('pending_notification_action');
        return action;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Dispose the service
  static Future<void> dispose() async {
    sendToBackground({'type': 'stop_service'});
    await _stopBackgroundServices();
  }
}