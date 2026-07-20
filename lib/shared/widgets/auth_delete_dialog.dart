import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/theme_provider.dart';
import '../../features/security/services/security_service.dart';

class AuthDeleteDialog extends StatefulWidget {
  final String itemName;
  final VoidCallback onDelete;
  final SecurityService securityService;

  const AuthDeleteDialog({
    super.key,
    required this.itemName,
    required this.onDelete,
    required this.securityService,
  });

  @override
  State<AuthDeleteDialog> createState() => _AuthDeleteDialogState();
}

class _AuthDeleteDialogState extends State<AuthDeleteDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorText;
  bool _isAuthenticating = false;

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorText = null;
    });

    // Try biometrics first if available
    final bool biometricSuccess = await widget.securityService.authenticateWithBiometrics(
      'Authenticate to delete ${widget.itemName}',
    );

    if (biometricSuccess) {
      widget.onDelete();
      if (mounted) Navigator.pop(context, true);
      return;
    }

    // Fall back to PIN
    final pin = _pinController.text;
    if (pin.isEmpty) {
      setState(() {
        _errorText = 'PIN is required';
        _isAuthenticating = false;
      });
      return;
    }

    final bool pinSuccess = await widget.securityService.verifyPin(pin);
    if (pinSuccess) {
      widget.onDelete();
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() {
        _errorText = 'Incorrect PIN';
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Delete ${widget.itemName}?'.t(context),
              style: TextStyle(
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: theme.fontSize * 1.2,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This item will be permanently deleted. This action cannot be undone. Please confirm by entering your PIN or using biometrics.'.t(context),
            style: TextStyle(
              color: theme.textSecondary,
              fontFamily: theme.fontFamily,
              fontSize: theme.fontSize * 0.9,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            style: TextStyle(color: theme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter PIN'.t(context),
              hintStyle: TextStyle(color: theme.textSecondary.withOpacity(0.5)),
              errorText: _errorText,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.borderColor),
                borderRadius: theme.cornerRadius,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor),
                borderRadius: theme.cornerRadius,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'CANCEL'.t(context),
            style: TextStyle(color: theme.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
          ),
          onPressed: _isAuthenticating ? null : _authenticate,
          child: _isAuthenticating
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text('DELETE'.t(context)),
        ),
      ],
    );
  }
}
