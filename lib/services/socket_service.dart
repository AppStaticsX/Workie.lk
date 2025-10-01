import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _currentUserId;
  bool _isConnected = false;

  // Event listeners for different socket events
  final Map<String, List<Function>> _listeners = {};

  // Singleton getter for global access
  static SocketService get instance => _instance;

  // Initialize socket connection
  Future<void> initialize() async {
    try {
      if (_socket != null && _socket!.connected) {
        if (kDebugMode) print('🔗 Socket already connected');
        return;
      }

      // Get current user ID from token
      await _getCurrentUserId();

      // Initialize socket connection
      _socket = IO.io(
        'https://workie-lk-backend.onrender.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      // Set up connection event listeners
      _setupConnectionListeners();

      // Set up post-related event listeners
      _setupPostEventListeners();

      if (kDebugMode) print('🚀 Socket service initialized');
    } catch (e) {
      if (kDebugMode) print('❌ Error initializing socket: $e');
    }
  }

  // Get current user ID from stored JWT token
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
          if (kDebugMode) print('👤 Current user ID: $_currentUserId');
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error getting user ID: $e');
    }
  }

  // Setup connection event listeners
  void _setupConnectionListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      if (kDebugMode) print('🔗 Socket connected');
      
      // Authenticate user with socket
      if (_currentUserId != null) {
        _socket?.emit('authenticate', _currentUserId);
        if (kDebugMode) print('🔐 User authenticated: $_currentUserId');
      }
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      if (kDebugMode) print('🔌 Socket disconnected');
    });

    _socket?.onReconnect((_) {
      if (kDebugMode) print('🔄 Socket reconnected');
      // Re-authenticate on reconnection
      if (_currentUserId != null) {
        _socket?.emit('authenticate', _currentUserId);
      }
    });

    _socket?.onConnectError((error) {
      if (kDebugMode) print('❌ Socket connection error: $error');
    });
  }

  // Setup post-related event listeners
  void _setupPostEventListeners() {
    // Listen for post like updates
    _socket?.on('post_like_updated', (data) {
      if (kDebugMode) print('👍 Received like update: $data');
      _notifyListeners('post_like_updated', data);
    });

    // Listen for new comments
    _socket?.on('post_comment_added', (data) {
      if (kDebugMode) print('💬 Received comment update: $data');
      _notifyListeners('post_comment_added', data);
    });

    // Listen for like notifications (for post owners)
    _socket?.on('post_like_notification', (data) {
      if (kDebugMode) print('🔔 Received like notification: $data');
      _notifyListeners('post_like_notification', data);
    });

    // Listen for comment notifications (for post owners)
    _socket?.on('post_comment_notification', (data) {
      if (kDebugMode) print('🔔 Received comment notification: $data');
      _notifyListeners('post_comment_notification', data);
    });

    // Listen for new posts created
    _socket?.on('new_post_created', (data) {
      if (kDebugMode) print('🆕 Received new post: $data');
      _notifyListeners('new_post_created', data);
    });

    // Listen for post updates/edits
    _socket?.on('post_updated', (data) {
      if (kDebugMode) print('✏️ Received post update: $data');
      _notifyListeners('post_updated', data);
    });

    // Listen for post deletions
    _socket?.on('post_deleted', (data) {
      if (kDebugMode) print('🗑️ Received post deletion: $data');
      _notifyListeners('post_deleted', data);
    });
  }

  // Add listener for specific events
  void addEventListener(String event, Function callback) {
    if (_listeners[event] == null) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);
    if (kDebugMode) print('📝 Added listener for event: $event');
  }

  // Remove listener for specific events
  void removeEventListener(String event, Function callback) {
    if (_listeners[event] != null) {
      _listeners[event]!.remove(callback);
      if (kDebugMode) print('🗑️ Removed listener for event: $event');
    }
  }

  // Remove all listeners for an event
  void removeAllListeners(String event) {
    if (_listeners[event] != null) {
      _listeners[event]!.clear();
      if (kDebugMode) print('🧹 Cleared all listeners for event: $event');
    }
  }

  // Notify all listeners for an event
  void _notifyListeners(String event, dynamic data) {
    if (_listeners[event] != null) {
      for (var callback in _listeners[event]!) {
        try {
          callback(data);
        } catch (e) {
          if (kDebugMode) print('❌ Error in listener callback: $e');
        }
      }
    }
  }

  // Emit custom events to server (if needed)
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket?.emit(event, data);
      if (kDebugMode) print('📤 Emitted event: $event with data: $data');
    } else {
      if (kDebugMode) print('❌ Cannot emit: Socket not connected');
    }
  }

  // Check if socket is connected
  bool get isConnected => _isConnected;

  // Get current user ID
  String? get currentUserId => _currentUserId;

  // Disconnect socket
  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
    _listeners.clear();
    if (kDebugMode) print('🔌 Socket disconnected and listeners cleared');
  }

  // Reconnect socket
  Future<void> reconnect() async {
    if (_socket != null) {
      _socket?.disconnect();
    }
    await initialize();
  }

  // Update user ID (call when user logs in/out)
  Future<void> updateUserId(String? userId) async {
    _currentUserId = userId;
    if (_socket != null && _isConnected && userId != null) {
      _socket?.emit('authenticate', userId);
      if (kDebugMode) print('🔄 Updated user authentication: $userId');
    }
  }
}