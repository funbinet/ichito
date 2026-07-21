import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ichito/shared/providers/language_provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../services/security_service.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/data/local/settings_repository.dart';

class PasswordSetupScreen extends StatefulWidget {
  const PasswordSetupScreen({super.key});

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> with ThemeAwareMixin {
  final SecurityService _securityService = SecurityService();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isError = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    final p1 = _passwordController.text;
    final p2 = _confirmPasswordController.text;
    
    if (p1.isEmpty || p1.length < 6) {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password must be at least 6 characters'.t(context))));
      return;
    }
    
    if (p1 == p2) {
      await _securityService.setPin(p1); // using the same storage mechanism as PIN
      await SettingsRepository().setLockType('password');
      
      if (await _securityService.canUseBiometrics()) {
        final useBiometrics = await _securityService.authenticateWithBiometrics('Enable Biometrics for quicker access');
        if (useBiometrics && mounted) {
          Provider.of<AppStateProvider>(context, listen: false).setBiometricEnabled(true);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password setup successfully!'.t(context), style: TextStyle(color: theme.onAccent)), backgroundColor: theme.accentColor));
        Navigator.pop(context);
      }
    } else {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match'.t(context))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Setup Security'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
          child: Column(
            children: [
              Text(
                'Create a Secure Password'.t(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: theme.fontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: theme.fontFamily,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
                decoration: InputDecoration(
                  labelText: 'Password'.t(context),
                  labelStyle: TextStyle(color: theme.textSecondary),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: theme.cornerRadius),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
                decoration: InputDecoration(
                  labelText: 'Confirm Password'.t(context),
                  labelStyle: TextStyle(color: theme.textSecondary),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: theme.cornerRadius),
                  errorText: _isError ? 'Passwords do not match or are too short'.t(context) : null,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _savePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
                ),
                child: Text('Save Password'.t(context), style: TextStyle(color: theme.onAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
