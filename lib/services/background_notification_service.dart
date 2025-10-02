import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'notification_service.dart';

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
        if (kDebugMode) print('🔄 Background isolate already running');
      } else {
        await _startBackgroundIsolate();
        if (kDebugMode) print('🚀 Background notification service initialized');
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) print('❌ Error initializing background service: $e');
    }
  }

  /// Start the background isolate for handling notifications
  static Future<void> _startBackgroundIsolate() async {
    try {
      final receivePort = ReceivePort();
      
      await Isolate.spawn(_backgroundIsolateEntryPoint, receivePort.sendPort);
      
      _isolatePort = await receivePort.first;
      IsolateNameServer.registerPortWithName(_isolatePort!, _isolateName);
      
      if (kDebugMode) print('✅ Background isolate started successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to start background isolate: $e');
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
          if (kDebugMode) print('❌ Error handling background message: $e');
        }
      });

      if (kDebugMode) print('🔧 Background isolate listening for messages');
    } catch (e) {
      if (kDebugMode) print('❌ Error in background isolate: $e');
    }
  }

  /// Initialize services in the background isolate
  static Future<void> _initializeBackgroundServices() async {
    try {
      // Initialize notification service in background
      await NotificationService.initialize(
        onBackgroundNotificationTap: _handleBackgroundNotificationTap,
      );

      // Setup socket connection for background events
      await _setupBackgroundSocket();

      if (kDebugMode) print('✅ Background services initialized');
    } catch (e) {
      if (kDebugMode) print('❌ Error initializing background services: $e');
    }
  }

  /// Setup socket connection in background isolate
  static Future<void> _setupBackgroundSocket() async {
    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        if (kDebugMode) print('⚠️ No auth token for background socket');
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
        if (kDebugMode) print('🔗 Background socket connected');
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
        if (kDebugMode) print('🔌 Background socket disconnected');
      });

      if (kDebugMode) print('✅ Background socket setup complete');
    } catch (e) {
      if (kDebugMode) print('❌ Error setting up background socket: $e');
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

      await NotificationService.showPostLikeNotification(
        likerName: likerName,
        postContent: postContent,
        postId: postId,
      );

      if (kDebugMode) print('📱 Background like notification shown');
    } catch (e) {
      if (kDebugMode) print('❌ Error handling background like notification: $e');
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

      await NotificationService.showPostCommentNotification(
        commenterName: commenterName,
        commentText: commentText,
        postContent: postContent,
        postId: postId,
      );

      if (kDebugMode) print('📱 Background comment notification shown');
    } catch (e) {
      if (kDebugMode) print('❌ Error handling background comment notification: $e');
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
      if (kDebugMode) print('❌ Error handling background message: $e');
    }
  }

  /// Handle background notification taps
  @pragma('vm:entry-point')
  static void _handleBackgroundNotificationTap(NotificationResponse response) {
    if (kDebugMode) print('📱 Background notification tapped: ${response.payload}');
    
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
      
      if (kDebugMode) print('🛑 Background services stopped');
    } catch (e) {
      if (kDebugMode) print('❌ Error stopping background services: $e');
    }
  }

  /// Send message to background isolate
  static void sendToBackground(Map<String, dynamic> message) {
    try {
      _isolatePort?.send(message);
    } catch (e) {
      if (kDebugMode) print('❌ Error sending to background: $e');
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
      if (kDebugMode) print('❌ Error checking pending notification: $e');
      return null;
    }
  }

  /// Dispose the service
  static Future<void> dispose() async {
    sendToBackground({'type': 'stop_service'});
    await _stopBackgroundServices();
  }
}