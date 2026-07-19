import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with ThemeAwareMixin {
  static const String _appVersion = '4.0.0';
  static const String _buildNumber = '1';

  Future<void> _openUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $e')),
      );
    }
  }

  void _sendEmail() {
    _openUrl('mailto:support@ichito.app?subject=ICHITO Support - v$_appVersion&body=');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('About ICHITO', style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16).copyWith(bottom: 120),
        children: [
          // App Logo and Title
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.accentColor.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: Icon(
                  Icons.checkroom_outlined,
                  size: 60,
                  color: theme.accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App Name
          Center(
            child: Text(
              'ICHITO',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Version
          Center(
            child: Text(
              'Version $_appVersion (Build $_buildNumber)',
              style: TextStyle(
                fontSize: 14,
                color: theme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Tagline
          Center(
            child: Text(
              '"Work. Create. Thrive."',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: theme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: theme.cornerRadius,
              border: Border.all(color: theme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'ICHITO is a complete tailor management system built with care for tailors everywhere.\n\n'
                  '"Ichito" means "to work" or "work/job" in Sheng (Kenyan slang).\n\n'
                  'The app combines premium aesthetics with powerful functionality to help you manage your tailoring business offline, anytime, anywhere.',
                  style: TextStyle(
                    color: theme.textSecondary,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Technology
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: theme.cornerRadius,
              border: Border.all(color: theme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Built With',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Powered by Flutter & Dart\n'
                  'SQLite for local data storage\n'
                  'Clean Architecture with Provider state management',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          ElevatedButton.icon(
            onPressed: _sendEmail,
            icon: const Icon(Icons.mail_outline),
            label: const Text('Contact Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              foregroundColor: theme.onAccent,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              _openUrl('https://ichito.app/privacy');
            },
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('Privacy Policy'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
              side: BorderSide(color: theme.borderColor),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              _openUrl('https://ichito.app/licenses');
            },
            icon: const Icon(Icons.description_outlined),
            label: const Text('Open Source Licenses'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
              side: BorderSide(color: theme.borderColor),
            ),
          ),
          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              '© 2026 ICHITO. All rights reserved.\n'
              'Licensed under MIT License',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: theme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
