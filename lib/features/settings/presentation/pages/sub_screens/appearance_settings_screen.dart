import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../shared/providers/theme_provider.dart';
import '../../../../../shared/providers/language_provider.dart';
import '../../../../../shared/data/local/settings_repository.dart';
import '../../../../../core/widgets/ichito_scaffold.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> with ThemeAwareMixin {
  final SettingsRepository _settings = SettingsRepository();

  void _showColorPicker() {
    Color pickerColor = theme.accentColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text('Pick Accent Color'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.t(context), style: TextStyle(color: theme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                theme.setAccentColor(pickerColor);
                _settings.setAccentColor(pickerColor.value);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
              child: Text('Select'.t(context), style: TextStyle(color: theme.onAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Appearance'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Theme Mode'),
          _buildThemeSelector(),
          SizedBox(height: 24),
          _buildSectionHeader('Colors'),
          _buildColorSettings(),
          _buildSectionHeader('Typography'),
          _buildFontFamilySettings(),
          SizedBox(height: 24),
          _buildSectionHeader('Global Font Size'),
          _buildFontSizeSettings(),
          SizedBox(height: 24),
          _buildSectionHeader('Corner Styles'),
          _buildCornerSettings(),
          SizedBox(height: 24),
          _buildSectionHeader('Gradient Themes (15 Options)'),
          _buildGradientSettings(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildColorSettings() {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: ListTile(
        title: Text('Accent Color'.t(context), style: bodyStyle),
        subtitle: Text('Tap to change the primary accent color'.t(context), style: subtitleStyle),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.accentColor,
            shape: BoxShape.circle,
            border: Border.all(color: theme.borderColor),
          ),
        ),
        onTap: _showColorPicker,
      ),
    );
  }

  Widget _buildFontFamilySettings() {
    final fonts = ['Roboto', 'Open Sans', 'Lato', 'Montserrat', 'Poppins'];
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: fonts.map((font) {
          return RadioListTile<String>(
            title: Text(font, style: TextStyle(fontFamily: font, fontSize: theme.fontSize, color: theme.textPrimary)),
            value: font,
            groupValue: theme.fontFamily,
            activeColor: theme.accentColor,
            onChanged: (val) {
              if (val != null) {
                theme.setFontFamily(val);
                _settings.setFontFamily(val);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFontSizeSettings() {
    final sizes = [
      {'label': 'Extra Small', 'value': 12.0},
      {'label': 'Small', 'value': 14.0},
      {'label': 'Medium (Default)', 'value': 16.0},
      {'label': 'Large', 'value': 18.0},
      {'label': 'Extra Large', 'value': 20.0},
      {'label': 'Huge', 'value': 24.0},
    ];

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          ...sizes.map((size) {
            return RadioListTile<double>(
              title: Text(size['label'] as String, style: bodyStyle),
              value: size['value'] as double,
              groupValue: theme.fontSize,
              activeColor: theme.accentColor,
              onChanged: (val) {
                if (val != null) {
                  theme.setFontSize(val);
                }
              },
            );
          }),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Sample Text Preview'.t(context),
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontSize: theme.fontSize,
                color: theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerSettings() {
    final styles = [
      CornerStyle.rounded,
      CornerStyle.sharp,
    ];

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: styles.map((style) {
          return RadioListTile<CornerStyle>(
            title: Text(style.name.toUpperCase(), style: bodyStyle),
            value: style,
            groupValue: theme.cornerStyle,
            activeColor: theme.accentColor,
            onChanged: (val) {
              if (val != null) {
                theme.setCornerStyle(val);
                // Assume _settings.setCornerStyle exists, or skip persistence for now
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGradientSettings() {
    final List<Color> gradientThemes = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFF6200EA), // Purple
      const Color(0xFFF44336), // Red
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Deep Purple
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF2196F3), // Blue
      const Color(0xFF03A9F4), // Light Blue
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF009688), // Teal
      const Color(0xFF4CAF50), // Green
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF607D8B), // Blue Grey
    ];

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text('Use Gradient Accents'.t(context), style: bodyStyle),
            subtitle: Text('Apply gradients instead of solid colors'.t(context), style: subtitleStyle),
            value: theme.useGradients,
            activeColor: theme.accentColor,
            onChanged: (val) {
              theme.setUseGradients(val);
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: gradientThemes.map((color) {
                final isSelected = theme.accentColor.value == color.value;
                return GestureDetector(
                  onTap: () {
                    theme.setAccentColor(color);
                    _settings.setAccentColor(color.value);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: isSelected ? theme.textPrimary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
