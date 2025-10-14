import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../screens/terms_privacy_page.dart';
import '../services/pull_data/get_user_data.dart';
import '../services/location_service.dart';
import '../themes/theme_provider.dart';
import 'components/privacy_settings_page.dart';
import 'components/work_categories_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  String _fullName = '';
  String _userEmail = '';
  String _userProfileImage = '';
  final String _currentVersion = '1.2.25';
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadSettings();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has regained focus, check location permission again
      // in case user changed it in device settings
      _checkLocationPermission();
    }
  }

  Future<void> _loadUserData() async {

    try {
      UserData? userData = await GetUserDataService.getCurrentUserData();

      if (userData != null) {
        setState(() {
          _fullName = userData.fullName;
          _userEmail = userData.email;
          _userProfileImage = userData.profilePicture!;
        });
      }
    } catch (e) {
      //
    }
    /*try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _fullName = prefs.getString('full_name') ?? 'User';
        _userEmail = prefs.getString('email') ?? 'user@example.com';
      });
    } catch (e) {
      // Handle error
    }*/
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        // Location enabled state is now managed by actual device permission
        // _locationEnabled will be set by _checkLocationPermission()
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool permissionGranted = await LocationService.isLocationPermissionGranted();
      setState(() {
        _locationEnabled = permissionGranted;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _locationEnabled = false;
      });
    }
  }

  Future<void> _saveNotificationSetting(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', value);
      setState(() {
        _notificationsEnabled = value;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveLocationSetting(bool value) async {
    if (value) {
      // User wants to enable location - request permission
      bool permissionGranted = await LocationService.requestLocationPermission();
      setState(() {
        _locationEnabled = permissionGranted;
      });

      if (!permissionGranted) {
        // Show error message if permission was not granted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permission is required to enable location services'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // User wants to disable location - show dialog to explain they need to do it in settings
      _showLocationDisableDialog();
    }
  }

  void _showLocationDisableDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            'Disable Location Services',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Montserrat'
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'To disable location services, please go to your device settings and revoke location permissions for this app.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontFamily: 'Montserrat'
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Open app settings so user can disable permissions
                LocationService.requestLocationPermission();
              },
              child: Text(
                'Open Settings',
                style: TextStyle(color: const Color(0xFF4E6BF5), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              title: Text(
                'Choose Theme',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeOption(
                    'Light Theme',
                    Iconsax.sun_1_copy,
                    ThemeMode.light,
                    themeProvider,
                  ),
                  _buildThemeOption(
                    'Dark Theme',
                    Iconsax.moon_copy,
                    ThemeMode.dark,
                    themeProvider,
                  ),
                  _buildThemeOption(
                    'System',
                    Iconsax.mobile_programming_copy,
                    ThemeMode.system,
                    themeProvider,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: const Color(0xFF4E6BF5)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(
    String title,
    IconData icon,
    ThemeMode mode,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected 
          ? const Color(0xFF4E6BF5) 
          : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
        ? Icon(
            Iconsax.tick_circle_copy,
            color: const Color(0xFF4E6BF5),
          )
        : null,
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.of(context).pop();
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              title: Text(
                'Choose Language',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageOption(
                    'English',
                    'en',
                    languageProvider,
                  ),
                  _buildLanguageOption(
                    'සිංහල',
                    'si',
                    languageProvider,
                  ),
                  _buildLanguageOption(
                    'தமிழ்',
                    'ta',
                    languageProvider,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: const Color(0xFF4E6BF5)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String displayName,
    String languageCode,
    LanguageProvider languageProvider,
  ) {
    final isSelected = languageProvider.locale.languageCode == languageCode;
    
    return ListTile(
      leading: Icon(
        Iconsax.global_copy,
        color: isSelected 
          ? const Color(0xFF4E6BF5) 
          : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        displayName,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
        ? Icon(
            Iconsax.tick_circle_copy,
            color: const Color(0xFF4E6BF5),
          )
        : null,
      onTap: () {
        languageProvider.setLocale(Locale(languageCode));
        Navigator.of(context).pop();
      },
    );
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Montserrat'
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Are you sure you want to logout?\nAll data will be removed. This can\'t be undone.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontFamily: 'Montserrat'
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Card(
              color: Theme.of(context).colorScheme.tertiary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: const Color(0xFF4E6BF5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Logging out...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Clear all stored data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // You can add more logout logic here such as:
      // - Clear Hive data
      // - Disconnect from socket
      // - Clear cached images
      // - Reset any global state

      Navigator.of(context).pop(); // Close loading dialog
      
      // Navigate to login screen
      // Navigator.of(context).pushReplacementNamed('/login');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully logged out'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteAccountDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Montserrat'
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Are you sure you want to permanently delete your account? This action cannot be undone.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Montserrat'
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Implement delete account logic here
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account deletion functionality not implemented yet'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4E6BF5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.info_circle_copy,
                  color: const Color(0xFF4E6BF5),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'About Workie',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version: $_currentVersion',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Workie is a platform that connects skilled workers with clients who need their services. Find work opportunities or hire talented professionals in your area.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '© 2025 Workie.lk',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: const Color(0xFF4E6BF5)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearCache() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Card(
            color: Theme.of(context).colorScheme.tertiary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 2,
                      child: Lottie.asset(
                          'assets/animation/cache_cleaner.json',
                          width: 100,
                        height: 80
                      )
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Clearing cache...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Add cache clearing logic here
      await Future.delayed(Duration(seconds: 2)); // Simulate clearing process
      
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cache cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing cache: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: const Color(0xFF4E6BF5),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Iconsax.arrow_left_copy, color: Colors.white),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF4E6BF5).withOpacity(0.2),
                    backgroundImage: NetworkImage(_userProfileImage),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Text(
                          _userEmail,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  /*Icon(
                    Iconsax.edit_copy,
                    color: Theme.of(context).colorScheme.primary,
                  ),*/
                ],
              ),
            ),
            
            const SizedBox(height: 12),

            // General Settings Section
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'General',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Iconsax.notification_copy,
                    title: 'Notifications',
                    subtitle: 'Push notifications and alerts',
                    trailing: Switch.adaptive(
                      value: _notificationsEnabled,
                      onChanged: _saveNotificationSetting,
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF4E6BF5),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Iconsax.location_copy,
                    title: 'Location Services',
                    subtitle: 'Enable location for better job matching',
                    trailing: Switch.adaptive(
                      value: _locationEnabled,
                      onChanged: _saveLocationSetting,
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF4E6BF5),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                    )
                  ),
                  _buildDivider(),
                  Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      return _buildSettingsTile(
                        icon: Iconsax.global_copy,
                        title: 'Language',
                        subtitle: 'Select your preferred language',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              languageProvider.getLanguageDisplayText(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Iconsax.arrow_right_3_copy,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        onTap: _showLanguageDialog,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Iconsax.colorfilter_copy,
                    title: 'Theme',
                    subtitle: 'Appearance and theme settings',
                    trailing: Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: _showThemeDialog,
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Iconsax.trash_copy,
                    title: 'Clear Cache',
                    subtitle: 'Clear app cache and temporary files',
                    trailing: Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: _clearCache,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Account Settings Section
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Iconsax.security_safe_copy,
                    title: 'Privacy & Security',
                    subtitle: 'Manage your privacy settings',
                    trailing: Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Iconsax.briefcase_copy,
                    title: 'Work Categories',
                    subtitle: 'Manage your work categories',
                    trailing: Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkCategoriesPage(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Iconsax.document_text_copy,
                    title: 'Terms & Conditions',
                    subtitle: 'View terms and conditions',
                    trailing: Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () {
                      // Navigate to terms
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const TermsAndPrivacyPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // Start from bottom
                            const end = Offset.zero; // End at normal position
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Support Section
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Support',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Iconsax.message_question_copy,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    trailing: Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Iconsax.star_copy,
                    title: 'Rate App',
                    subtitle: 'Rate us on the app store',
                    trailing: Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () {
                      // Open app store for rating
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Iconsax.info_circle_copy,
                    title: 'About',
                    subtitle: 'App version $_currentVersion',
                    trailing: Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: _showAboutDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Danger Zone Section
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Danger Zone',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Iconsax.logout_copy,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    trailing: Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Colors.red,
                    ),
                    onTap: _showLogoutDialog,
                    titleColor: Colors.red,
                    iconColor: Colors.red,
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Iconsax.trash_copy,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    trailing: Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Colors.red,
                    ),
                    onTap: _showDeleteAccountDialog,
                    titleColor: Colors.red,
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF4E6BF5)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFF4E6BF5),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: titleColor ?? Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      indent: 16,
      endIndent: 16,
    );
  }
}