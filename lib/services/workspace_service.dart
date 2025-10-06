import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';
import 'background_notification_service.dart';

/// Service to manage background tasks and notification processing
class WorkspaceService {
  static const String _taskIdentifier = 'background_notification_task';
  static const String _socketCheckTask = 'socket_check_task';

  /// Initialize the workspace for background tasks
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      try {
        await Workmanager().initialize(
          callbackDispatcher,
          isInDebugMode: kDebugMode,
        );

        // Register periodic task for background notifications
        await Workmanager().registerPeriodicTask(
          _taskIdentifier,
          _taskIdentifier,
          frequency: const Duration(minutes: 15), // Minimum allowed by Android
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );

        // Register a one-off task for immediate socket check
        await Workmanager().registerOneOffTask(
          _socketCheckTask,
          _socketCheckTask,
          constraints: Constraints(
            networkType: NetworkType.connected,
          ),
        );

        if (kDebugMode) print('✅ Workmanager initialized for background tasks');
      } catch (e) {
        if (kDebugMode) print('❌ Error initializing Workmanager: $e');
      }
    }
  }

  /// Cancel all background tasks
  static Future<void> cancelAllTasks() async {
    if (Platform.isAndroid) {
      try {
        await Workmanager().cancelAll();
        if (kDebugMode) print('🛑 All background tasks canceled');
      } catch (e) {
        if (kDebugMode) print('❌ Error canceling background tasks: $e');
      }
    }
  }

  /// Register a one-time background check
  static Future<void> scheduleImmediateCheck() async {
    if (Platform.isAndroid) {
      try {
        await Workmanager().registerOneOffTask(
          'immediate_${DateTime.now().millisecondsSinceEpoch}',
          _socketCheckTask,
          constraints: Constraints(
            networkType: NetworkType.connected,
          ),
          initialDelay: const Duration(seconds: 5),
        );

        if (kDebugMode) print('⏰ Scheduled immediate background check');
      } catch (e) {
        if (kDebugMode) print('❌ Error scheduling immediate check: $e');
      }
    }
  }
}

/// Callback dispatcher for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) print('🔄 Background task executing: $task');

      switch (task) {
        case 'background_notification_task':
          await _handleBackgroundNotificationTask();
          break;
        case 'socket_check_task':
          await _handleSocketCheckTask();
          break;
        default:
          if (kDebugMode) print('⚠️ Unknown task: $task');
      }

      return Future.value(true);
    } catch (e) {
      if (kDebugMode) print('❌ Background task error: $e');
      return Future.value(false);
    }
  });
}

/// Handle background notification checking
Future<void> _handleBackgroundNotificationTask() async {
  try {
    if (kDebugMode) print('📱 Checking for background notifications...');

    // Initialize notification service if needed
    await NotificationService.initialize();

    // Initialize background notification service
    await BackgroundNotificationService.initialize();

    if (kDebugMode) print('✅ Background notification check completed');
  } catch (e) {
    if (kDebugMode) print('❌ Background notification task error: $e');
  }
}

/// Handle socket connection check
Future<void> _handleSocketCheckTask() async {
  try {
    if (kDebugMode) print('🔌 Checking socket connection in background...');

    // Initialize services for socket check
    await NotificationService.initialize();
    await BackgroundNotificationService.initialize();

    // Test notification to ensure system is working
    if (kDebugMode) {
      await NotificationService.showNotification(
        title: 'Background Check',
        body: 'Background notification system is active',
        payload: 'background_test',
      );
    }

    if (kDebugMode) print('✅ Socket check completed');
  } catch (e) {
    if (kDebugMode) print('❌ Socket check task error: $e');
  }
}