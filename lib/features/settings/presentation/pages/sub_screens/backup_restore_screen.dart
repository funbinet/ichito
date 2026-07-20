import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/ichito_scaffold.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> with ThemeAwareMixin {
  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Backup & Restore'.t(context), style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
              child: ListTile(
                leading: Icon(Icons.backup, color: theme.accentColor, size: 32),
                title: Text('Backup Data'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                subtitle: Text('Save a copy of your database to local storage.'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Database backed up successfully!'.t(context)), backgroundColor: theme.accentColor),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
              child: ListTile(
                leading: Icon(Icons.restore, color: theme.accentColor, size: 32),
                title: Text('Restore Data'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                subtitle: Text('Restore database from a backup file.'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please pick a valid backup file.'.t(context)), backgroundColor: Colors.orange),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
