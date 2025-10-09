import 'dart:io';
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
      } catch (e) {
        // Handle error silently in production
      }
    }
  }

  /// Cancel all background tasks
  static Future<void> cancelAllTasks() async {
    if (Platform.isAndroid) {
      try {
        await Workmanager().cancelAll();
      } catch (e) {
        // Handle error silently in production
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
      } catch (e) {
        // Handle error silently in production
      }
    }
  }
}

/// Callback dispatcher for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'background_notification_task':
          await _handleBackgroundNotificationTask();
          break;
        case 'socket_check_task':
          await _handleSocketCheckTask();
          break;
        default:
          // Unknown task - do nothing
          break;
      }

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

/// Handle background notification checking
Future<void> _handleBackgroundNotificationTask() async {
  try {
    // Initialize notification service if needed
    await NotificationService.initialize();

    // Initialize background notification service
    await BackgroundNotificationService.initialize();
  } catch (e) {
    // Handle error silently in production
  }
}

/// Handle socket connection check
Future<void> _handleSocketCheckTask() async {
  try {
    // Initialize services for socket check
    await NotificationService.initialize();
    await BackgroundNotificationService.initialize();
  } catch (e) {
    // Handle error silently in production
  }
}