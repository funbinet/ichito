import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/data/local/settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with ThemeAwareMixin {
  final SettingsRepository _settings = SettingsRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('Settings'), style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
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
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
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
                  onTap: () => theme.setAccentColor(color),
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
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
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
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
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
}
