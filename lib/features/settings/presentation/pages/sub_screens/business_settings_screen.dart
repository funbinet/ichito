import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../shared/providers/profile_provider.dart';
import '../../../../../shared/data/local/settings_repository.dart';
import '../widgets/index.dart';

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> with ThemeAwareMixin {
  late SettingsRepository _settings;
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _laborCostController;
  late TextEditingController _taxRateController;
  late TextEditingController _orderPrefixController;

  @override
  void initState() {
    super.initState();
    _settings = SettingsRepository();
    
    _nameController = TextEditingController(text: _settings.getBusinessName());
    _locationController = TextEditingController(text: _settings.getBusinessLocation());
    _phoneController = TextEditingController(text: _settings.getBusinessPhone());
    _emailController = TextEditingController(text: _settings.getBusinessEmail());
    _laborCostController = TextEditingController(text: _settings.getDefaultLaborCost().toString());
    _taxRateController = TextEditingController(text: _settings.getTaxRate().toString());
    _orderPrefixController = TextEditingController(text: _settings.getOrderPrefix());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _laborCostController.dispose();
    _taxRateController.dispose();
    _orderPrefixController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    try {
      // Save business settings to repository
      await Future.wait([
        _settings.setBusinessName(_nameController.text),
        _settings.setBusinessLocation(_locationController.text),
        _settings.setBusinessPhone(_phoneController.text),
        _settings.setBusinessEmail(_emailController.text),
        _settings.setDefaultLaborCost(double.tryParse(_laborCostController.text) ?? 1500.0),
        _settings.setTaxRate(double.tryParse(_taxRateController.text) ?? 0.0),
        _settings.setOrderPrefix(_orderPrefixController.text.isNotEmpty ? _orderPrefixController.text : 'ICHITO'),
      ]);

      // Also update profile provider if available
      if (mounted) {
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        await profileProvider.setTaxRate(double.tryParse(_taxRateController.text) ?? 0.0);
        await profileProvider.setOrderPrefix(_orderPrefixController.text.isNotEmpty ? _orderPrefixController.text : 'ICHITO');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business settings saved successfully'.t(context))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e'.t(context)), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Business Settings'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView(
        padding: EdgeInsets.all(16).copyWith(bottom: 120),
        children: [
          // Business Information
          SettingsTile(
            title: 'Business Information'.t(context),
            children: [
              SettingsTextField(
                label: 'Business Name'.t(context),
                initialValue: _nameController.text,
                onChanged: (value) => _nameController.text = value,
                hintText: 'e.g., Ichito Studios'.t(context),
              ),
              SettingsTextField(
                label: 'Location'.t(context),
                initialValue: _locationController.text,
                onChanged: (value) => _locationController.text = value,
                hintText: 'e.g., Nairobi, Kenya'.t(context),
              ),
              SettingsTextField(
                label: 'Phone'.t(context),
                initialValue: _phoneController.text,
                onChanged: (value) => _phoneController.text = value,
                keyboardType: TextInputType.phone,
                hintText: 'e.g., +254 712 345 678'.t(context),
              ),
              SettingsTextField(
                label: 'Email'.t(context),
                initialValue: _emailController.text,
                onChanged: (value) => _emailController.text = value,
                keyboardType: TextInputType.emailAddress,
                hintText: 'e.g., contact@ichito.app'.t(context),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Financial Settings
          SettingsTile(
            title: 'Financial Settings'.t(context),
            children: [
              SettingsTextField(
                label: 'Default Labor Cost'.t(context),
                initialValue: _laborCostController.text,
                onChanged: (value) => _laborCostController.text = value,
                keyboardType: TextInputType.number,
                hintText: '1500',
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Default cost per order used in the order wizard pricing step'.t(context),
                  style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary),
                ),
              ),
              SettingsTextField(
                label: 'Tax Rate (%)'.t(context),
                initialValue: _taxRateController.text,
                onChanged: (value) => _taxRateController.text = value,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                hintText: '0',
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Percentage tax applied to order totals (0 = no tax)'.t(context),
                  style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Order Settings
          SettingsTile(
            title: 'Order Settings'.t(context),
            children: [
              SettingsTextField(
                label: 'Order Number Prefix'.t(context),
                initialValue: _orderPrefixController.text,
                onChanged: (value) => _orderPrefixController.text = value,
                hintText: 'ICHITO'.t(context),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example order number:'.t(context),
                      style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_orderPrefixController.text.isNotEmpty ? _orderPrefixController.text : 'ICHITO'}-2026-07-001',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: theme.fontSize * 0.88,
                        color: theme.accentColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
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
              'Save Business Settings'.t(context),
              style: TextStyle(
                color: theme.onAccent,
                fontWeight: FontWeight.bold,
                fontSize: theme.fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
