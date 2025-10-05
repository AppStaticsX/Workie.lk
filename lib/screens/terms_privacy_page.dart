import 'package:flutter/material.dart';

class TermsAndPrivacyPage extends StatelessWidget {
  const TermsAndPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Legal Information'),
          backgroundColor: const Color(0xFF4E6BF5),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Terms of Use'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TermsOfUseTab(),
            PrivacyPolicyTab(),
          ],
        ),
      ),
    );
  }
}

class TermsOfUseTab extends StatelessWidget {
  const TermsOfUseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms of Use',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last Updated: ${_getCurrentDate()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            '1. Acceptance of Terms',
            'By accessing and using Workie, you accept and agree to be bound by these Terms of Use. If you do not agree to these terms, please do not use our service.',
          ),
          _buildSection(
            context,
            '2. Description of Service',
            'Workie is a platform that connects skilled workers (including masons, carpenters, tile workers, and other tradespeople) with individuals and businesses seeking their services. We provide a marketplace for posting job opportunities and finding work.',
          ),
          _buildSection(
            context,
            '3. User Accounts',
            'You must create an account to use certain features of Workie. You are responsible for:\n\n• Maintaining the confidentiality of your account credentials\n• All activities that occur under your account\n• Providing accurate and current information\n• Notifying us immediately of any unauthorized use',
          ),
          _buildSection(
            context,
            '4. User Responsibilities',
            'Workers agree to:\n\n• Provide accurate information about skills and experience\n• Complete jobs professionally and in good faith\n• Comply with all applicable laws and regulations\n• Not misrepresent qualifications or credentials\n\nEmployers/Job Posters agree to:\n\n• Provide accurate job descriptions and requirements\n• Pay agreed-upon wages in a timely manner\n• Maintain a safe working environment\n• Comply with labor laws and regulations',
          ),
          _buildSection(
            context,
            '5. Prohibited Conduct',
            'You may not:\n\n• Post false, misleading, or fraudulent information\n• Harass, threaten, or intimidate other users\n• Use the platform for illegal activities\n• Attempt to circumvent platform fees or payments\n• Share login credentials with others\n• Scrape or copy content without permission',
          ),
          _buildSection(
            context,
            '6. Payments and Fees',
            'Workie may charge service fees for connecting workers with jobs. All fees will be clearly disclosed before transactions. Users are responsible for applicable taxes. Payment disputes should be reported within 30 days.',
          ),
          _buildSection(
            context,
            '7. Intellectual Property',
            'All content on Workie, including logos, text, graphics, and software, is owned by Workie or its licensors. You may not copy, modify, or distribute our content without permission.',
          ),
          _buildSection(
            context,
            '8. Disclaimer of Warranties',
            'Workie is provided "as is" without warranties of any kind. We do not guarantee:\n\n• Job availability or quality\n• Worker skills or reliability\n• Uninterrupted or error-free service\n• Results from using the platform',
          ),
          _buildSection(
            context,
            '9. Limitation of Liability',
            'Workie is not liable for:\n\n• Disputes between workers and employers\n• Quality of work performed\n• Injuries or damages occurring during jobs\n• Loss of income or business opportunities\n• Indirect or consequential damages',
          ),
          _buildSection(
            context,
            '10. Termination',
            'We reserve the right to suspend or terminate accounts that violate these terms. You may terminate your account at any time by contacting support.',
          ),
          _buildSection(
            context,
            '11. Changes to Terms',
            'We may modify these terms at any time. Continued use of Workie after changes constitutes acceptance of the new terms.',
          ),
          _buildSection(
            context,
            '12. Contact Information',
            'For questions about these Terms of Use, contact us at:\n\nEmail: support.workie@gmail.com',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyTab extends StatelessWidget {
  const PrivacyPolicyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last Updated: ${_getCurrentDate()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            '1. Introduction',
            'Workie ("we," "our," or "us") respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
          ),
          _buildSection(
            context,
            '2. Information We Collect',
            'We collect several types of information:\n\nPersonal Information:\n• Name and contact details (email, phone number)\n• Profile photo\n• Location information\n• Work history and skills\n• Government ID for verification (if applicable)\n• Payment information\n\nUsage Information:\n• App usage statistics\n• Device information\n• IP address\n• Log data\n• Search queries and preferences',
          ),
          _buildSection(
            context,
            '3. How We Use Your Information',
            'We use your information to:\n\n• Connect workers with job opportunities\n• Process payments and transactions\n• Verify identities and maintain platform security\n• Communicate about jobs, services, and updates\n• Improve our services and user experience\n• Comply with legal obligations\n• Send promotional materials (with consent)\n• Analyze platform usage and trends',
          ),
          _buildSection(
            context,
            '4. Information Sharing',
            'We may share your information with:\n\n• Other users as necessary to facilitate jobs\n• Payment processors for transactions\n• Service providers who assist our operations\n• Law enforcement when required by law\n• Business partners with your consent\n\nWe do not sell your personal information to third parties.',
          ),
          _buildSection(
            context,
            '5. Location Information',
            'We collect location data to:\n\n• Show nearby job opportunities\n• Help workers find local jobs\n• Display accurate service areas\n• Improve location-based features\n\nYou can disable location services in your device settings, but this may limit functionality.',
          ),
          _buildSection(
            context,
            '6. Data Security',
            'We implement security measures to protect your information, including:\n\n• Encryption of sensitive data\n• Secure servers and databases\n• Regular security audits\n• Access controls and authentication\n\nHowever, no method of transmission over the internet is 100% secure.',
          ),
          _buildSection(
            context,
            '7. Data Retention',
            'We retain your information for as long as:\n\n• Your account is active\n• Needed to provide services\n• Required by law\n• Necessary for legitimate business purposes\n\nYou may request deletion of your data at any time.',
          ),
          _buildSection(
            context,
            '8. Your Rights',
            'You have the right to:\n\n• Access your personal information\n• Correct inaccurate data\n• Delete your account and data\n• Opt-out of marketing communications\n• Restrict processing of your data\n• Export your data\n\nContact us to exercise these rights.',
          ),
          _buildSection(
            context,
            '9. Children\'s Privacy',
            'Workie is not intended for users under 18 years of age. We do not knowingly collect information from children. If we learn we have collected data from a child, we will delete it immediately.',
          ),
          _buildSection(
            context,
            '10. Cookies and Tracking',
            'We use cookies and similar technologies to:\n\n• Remember your preferences\n• Analyze app usage\n• Improve performance\n• Provide personalized content\n\nYou can manage cookie preferences in your device settings.',
          ),
          _buildSection(
            context,
            '11. Third-Party Services',
            'Our app may contain links to third-party services. We are not responsible for the privacy practices of these external sites. Please review their privacy policies.',
          ),
          _buildSection(
            context,
            '12. Changes to Privacy Policy',
            'We may update this Privacy Policy periodically. We will notify you of significant changes through the app or via email. Continued use after changes constitutes acceptance.',
          ),
          _buildSection(
            context,
            '13. Contact Us',
            'For questions or concerns about this Privacy Policy or your data, contact us at:\n\nEmail: support.workie@gmail.com',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

String _getCurrentDate() {
  final now = DateTime.now();
  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return '${months[now.month - 1]} ${now.day}, ${now.year}';
}