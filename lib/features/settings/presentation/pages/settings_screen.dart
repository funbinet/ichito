import 'package:ichito/shared/providers/language_provider.dart';
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
        padding: EdgeInsets.all(16).copyWith(bottom: 120),
        children: [
          _buildSettingsTile(
            title: 'Profile Settings'.t(context),
            subtitle: 'Personal & business information'.t(context),
            icon: Icons.person_outline,
            onTap: () => Navigator.pushNamed(context, '/settings/profile'),
          ),
          _buildSettingsTile(
            title: 'Appearance Settings'.t(context),
            subtitle: 'Theme, colors, and gradients'.t(context),
            icon: Icons.palette_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/appearance'),
          ),
          _buildSettingsTile(
            title: 'Language & Format'.t(context),
            subtitle: 'Language, units, currency & dates'.t(context),
            icon: Icons.language_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/language'),
          ),
          _buildSettingsTile(
            title: 'Security Settings'.t(context),
            subtitle: 'App lock, biometrics, PIN'.t(context),
            icon: Icons.security_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/security'),
          ),
          _buildSettingsTile(
            title: 'Preferences Settings'.t(context),
            subtitle: 'Display, interaction & default sort'.t(context),
            icon: Icons.tune_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/preferences'),
          ),
          _buildSettingsTile(
            title: 'Measurement Types'.t(context),
            subtitle: 'Configure global garment measurements'.t(context),
            icon: Icons.straighten_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/measurements'),
          ),
          _buildSettingsTile(
            title: 'Backup & Restore'.t(context),
            subtitle: 'Backup or restore data from device'.t(context),
            icon: Icons.restore_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/backup'),
          ),
          _buildSettingsTile(
            title: 'Help'.t(context),
            subtitle: 'User guide and support'.t(context),
            icon: Icons.help_outline,
            onTap: () => Navigator.pushNamed(context, '/settings/help'),
          ),
          _buildSettingsTile(
            title: 'About'.t(context),
            subtitle: 'Version info and legal'.t(context),
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
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.borderColor),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
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
