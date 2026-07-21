import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../shared/data/database/backup_service.dart';
import '../widgets/index.dart';

class StorageSettingsScreen extends StatefulWidget {
  const StorageSettingsScreen({super.key});

  @override
  State<StorageSettingsScreen> createState() => _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends State<StorageSettingsScreen> with ThemeAwareMixin {
  double _databaseSize = 0;
  double _imagesSize = 0;
  double _cacheSize = 0;
  bool _isLoadingSize = true;

  @override
  void initState() {
    super.initState();
    _loadStorageSizes();
  }

  Future<void> _loadStorageSizes() async {
    // TODO: Implement actual storage calculation
    // For now, using placeholder values
    setState(() {
      _databaseSize = 2.4 * 1024 * 1024; // 2.4 MB
      _imagesSize = 45.2 * 1024 * 1024; // 45.2 MB
      _cacheSize = 8.1 * 1024 * 1024; // 8.1 MB
      _isLoadingSize = false;
    });
  }

  Future<void> _backupData() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Backup Summary'.t(context), style: TextStyle(color: theme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Database: ${(_databaseSize / (1024 * 1024)).toStringAsFixed(1)} MB'.t(context), 
              style: TextStyle(color: theme.textSecondary)),
            Text('Images: ${(_imagesSize / (1024 * 1024)).toStringAsFixed(1)} MB'.t(context),
              style: TextStyle(color: theme.textSecondary)),
            Text('Total: ${((_databaseSize + _imagesSize) / (1024 * 1024)).toStringAsFixed(1)} MB'.t(context),
              style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel'.t(context))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Creating backup...'.t(context))),
              );
              try {
                final result = await BackupService().exportBackup();
                if (result != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup created successfully'.t(context))),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup failed: $e'.t(context)), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text('Backup'.t(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Restore Backup?'.t(context), style: TextStyle(color: theme.textPrimary)),
        content: Text(
          'Restoring from backup will REPLACE all current data. This action cannot be undone.'.t(context),
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.t(context))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Restore'.t(context), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restoring backup...'.t(context))),
      );
      try {
        final result = await BackupService().importBackup();
        if (result && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup restored successfully. Restarting app...'.t(context))),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Restore failed: $e'.t(context)), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Clear Cache?'.t(context), style: TextStyle(color: theme.textPrimary)),
        content: Text(
          'This will delete cached image thumbnails. The app will regenerate them on next use.'.t(context),
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.t(context))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear'.t(context)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // TODO: Implement actual cache clearing
      setState(() {
        _cacheSize = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully'.t(context))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSize = _databaseSize + _imagesSize + _cacheSize;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Storage Management'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView(
        padding: EdgeInsets.all(16).copyWith(bottom: 120),
        children: [
          // Storage Overview
          if (_isLoadingSize)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(theme.accentColor)),
              ),
            )
          else
            Column(
              children: [
                StorageUsageBar(
                  label: 'Database'.t(context),
                  usedBytes: _databaseSize,
                  totalBytes: 100 * 1024 * 1024, // 100 MB max
                  color: Colors.blue,
                ),
                StorageUsageBar(
                  label: 'Images'.t(context),
                  usedBytes: _imagesSize,
                  totalBytes: 200 * 1024 * 1024, // 200 MB max
                  color: Colors.green,
                ),
                StorageUsageBar(
                  label: 'Cache'.t(context),
                  usedBytes: _cacheSize,
                  totalBytes: 50 * 1024 * 1024, // 50 MB max
                  color: Colors.orange,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Used'.t(context),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: theme.fontSize, color: theme.textPrimary),
                      ),
                      Text(
                        _formatBytes(totalSize),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: theme.fontSize, color: theme.accentColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          
          SizedBox(height: 24),
          
          // Backup & Restore
          SettingsTile(
            title: 'Backup & Restore'.t(context),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: _backupData,
                  icon: Icon(Icons.cloud_upload_outlined),
                  label: Text('Create Backup'.t(context)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor.withOpacity(0.2),
                    foregroundColor: theme.accentColor,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: _restoreData,
                  icon: Icon(Icons.cloud_download_outlined),
                  label: Text('Restore from Backup'.t(context)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.accentColor),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Cache Management
          SettingsTile(
            title: 'Cache Management'.t(context),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: _clearCache,
                  icon: Icon(Icons.cleaning_services_outlined),
                  label: Text('Clear Cache'.t(context)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Current cache size: ${_formatBytes(_cacheSize)}'.t(context),
                  style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Info
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.accentColor.withOpacity(0.1),
              borderRadius: theme.cornerRadius,
              border: Border.all(color: theme.accentColor.withOpacity(0.3)),
            ),
            child: Text(
              'Backups include your database, images, and all settings. They are stored as encrypted .zip files on your device.'.t(context),
              style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(double bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int suffixIndex = 0;
    double amount = bytes.toDouble();

    while (amount >= 1024 && suffixIndex < suffixes.length - 1) {
      amount /= 1024;
      suffixIndex++;
    }

    return '${amount.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }
}
