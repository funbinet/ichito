import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../shared/providers/language_provider.dart';
import '../../../../../shared/data/local/settings_repository.dart';
import '../widgets/index.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> with ThemeAwareMixin {
  late SettingsRepository _settings;
  late String _selectedLanguage;
  late String _selectedCurrency;
  late String _selectedUnit;
  late String _selectedDateFormat;

  @override
  void initState() {
    super.initState();
    _settings = SettingsRepository();
    _selectedLanguage = _settings.getLanguage();
    _selectedCurrency = _settings.getCurrency();
    _selectedUnit = _settings.getMeasurementUnit();
    _selectedDateFormat = _settings.getDateFormat();
  }

  void _saveSettings() {
    _settings.setLanguage(_selectedLanguage);
    _settings.setCurrency(_selectedCurrency);
    _settings.setMeasurementUnit(_selectedUnit);
    _settings.setDateFormat(_selectedDateFormat);

    final langProv = Provider.of<LanguageProvider>(context, listen: false);
    langProv.setLanguage(_selectedLanguage == 'sheng' ? AppLanguage.sheng : AppLanguage.english);
    langProv.setCurrency(_selectedCurrency);
    langProv.setMeasurementUnit(_selectedUnit);
    langProv.setDateFormat(_selectedDateFormat);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language & Format settings saved'.t(context))),
    );
    Navigator.pop(context);
  }

  String _formatDateExample(String format) {
    final now = DateTime.now();
    switch (format) {
      case 'DD/MM/YYYY':
        return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      case 'MM/DD/YYYY':
        return '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
      case 'YYYY-MM-DD':
        return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      default:
        return format;
    }
  }

  String _formatCurrencyExample(String currency) {
    const examples = {
      'KES': 'KES 1,500.00',
      'USD': '\$1,500.00',
      'EUR': '€1,500.00',
      'GBP': '£1,500.00',
      'TZS': 'TSh 1,500',
      'UGX': 'UGX 1,500,000',
    };
    return examples[currency] ?? '$currency 1,500.00';
  }

  String _formatMeasurementExample(String unit) {
    return unit == 'cm' ? '85 cm' : '33.5 inches';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Language & Format'.t(context), style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView(
        padding: EdgeInsets.all(16).copyWith(bottom: 120),
        children: [
          // Language
          SettingsTile(
            title: 'Language'.t(context),
            children: [
              SettingsDropdown<String>(
                label: 'Select Language'.t(context),
                value: _selectedLanguage,
                items: [
                  DropdownMenuItem(value: 'english', child: Text('English'.t(context))),
                  DropdownMenuItem(value: 'sheng', child: Text('Sheng'.t(context))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedLanguage = value);
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  _selectedLanguage == 'english' ? 'Full interface language' : 'Sheng slang with English fallbacks',
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Measurement Unit
          SettingsTile(
            title: 'Measurement Unit'.t(context),
            children: [
              SettingsDropdown<String>(
                label: 'Select Unit'.t(context),
                value: _selectedUnit,
                items: [
                  DropdownMenuItem(value: 'cm', child: Text('Centimeters (cm)'.t(context))),
                  DropdownMenuItem(value: 'inches', child: Text('Inches'.t(context))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedUnit = value);
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Example: ${_formatMeasurementExample(_selectedUnit)}'.t(context),
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Currency
          SettingsTile(
            title: 'Currency'.t(context),
            children: [
              SettingsDropdown<String>(
                label: 'Select Currency'.t(context),
                value: _selectedCurrency,
                items: [
                  DropdownMenuItem(value: 'KES', child: Text('KES - Kenya Shilling'.t(context))),
                  DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar'.t(context))),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro'.t(context))),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound'.t(context))),
                  DropdownMenuItem(value: 'TZS', child: Text('TZS - Tanzania Shilling'.t(context))),
                  DropdownMenuItem(value: 'UGX', child: Text('UGX - Uganda Shilling'.t(context))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCurrency = value);
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Example: ${_formatCurrencyExample(_selectedCurrency)}'.t(context),
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Date Format
          SettingsTile(
            title: 'Date Format'.t(context),
            children: [
              SettingsDropdown<String>(
                label: 'Select Date Format'.t(context),
                value: _selectedDateFormat,
                items: [
                  DropdownMenuItem(value: 'DD/MM/YYYY', child: Text('DD/MM/YYYY'.t(context))),
                  DropdownMenuItem(value: 'MM/DD/YYYY', child: Text('MM/DD/YYYY'.t(context))),
                  DropdownMenuItem(value: 'YYYY-MM-DD', child: Text('YYYY-MM-DD'.t(context))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDateFormat = value);
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Example: ${_formatDateExample(_selectedDateFormat)}'.t(context),
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // Save button
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
            ),
            child: Text(
              'Save Settings'.t(context),
              style: TextStyle(
                color: theme.onAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
