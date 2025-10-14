import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _profileVisibility = true;
  bool _showOnlineStatus = true;
  bool _allowDirectMessages = true;
  bool _showContactInfo = false;
  bool _shareAnalytics = true;
  bool _marketingEmails = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _profileVisibility = prefs.getBool('profile_visibility') ?? true;
        _showOnlineStatus = prefs.getBool('show_online_status') ?? true;
        _allowDirectMessages = prefs.getBool('allow_direct_messages') ?? true;
        _showContactInfo = prefs.getBool('show_contact_info') ?? false;
        _shareAnalytics = prefs.getBool('share_analytics') ?? true;
        _marketingEmails = prefs.getBool('marketing_emails') ?? false;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _savePrivacySetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      // Handle error
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
          'Privacy & Security',
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
            const SizedBox(height: 12),

            // Profile Privacy Section
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Profile Privacy',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  _buildPrivacyTile(
                    icon: Iconsax.eye_copy,
                    title: 'Profile Visibility',
                    subtitle: 'Allow others to see your profile',
                    value: _profileVisibility,
                    onChanged: (value) {
                      setState(() => _profileVisibility = value);
                      _savePrivacySetting('profile_visibility', value);
                    },
                  ),
                  _buildDivider(),
                  _buildPrivacyTile(
                    icon: Iconsax.status_copy,
                    title: 'Online Status',
                    subtitle: 'Show when you are online',
                    value: _showOnlineStatus,
                    onChanged: (value) {
                      setState(() => _showOnlineStatus = value);
                      _savePrivacySetting('show_online_status', value);
                    },
                  ),
                  _buildDivider(),
                  _buildPrivacyTile(
                    icon: Iconsax.sms_copy,
                    title: 'Direct Messages',
                    subtitle: 'Allow others to send you direct messages',
                    value: _allowDirectMessages,
                    onChanged: (value) {
                      setState(() => _allowDirectMessages = value);
                      _savePrivacySetting('allow_direct_messages', value);
                    },
                  ),
                  _buildDivider(),
                  _buildPrivacyTile(
                    icon: Iconsax.call_copy,
                    title: 'Contact Information',
                    subtitle: 'Show contact info on your profile',
                    value: _showContactInfo,
                    onChanged: (value) {
                      setState(() => _showContactInfo = value);
                      _savePrivacySetting('show_contact_info', value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Data Privacy Section
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Data Privacy',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  _buildPrivacyTile(
                    icon: Iconsax.chart_copy,
                    title: 'Analytics Data',
                    subtitle: 'Help improve the app by sharing usage data',
                    value: _shareAnalytics,
                    onChanged: (value) {
                      setState(() => _shareAnalytics = value);
                      _savePrivacySetting('share_analytics', value);
                    },
                  ),
                  _buildDivider(),
                  _buildPrivacyTile(
                    icon: Iconsax.sms_notification_copy,
                    title: 'Marketing Emails',
                    subtitle: 'Receive promotional emails and updates',
                    value: _marketingEmails,
                    onChanged: (value) {
                      setState(() => _marketingEmails = value);
                      _savePrivacySetting('marketing_emails', value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Security Actions Section
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Security Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  _buildActionTile(
                    icon: Iconsax.key_copy,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () {
                      // Navigate to change password screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Change password functionality not implemented yet'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: Iconsax.security_time_copy,
                    title: 'Two-Factor Authentication',
                    subtitle: 'Add an extra layer of security',
                    onTap: () {
                      // Navigate to 2FA setup
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Two-factor authentication not implemented yet'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: Iconsax.devices_copy,
                    title: 'Active Sessions',
                    subtitle: 'Manage your active login sessions',
                    onTap: () {
                      // Show active sessions
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Active sessions management not implemented yet'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: Iconsax.document_download_copy,
                    title: 'Download My Data',
                    subtitle: 'Request a copy of your data',
                    onTap: () {
                      _showDataDownloadDialog();
                    },
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

  Widget _buildPrivacyTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4E6BF5).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4E6BF5),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFF4E6BF5),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4E6BF5).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4E6BF5),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3_copy,
        color: Theme.of(context).colorScheme.primary,
      ),
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

  void _showDataDownloadDialog() {
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
                  Iconsax.document_download_copy,
                  color: const Color(0xFF4E6BF5),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Download Data',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'We will prepare a copy of your data and send it to your registered email address within 24 hours.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data download request submitted'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                'Request',
                style: TextStyle(color: const Color(0xFF4E6BF5), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}