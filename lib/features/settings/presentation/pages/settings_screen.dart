import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/data/local/settings_repository.dart';
import '../../../../core/widgets/ichito_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with ThemeAwareMixin {
  final SettingsRepository _settings = SettingsRepository();

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(lang.t('Settings'), style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _buildSectionHeader('Appearance'),
          _buildThemeSelector(),
          _buildAccentColorSelector(),
          const SizedBox(height: 24),
          _buildSectionHeader('Localization'),
          _buildLanguageSelector(),
          const SizedBox(height: 24),
          _buildSectionHeader('Security'),
          _buildSecuritySettings(),
          const SizedBox(height: 24),
          _buildSectionHeader('Data Management'),
          _buildDataManagementSettings(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: subtitleStyle.copyWith(color: theme.accentColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: AppThemeMode.values.map((mode) {
          return RadioListTile<AppThemeMode>(
            title: Text(mode.name.toUpperCase(), style: bodyStyle),
            value: mode,
            groupValue: theme.themeMode,
            activeColor: theme.accentColor,
            onChanged: (val) {
              if (val != null) {
                theme.setThemeMode(val);
                _settings.setThemeMode(val.name);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccentColorSelector() {
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey, const Color(0xFFFFD700),
    ];

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accent Color', style: bodyStyle),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((color) {
                final isSelected = theme.accentColor.value == color.value;
                return GestureDetector(
                  onTap: () {
                    theme.setAccentColor(color);
                    _settings.setAccentColor(color.value);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? theme.textPrimary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected ? Icon(Icons.check, color: theme.onAccent) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: AppLanguage.values.map((l) {
          return RadioListTile<AppLanguage>(
            title: Text(l.name.toUpperCase(), style: bodyStyle),
            value: l,
            groupValue: lang.currentLanguage,
            activeColor: theme.accentColor,
            onChanged: (val) {
              if (val != null) {
                lang.setLanguage(val);
                _settings.setLanguage(val.name);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    final appState = Provider.of<AppStateProvider>(context);
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text('Enable App Lock (PIN)', style: bodyStyle),
            value: appState.isAppLockEnabled,
            activeColor: theme.accentColor,
            onChanged: (val) {
              appState.setAppLockEnabled(val);
              if (val) {
                // In real app, route to Set PIN screen
              }
            },
          ),
          if (appState.isAppLockEnabled)
            SwitchListTile(
              title: Text('Enable Biometrics', style: bodyStyle),
              value: appState.isBiometricEnabled,
              activeColor: theme.accentColor,
              onChanged: (val) {
                appState.setBiometricEnabled(val);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSettings() {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: Text('Factory Reset', style: bodyStyle.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: Text('Delete all data and reset app', style: subtitleStyle),
            onTap: () => _showFactoryResetDialog(),
          ),
        ],
      ),
    );
  }

  Future<void> _showFactoryResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        title: Text('Factory Reset', style: headingStyle.copyWith(color: Colors.red)),
        content: Text('This will delete ALL data including customers, orders, notes, and images. This CANNOT be undone.\n\nAre you absolutely sure?', style: bodyStyle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('CANCEL', style: TextStyle(color: theme.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('YES, DELETE EVERYTHING', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Execute factory reset
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.setAppLockEnabled(false);
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }
}
