import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with ThemeAwareMixin {
  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(lang.t('Settings') ?? 'Settings', style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16).copyWith(bottom: 120),
        children: [
          _buildSettingsTile(
            title: 'Profile Settings',
            subtitle: 'Personal & business information',
            icon: Icons.person_outline,
            onTap: () => Navigator.pushNamed(context, '/settings/profile'),
          ),
          _buildSettingsTile(
            title: 'Appearance Settings',
            subtitle: 'Theme, colors, and gradients',
            icon: Icons.palette_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/appearance'),
          ),
          _buildSettingsTile(
            title: 'Language & Format',
            subtitle: 'Language, units, currency & dates',
            icon: Icons.language_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/language'),
          ),
          _buildSettingsTile(
            title: 'Security Settings',
            subtitle: 'App lock, biometrics, PIN',
            icon: Icons.security_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/security'),
          ),
          _buildSettingsTile(
            title: 'Preferences Settings',
            subtitle: 'Display, interaction & default sort',
            icon: Icons.tune_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/preferences'),
          ),
          _buildSettingsTile(
            title: 'Business Settings',
            subtitle: 'Financials, tax & order prefixes',
            icon: Icons.business_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/business'),
          ),
          _buildSettingsTile(
            title: 'Storage Management',
            subtitle: 'Usage, backup, restore & cache',
            icon: Icons.storage_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/storage'),
          ),
          _buildSettingsTile(
            title: 'Advanced Settings',
            subtitle: 'Performance mode & debugging',
            icon: Icons.build_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/advanced'),
          ),
          _buildSettingsTile(
            title: 'Help',
            subtitle: 'User guide and support',
            icon: Icons.help_outline,
            onTap: () => Navigator.pushNamed(context, '/settings/help'),
          ),
          _buildSettingsTile(
            title: 'About',
            subtitle: 'Version info and legal',
            icon: Icons.info_outline,
            onTap: () => Navigator.pushNamed(context, '/settings/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.borderColor),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? theme.accentColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? theme.accentColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? theme.textPrimary,
            fontFamily: theme.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: theme.textSecondary,
            fontFamily: theme.fontFamily,
            fontSize: theme.fontSize * 0.85,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: theme.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
