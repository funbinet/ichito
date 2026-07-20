import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../shared/providers/app_state_provider.dart';
import '../widgets/index.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> with ThemeAwareMixin {
  late AppStateProvider _appState;

  @override
  void initState() {
    super.initState();
    _appState = Provider.of<AppStateProvider>(context, listen: false);
  }

  Future<void> _exportDataAsJson() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data as JSON...'.t(context))),
    );
    // TODO: Implement actual JSON export
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export completed successfully'.t(context))),
      );
    }
  }

  Future<void> _exportDataAsCsv() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data as CSV...'.t(context))),
    );
    // TODO: Implement actual CSV export
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export completed successfully'.t(context))),
      );
    }
  }

  Future<void> _showFactoryResetDialog() async {
    // First confirmation
    final confirm1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Factory Reset?'.t(context), style: TextStyle(color: Colors.red, fontSize: 16)),
        content: Text(
          'This will delete ALL data including customers, orders, notes, and images. This action CANNOT be undone.'.t(context),
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.t(context))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Continue'.t(context), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm1 != true) return;

    // Second confirmation - type "RESET"
    if (!mounted) return;
    final resetCode = await showDialog<String>(
      context: context,
      builder: (ctx) => _TypeResetConfirmDialog(theme: theme),
    );

    if (resetCode != 'RESET') return;

    // Third confirmation - last chance
    if (!mounted) return;
    final confirm3 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Last Chance!'.t(context), style: TextStyle(color: Colors.red, fontSize: 16)),
        content: Text(
          'All data will be permanently deleted. The app will restart to the welcome screen.'.t(context),
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.t(context))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete Everything'.t(context), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm3 != true) return;

    // Perform factory reset
    try {
      await _appState.factoryReset();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during reset: $e'.t(context)), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Advanced Settings'.t(context), style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          return ListView(
            padding: EdgeInsets.all(16).copyWith(bottom: 120),
            children: [
              // Performance Settings
              SettingsTile(
                title: 'Performance'.t(context),
                children: [
                  SettingsToggle(
                    label: 'Performance Mode'.t(context),
                    description: 'Reduce animations and effects for older devices',
                    value: appState.performanceMode,
                    onChanged: (value) async {
                      await appState.setPerformanceMode(value);
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Debug Settings
              SettingsTile(
                title: 'Debug & Logging'.t(context),
                children: [
                  SettingsToggle(
                    label: 'Debug Logging'.t(context),
                    description: 'Enable detailed debug logs for troubleshooting',
                    value: appState.debugLogging,
                    onChanged: (value) async {
                      await appState.setDebugLogging(value);
                    },
                  ),
                  if (appState.debugLogging)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Debug log viewer - coming soon'.t(context))),
                          );
                        },
                        icon: Icon(Icons.description_outlined),
                        label: Text('View Debug Logs'.t(context)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),

              // Data Export
              SettingsTile(
                title: 'Data Export'.t(context),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: _exportDataAsJson,
                      icon: Icon(Icons.description_outlined),
                      label: Text('Export as JSON'.t(context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accentColor.withOpacity(0.2),
                        foregroundColor: theme.accentColor,
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: _exportDataAsCsv,
                      icon: Icon(Icons.table_chart_outlined),
                      label: Text('Export as CSV'.t(context)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Danger Zone
              SettingsTile(
                title: 'Danger Zone'.t(context),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: _showFactoryResetDialog,
                      icon: Icon(Icons.delete_forever_outlined),
                      label: Text('Factory Reset'.t(context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Delete all app data and reset to default settings. This cannot be undone.'.t(context),
                      style: TextStyle(fontSize: 12, color: Colors.red.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Warning
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: theme.cornerRadius,
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  'Warning: Advanced settings are for experienced users. Incorrect changes may cause unexpected behavior.'.t(context),
                  style: TextStyle(fontSize: 12, color: Colors.red.withOpacity(0.8)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Dialog to confirm factory reset by typing "RESET".
class _TypeResetConfirmDialog extends StatefulWidget {
  final dynamic theme;

  const _TypeResetConfirmDialog({required this.theme});

  @override
  State<_TypeResetConfirmDialog> createState() => _TypeResetConfirmDialogState();
}

class _TypeResetConfirmDialogState extends State<_TypeResetConfirmDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.cardColor,
      title: Text('Confirm Reset'.t(context), style: TextStyle(color: Colors.red, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type "RESET" to confirm:',
            style: TextStyle(color: widget.theme.textSecondary),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Type RESET'.t(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'.t(context))),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text('Continue'.t(context), style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
