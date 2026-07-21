import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/widgets/square_avatar.dart';
import '../../../../shared/providers/profile_provider.dart';
import '../../services/security_service.dart';
import 'recovery_setup_screen.dart';

class PasswordLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  
  const PasswordLockScreen({super.key, required this.onUnlocked});

  @override
  State<PasswordLockScreen> createState() => _PasswordLockScreenState();
}

class _PasswordLockScreenState extends State<PasswordLockScreen> with ThemeAwareMixin {
  final SecurityService _securityService = SecurityService();
  bool _isError = false;
  final _passwordController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final success = await _securityService.authenticateWithBiometrics(
      lang.t('authenticate_to_unlock') ?? 'Authenticate to unlock'
    );
    if (success && mounted) {
      widget.onUnlocked();
    }
  }

  Future<void> _verifyPassword() async {
    final success = await _securityService.verifyPin(_passwordController.text);
    if (success) {
      if (mounted) widget.onUnlocked();
    } else {
      setState(() {
        _isError = true;
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              SquareAvatar(
                size: 80,
                base64Image: profile.profilePhotoBase64,
              ),
              const SizedBox(height: 24),
              Text(
                'Enter Password'.t(context),
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: theme.fontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: theme.fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              if (_isError)
                Text(
                  'Incorrect Password. Try again.'.t(context),
                  style: TextStyle(color: Colors.red, fontFamily: theme.fontFamily),
                )
              else
                const SizedBox(height: 16),
              const SizedBox(height: 32),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
                decoration: InputDecoration(
                  hintText: 'Password'.t(context),
                  hintStyle: TextStyle(color: theme.textSecondary),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: theme.cornerRadius,
                    borderSide: BorderSide(color: theme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: theme.cornerRadius,
                    borderSide: BorderSide(color: theme.accentColor),
                  ),
                ),
                onSubmitted: (_) => _verifyPassword(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _verifyPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text('Unlock'.t(context), style: TextStyle(color: theme.onAccent, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _tryBiometric,
                    icon: Icon(Icons.fingerprint, size: 48, color: theme.accentColor),
                  ),
                  TextButton(
                    onPressed: () => _showRecoveryDialog(context),
                    child: Text('Forgot?'.t(context), style: TextStyle(color: theme.textSecondary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecoveryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _RecoveryDialog(onUnlocked: widget.onUnlocked),
    );
  }
}

class _RecoveryDialog extends StatefulWidget {
  final VoidCallback onUnlocked;
  const _RecoveryDialog({required this.onUnlocked});

  @override
  State<_RecoveryDialog> createState() => _RecoveryDialogState();
}

class _RecoveryDialogState extends State<_RecoveryDialog> with ThemeAwareMixin {
  final _codeController = TextEditingController();
  DateTime? _selectedDate;
  bool _isError = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: theme.accentColor,
              onPrimary: theme.onAccent,
              surface: theme.backgroundColor,
              onSurface: theme.textPrimary,
            ),
            dialogBackgroundColor: theme.cardColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isError = false;
      });
    }
  }

  Future<void> _verifyRecovery() async {
    if (_codeController.text.trim().isEmpty || _selectedDate == null) {
      setState(() => _isError = true);
      return;
    }

    final dateStr = _selectedDate!.toIso8601String().split('T')[0];
    final success = await SecurityService().verifyRecoveryCode(_codeController.text.trim(), dateStr);
    
    if (success) {
      if (mounted) {
        Navigator.pop(context); // close dialog
        widget.onUnlocked();
      }
    } else {
      setState(() => _isError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
      title: Text('Account Recovery'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isError)
            Text('Invalid recovery details'.t(context), style: TextStyle(color: Colors.red, fontFamily: theme.fontFamily)),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
            decoration: InputDecoration(
              labelText: 'Security Code',
              labelStyle: TextStyle(color: theme.textSecondary),
              filled: true,
              fillColor: theme.backgroundColor,
              border: OutlineInputBorder(borderRadius: theme.cornerRadius),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: theme.cornerRadius,
                border: Border.all(color: theme.borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: theme.textSecondary),
                  const SizedBox(width: 16),
                  Text(
                    _selectedDate == null ? 'Select Date of Birth' : _selectedDate!.toIso8601String().split('T')[0],
                    style: TextStyle(color: _selectedDate == null ? theme.textSecondary : theme.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
        ),
        ElevatedButton(
          onPressed: _verifyRecovery,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.accentColor,
            shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
          ),
          child: Text('Verify & Unlock'.t(context), style: TextStyle(color: theme.onAccent, fontFamily: theme.fontFamily)),
        ),
      ],
    );
  }
}
