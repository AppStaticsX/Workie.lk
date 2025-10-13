import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../secrets/app_secrets.dart';

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
        return;
      }

      // Get current user ID from token
      await _getCurrentUserId();

      // Initialize socket connection
      _socket = IO.io(
        SERVER.serverURL,
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
    } catch (e) {
      // Handle error silently in production
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
        }
      }
    } catch (e) {
      // Handle error silently in production
    }
  }

  // Setup connection event listeners
  void _setupConnectionListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;

      // Authenticate user with socket
      if (_currentUserId != null) {
        _socket?.emit('authenticate', _currentUserId);
      }
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
    });

    _socket?.onReconnect((_) {
      // Re-authenticate on reconnection
      if (_currentUserId != null) {
        _socket?.emit('authenticate', _currentUserId);
      }
    });

    _socket?.onConnectError((error) {
      // Handle connection error silently in production
    });
  }

  // Setup post-related event listeners
  void _setupPostEventListeners() {
    // Listen for post like updates
    _socket?.on('post_like_updated', (data) {
      _notifyListeners('post_like_updated', data);
    });

    // Listen for new comments
    _socket?.on('post_comment_added', (data) {
      _notifyListeners('post_comment_added', data);
    });

    // Listen for like notifications (for post owners)
    _socket?.on('post_like_notification', (data) {
      _notifyListeners('post_like_notification', data);
    });

    // Listen for comment notifications (for post owners)
    _socket?.on('post_comment_notification', (data) {
      _notifyListeners('post_comment_notification', data);
    });

    // Listen for new posts created
    _socket?.on('new_post_created', (data) {
      _notifyListeners('new_post_created', data);
    });

    // Listen for post updates/edits
    _socket?.on('post_updated', (data) {
      _notifyListeners('post_updated', data);
    });

    // Listen for post deletions
    _socket?.on('post_deleted', (data) {
      _notifyListeners('post_deleted', data);
    });
  }

  // Add listener for specific events
  void addEventListener(String event, Function callback) {
    if (_listeners[event] == null) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);
  }

  // Remove listener for specific events
  void removeEventListener(String event, Function callback) {
    if (_listeners[event] != null) {
      _listeners[event]!.remove(callback);
    }
  }

  // Remove all listeners for an event
  void removeAllListeners(String event) {
    if (_listeners[event] != null) {
      _listeners[event]!.clear();
    }
  }

  // Notify all listeners for an event
  void _notifyListeners(String event, dynamic data) {
    if (_listeners[event] != null) {
      for (var callback in _listeners[event]!) {
        try {
          callback(data);
        } catch (e) {
          // Handle listener callback error silently in production
        }
      }
    }
  }

  // Emit custom events to server (if needed)
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket?.emit(event, data);
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
    }
  }
}