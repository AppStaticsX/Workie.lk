import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:workie/l10n/l10n.dart';
import 'package:workie/screens/splash_screen.dart';
import 'package:workie/services/hive_service.dart';
import 'package:workie/services/notification_service.dart';
import 'package:workie/services/socket_service.dart';
import 'package:workie/themes/theme_provider.dart';
import 'package:workie/providers/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  // Initialize HiveService (registers adapters)
  await HiveService.initHive();

  // Initialize notification service
  await NotificationService.initialize(
    onNotificationTap: (response) {
      // Handle notification tap globally
      print('Notification tapped: ${response.payload}');
      // You can navigate to specific screens based on payload
      _handleNotificationTap(response);
    },
  );

  // Initialize socket service for real-time updates
  try {
    await SocketService.instance.initialize();
    print('✅ Socket service initialized globally');
  } catch (e) {
    print('❌ Error initializing socket service: $e');
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
  switch (response.payload) {
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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