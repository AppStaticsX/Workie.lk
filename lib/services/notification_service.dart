import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static final StreamController<NotificationResponse> _selectNotificationStream =
  StreamController<NotificationResponse>.broadcast();

  static Stream<NotificationResponse> get onNotificationTap =>
      _selectNotificationStream.stream;

  static int _notificationId = 0;

  /// Initialize the notification service
  static Future<void> initialize({
    Function(NotificationResponse)? onNotificationTap,
    Function(NotificationResponse)? onBackgroundNotificationTap,
  }) async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher_foreground');

    final List<DarwinNotificationCategory> darwinNotificationCategories = [
      DarwinNotificationCategory(
        'textCategory',
        actions: [
          DarwinNotificationAction.text(
            'text_1',
            'Reply',
            buttonTitle: 'Send',
            placeholder: 'Type your message...',
          ),
        ],
      ),
      DarwinNotificationCategory(
        'plainCategory',
        actions: [
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2',
            options: {DarwinNotificationActionOption.destructive},
          ),
        ],
      ),
    ];

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: darwinNotificationCategories,
    );

    final DarwinInitializationSettings initializationSettingsMacOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: darwinNotificationCategories,
    );

    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
      linux: initializationSettingsLinux,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap ?? _selectNotificationStream.add,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap ?? _notificationTapBackground,
    );

    await requestPermissions();
  }

  /// Configure local timezone
  static Future<void> _configureLocalTimeZone() async {
    if (Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    if (Platform.isWindows) {
      return;
    }

    // Try to detect timezone manually
    try {
      final DateTime now = DateTime.now();
      final String timeZoneOffset = now.timeZoneOffset.toString();

      // Use a default timezone or detect based on offset
      String timeZoneName = 'UTC';

      // Simple timezone detection based on offset
      switch (now.timeZoneOffset.inHours) {
        case -5:
          timeZoneName = 'America/New_York';
          break;
        case -8:
          timeZoneName = 'America/Los_Angeles';
          break;
        case 0:
          timeZoneName = 'Europe/London';
          break;
        case 1:
          timeZoneName = 'Europe/Berlin';
          break;
        case 5:
          timeZoneName = 'Asia/Karachi';
          break;
        case 8:
          timeZoneName = 'Asia/Shanghai';
          break;
        default:
          timeZoneName = 'UTC';
      }

      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to UTC if timezone detection fails
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// Background notification tap handler
  @pragma('vm:entry-point')
  static void _notificationTapBackground(NotificationResponse notificationResponse) {
    // Handle notification tap silently in production
  }

  /// Request permissions for notifications
  static Future<bool> requestPermissions() async {
    bool permissionGranted = false;

    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      permissionGranted = true;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      permissionGranted =
          await androidImplementation?.requestNotificationsPermission() ?? false;
    }

    return permissionGranted;
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ??
          false;
    }
    return true; // Assume enabled for other platforms
  }

  /// Show a simple notification
  static Future<void> showNotification({
    String? title,
    String? body,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    try {
      final details = notificationDetails ?? _defaultNotificationDetails();

      await _flutterLocalNotificationsPlugin.show(
        _notificationId++,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Show notification with custom sound
  static Future<void> showNotificationWithCustomSound({
    required String title,
    required String body,
    required String soundFileName, // e.g., 'custom_sound.wav'
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'custom_sound_channel',
      'Custom Sound Notifications',
      channelDescription: 'Notifications with custom sounds',
      sound: RawResourceAndroidNotificationSound(soundFileName.split('.').first),
      importance: Importance.max,
      priority: Priority.high,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: soundFileName,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await showNotification(
      title: title,
      body: body,
      payload: payload,
      notificationDetails: details,
    );
  }

  /// Show post like notification
  static Future<void> showPostLikeNotification({
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
        showWhen: true,
        when: null,
        usesChronometer: false,
        fullScreenIntent: true,
        autoCancel: true,
        ongoing: false,
        styleInformation: BigTextStyleInformation(
          '',
          contentTitle: 'Post Liked',
          summaryText: 'Someone liked your post',
        ),
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

      await showNotification(
        title: title,
        body: body,
        payload: payload,
        notificationDetails: details,
      );
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Show post comment notification
  static Future<void> showPostCommentNotification({
    required String commenterName,
    required String commentText,
    required String postContent,
    String? postId,
  }) async {
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
      showWhen: true,
      when: null,
      usesChronometer: false,
      fullScreenIntent: true,
      autoCancel: true,
      ongoing: false,
      styleInformation: BigTextStyleInformation(
        '',
        contentTitle: 'New Comment',
        summaryText: 'Someone commented on your post',
      ),
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

    final truncatedPostContent = postContent.length > 30
        ? '${postContent.substring(0, 30)}...'
        : postContent;

    final truncatedComment = commentText.length > 60
        ? '${commentText.substring(0, 60)}...'
        : commentText;

    await showNotification(
      title: '💬 New Comment',
      body: '$commenterName commented on your post "$truncatedPostContent": "$truncatedComment"',
      payload: 'post_comment:$postId',
      notificationDetails: details,
    );
  }

  /// Schedule a notification
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    final details = notificationDetails ?? _defaultNotificationDetails();

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationId++,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Show notification with action buttons
  static Future<void> showNotificationWithActions({
    required String title,
    required String body,
    required List<NotificationAction> actions,
    String? payload,
  }) async {
    final List<AndroidNotificationAction> androidActions = actions.map((action) =>
        AndroidNotificationAction(
          action.id,
          action.title,
          icon: action.icon != null ? DrawableResourceAndroidBitmap(action.icon!) : null,
        )).toList();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'action_channel',
      'Action Notifications',
      channelDescription: 'Notifications with action buttons',
      importance: Importance.max,
      priority: Priority.high,
      actions: androidActions,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'plainCategory',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await showNotification(
      title: title,
      body: body,
      payload: payload,
      notificationDetails: details,
    );
  }

  /// Show big picture notification (Android)
  static Future<void> showBigPictureNotification({
    required String title,
    required String body,
    required String imagePath,
    String? largeIconPath,
    String? payload,
  }) async {
    final BigPictureStyleInformation bigPictureStyleInformation =
    BigPictureStyleInformation(
      FilePathAndroidBitmap(imagePath),
      largeIcon: largeIconPath != null ? FilePathAndroidBitmap(largeIconPath) : null,
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'big_picture_channel',
      'Big Picture Notifications',
      channelDescription: 'Notifications with big pictures',
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails details = NotificationDetails(android: androidDetails);

    await showNotification(
      title: title,
      body: body,
      payload: payload,
      notificationDetails: details,
    );
  }

  /// Show big text notification (Android)
  static Future<void> showBigTextNotification({
    required String title,
    required String body,
    required String bigText,
    String? payload,
  }) async {
    final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      bigText,
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'big_text_channel',
      'Big Text Notifications',
      channelDescription: 'Notifications with big text',
      styleInformation: bigTextStyleInformation,
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails details = NotificationDetails(android: androidDetails);

    await showNotification(
      title: title,
      body: body,
      payload: payload,
      notificationDetails: details,
    );
  }

  /// Show ongoing notification
  static Future<void> showOngoingNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ongoing_channel',
      'Ongoing Notifications',
      channelDescription: 'Persistent notifications',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await showNotification(
      title: title,
      body: body,
      payload: payload,
      notificationDetails: details,
    );
  }

  /// Show progress notification
  static Future<void> showProgressNotification({
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'progress_channel',
      'Progress Notifications',
      channelDescription: 'Notifications showing progress',
      importance: Importance.max,
      priority: Priority.high,
      showProgress: true,
      progress: progress,
      maxProgress: maxProgress,
      onlyAlertOnce: true,
    );

    final NotificationDetails details = NotificationDetails(android: androidDetails);

    await showNotification(
      title: title,
      body: body,
      payload: payload,
      notificationDetails: details,
    );
  }

  /// Show grouped notifications (Android)
  static Future<void> showGroupedNotifications({
    required String groupKey,
    required List<GroupedNotification> notifications,
    required String summaryTitle,
    required String summaryBody,
  }) async {
    // Show individual notifications
    for (final notification in notifications) {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'grouped_channel',
        'Grouped Notifications',
        channelDescription: 'Notifications that can be grouped',
        importance: Importance.max,
        priority: Priority.high,
        groupKey: groupKey,
      );

      final NotificationDetails details = NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin.show(
        _notificationId++,
        notification.title,
        notification.body,
        details,
        payload: notification.payload,
      );
    }

    // Show summary notification
    final List<String> lines = notifications.map((n) => '${n.title}: ${n.body}').toList();
    final InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: summaryTitle,
      summaryText: summaryBody,
    );

    final AndroidNotificationDetails summaryAndroidDetails = AndroidNotificationDetails(
      'grouped_channel',
      'Grouped Notifications',
      channelDescription: 'Notifications that can be grouped',
      styleInformation: inboxStyleInformation,
      groupKey: groupKey,
      setAsGroupSummary: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails summaryDetails = NotificationDetails(android: summaryAndroidDetails);

    await _flutterLocalNotificationsPlugin.show(
      _notificationId++,
      summaryTitle,
      summaryBody,
      summaryDetails,
    );
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Get active notifications
  static Future<List<ActiveNotification>> getActiveNotifications() async {
    return await _flutterLocalNotificationsPlugin.getActiveNotifications();
  }

  /// Create notification channel (Android)
  static Future<void> createNotificationChannel({
    required String channelId,
    required String channelName,
    required String channelDescription,
    Importance importance = Importance.defaultImportance,
  }) async {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: importance,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Default notification details
  static NotificationDetails _defaultNotificationDetails() {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );
  }

  /// Dispose resources
  static void dispose() {
    _selectNotificationStream.close();
  }
}

/// Model for notification actions
class NotificationAction {
  final String id;
  final String title;
  final String? icon;

  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
  });
}

/// Model for grouped notifications
class GroupedNotification {
  final String title;
  final String body;
  final String? payload;

  const GroupedNotification({
    required this.title,
    required this.body,
    this.payload,
  });
}