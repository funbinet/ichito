import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/widgets/auth_delete_dialog.dart';
import '../../../security/services/security_service.dart';
import '../../../../shared/data/database/backup_service.dart';
import '../../../../core/widgets/ichito_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with ThemeAwareMixin {

  void _showFactoryResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AuthDeleteDialog(
        itemName: 'ALL APP DATA',
        securityService: SecurityService(),
        onDelete: () async {
          // Perform factory reset logic here
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
      ),
    );
  }

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
            title: 'Profile',
            subtitle: 'Personal & business information',
            icon: Icons.person_outline,
            onTap: () => Navigator.pushNamed(context, '/settings/profile'),
          ),
          _buildSettingsTile(
            title: 'Appearance',
            subtitle: 'Theme, colors, and gradients',
            icon: Icons.palette_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/appearance'),
          ),
          _buildSettingsTile(
            title: 'Localization',
            subtitle: 'Language and region settings',
            icon: Icons.language_outlined,
            onTap: () {
              // Show language selector dialog or navigate
            },
          ),
          _buildSettingsTile(
            title: 'Notifications',
            subtitle: 'Alerts and push notifications',
            icon: Icons.notifications_outlined,
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          _buildSettingsTile(
            title: 'Security',
            subtitle: 'App lock, biometrics, PIN',
            icon: Icons.security_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/security'),
          ),
          _buildSettingsTile(
            title: 'Backup Data',
            subtitle: 'Export a local .zip backup',
            icon: Icons.cloud_download_outlined,
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparing backup...')));
              final result = await BackupService().exportBackup();
              if (result != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup ready to share')));
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup failed')));
              }
            },
          ),
          _buildSettingsTile(
            title: 'Restore Data',
            subtitle: 'Import a local .zip backup',
            icon: Icons.restore_outlined,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: theme.cardColor,
                  title: Text('Restore Backup?', style: TextStyle(color: theme.textPrimary)),
                  content: Text('This will overwrite all current data. This action cannot be undone.', 
                    style: TextStyle(color: theme.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Restore', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                final success = await BackupService().importBackup();
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore successful. Restarting app...')));
                  // Restart to reload state
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore failed')));
                }
              }
            },
          ),
          _buildSettingsTile(
            title: 'Feedback',
            subtitle: 'Report bugs or request features',
            icon: Icons.feedback_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback feature coming soon')));
            },
          ),
          _buildSettingsTile(
            title: 'Share App',
            subtitle: 'Share ICHITO with friends',
            icon: Icons.share_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share feature coming soon')));
            },
          ),
          _buildSettingsTile(
            title: 'About',
            subtitle: 'App version and information',
            icon: Icons.info_outline,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            title: 'Factory Reset',
            subtitle: 'Delete all data and reset app',
            icon: Icons.delete_forever_outlined,
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: _showFactoryResetDialog,
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
