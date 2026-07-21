import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/ichito_scaffold.dart';

import '../../../../../shared/data/database/backup_service.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> with ThemeAwareMixin {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;

  Future<void> _handleBackup() async {
    setState(() => _isLoading = true);
    final path = await _backupService.exportBackup();
    setState(() => _isLoading = false);
    
    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup successful!'.t(context)), backgroundColor: theme.accentColor),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed.'.t(context)), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    final success = await _backupService.importBackup();
    setState(() => _isLoading = false);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore successful! Please restart the app.'.t(context)), backgroundColor: theme.accentColor),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore cancelled or failed.'.t(context)), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Backup & Restore'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                Card(
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
                  child: ListTile(
                    leading: Icon(Icons.backup, color: theme.accentColor, size: 32),
                    title: Text('Backup Data'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                    subtitle: Text('Save a copy of your database and images to a zip file.'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                    onTap: _isLoading ? null : _handleBackup,
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
                  child: ListTile(
                    leading: Icon(Icons.restore, color: theme.accentColor, size: 32),
                    title: Text('Restore Data'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                    subtitle: Text('Restore database and images from a backup zip file.'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                    onTap: _isLoading ? null : _handleRestore,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(color: theme.accentColor),
              ),
            ),
        ],
      ),
    );
  }
}
