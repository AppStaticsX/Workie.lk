import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:workie/l10n/l10n.dart';
import 'package:workie/screens/splash_screen.dart';
import 'package:workie/services/hive_service.dart';
import 'package:workie/services/notification_service.dart';
import 'package:workie/services/post_notification_service.dart';
import 'package:workie/services/socket_service.dart';
import 'package:workie/services/background_notification_service.dart';
import 'package:workie/services/workspace_service.dart';
import 'package:workie/themes/theme_provider.dart';
import 'package:workie/providers/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();
  // Initialize HiveService (registers adapters)
  await HiveService.initHive();

  // Initialize notification service
  await NotificationService.initialize(
    onNotificationTap: (response) {
      // You can navigate to specific screens based on payload
      _handleNotificationTap(response);
    },
  );

  // Create notification channels for post interactions
  await NotificationService.createNotificationChannel(
    channelId: 'post_like_channel',
    channelName: 'Post Like Notifications',
    channelDescription: 'Notifications when someone likes your post',
    importance: Importance.high,
  );

  await NotificationService.createNotificationChannel(
    channelId: 'post_comment_channel',
    channelName: 'Post Comment Notifications',
    channelDescription: 'Notifications when someone comments on your post',
    importance: Importance.high,
  );

  // Initialize socket service for real-time updates
  try {
    await SocketService.instance.initialize();
  } catch (e) {
    //
  }

  // Initialize post notification service for like/comment notifications
  try {
    await PostNotificationService.initialize();
  } catch (e) {
    //
  }

  // Initialize background notification service for notifications when app is in background
  try {
    await BackgroundNotificationService.initialize();
  } catch (e) {
    //
  }

  // Initialize workspace service for background tasks (Android only)
  try {
    await WorkspaceService.initialize();
  } catch (e) {
    //
  }

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ],
        child: const MyApp(),
      )
  );
}

void _handleNotificationTap(NotificationResponse response) {
  // Handle different notification types based on payload
  final payload = response.payload;
  
  if (payload == null) return;
  
  if (payload.startsWith('post_like:')) {
    // Extract post ID and navigate to post details
    final postId = payload.split(':')[1];
    // TODO: Navigate to specific post or home page
  } else if (payload.startsWith('post_comment:')) {
    // Extract post ID and navigate to post comments
    final postId = payload.split(':')[1];
    // TODO: Navigate to specific post comments or home page
  } else {
    // Handle other notification types
    switch (payload) {
      case 'chat_message':
        // Navigate to chat screen
        break;
      case 'reminder':
        // Navigate to reminder screen
        break;
      case 'download_complete':
        // Show download complete dialog
        break;
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPendingNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _checkPendingNotifications();
        break;
      case AppLifecycleState.paused:
        // Schedule a background check when app goes to background
        WorkspaceService.scheduleImmediateCheck();
        break;
      case AppLifecycleState.detached:
        BackgroundNotificationService.dispose();
        break;
      default:
        break;
    }
  }

  /// Check for pending notification actions when app becomes active
  Future<void> _checkPendingNotifications() async {
    try {
      final pendingAction = await BackgroundNotificationService.checkPendingNotificationAction();
      if (pendingAction != null && pendingAction.isNotEmpty) {
        _handleNotificationTap(NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          id: 0,
          actionId: null,
          input: null,
          payload: pendingAction,
        ));
      }
    } catch (e) {
      //
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Update theme when system brightness changes
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateSystemTheme();
  }

  // Method to update status bar based on system-theme
  void _updateStatusBar(bool isDarkMode) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        // Update status bar whenever theme changes
        final isDarkMode = themeProvider.themeData.brightness == Brightness.dark;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateStatusBar(isDarkMode);
        });

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
          theme: themeProvider.themeData,
          supportedLocales: L10n.all,
          locale: languageProvider.locale, // Use provider's locale
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}