import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/widgets/themed_logo.dart';
import '../../../../shared/widgets/square_avatar.dart';
import '../../../../shared/providers/profile_provider.dart';
import '../../services/security_service.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  
  const PinLockScreen({super.key, required this.onUnlocked});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> with ThemeAwareMixin {
  final SecurityService _securityService = SecurityService();
  String _input = '';
  bool _isError = false;
  
  @override
  void initState() {
    super.initState();
    _tryBiometric();
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

  void _onDigitPressed(String digit) {
    if (_input.length < 4) {
      setState(() {
        _input += digit;
        _isError = false;
      });
      if (_input.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final success = await _securityService.verifyPin(_input);
    if (success) {
      if (mounted) widget.onUnlocked();
    } else {
      setState(() {
        _isError = true;
        _input = '';
      });
      // Optionally trigger shake animation here
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            SquareAvatar(
              size: 80,
              base64Image: profile.profilePhotoBase64,
            ),
            SizedBox(height: 24),
            Text(
              'Enter PIN'.t(context),
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: theme.fontSize * 1.5,
                fontWeight: FontWeight.bold,
                fontFamily: theme.fontFamily,
              ),
            ),
            SizedBox(height: 16),
            if (_isError)
              Text(
                'Incorrect PIN. Try again.'.t(context),
                style: TextStyle(color: Colors.red, fontFamily: theme.fontFamily),
              )
            else
              SizedBox(height: 16),
            const Spacer(),
            
            _buildPinDots(),
              
            const Spacer(),
            
            _buildKeypad(),
              
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _tryBiometric,
                  icon: Icon(Icons.fingerprint, size: 48, color: theme.accentColor),
                ),
                TextButton(
                  onPressed: () {
                    _showRecoveryDialog(context);
                  },
                  child: Text('Forgot?'.t(context), style: TextStyle(color: theme.textSecondary)),
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isFilled = index < _input.length;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? theme.accentColor : Colors.transparent,
            border: Border.all(
              color: isFilled ? theme.accentColor : theme.borderColor,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('1'),
              _buildKeypadButton('2'),
              _buildKeypadButton('3'),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('4'),
              _buildKeypadButton('5'),
              _buildKeypadButton('6'),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('7'),
              _buildKeypadButton('8'),
              _buildKeypadButton('9'),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 80),
              _buildKeypadButton('0'),
              _buildKeypadButton('del', icon: Icons.backspace_outlined, onPressed: _onBackspacePressed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String value, {IconData? icon, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed ?? () => _onDigitPressed(value),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.cardColor.withOpacity(0.5),
          border: Border.all(color: theme.borderColor.withOpacity(0.3)),
        ),
        child: icon != null
            ? Icon(icon, size: 28, color: theme.textPrimary)
            : Text(
                value,
                style: TextStyle(
                  fontSize: theme.fontSize * 1.75,
                  fontWeight: FontWeight.w500,
                  color: theme.textPrimary,
                  fontFamily: theme.fontFamily,
                ),
              ),
      ),
    );
  }

  void _showRecoveryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _RecoveryDialog(),
    );
  }
}

class _RecoveryDialog extends StatefulWidget {
  const _RecoveryDialog();

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
        // Also unlock the app or clear PIN
        final pinLockState = context.findAncestorStateOfType<_PinLockScreenState>();
        if (pinLockState != null) {
          pinLockState.widget.onUnlocked();
        }
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
          SizedBox(height: 16),
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
          SizedBox(height: 16),
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: theme.cornerRadius,
                border: Border.all(color: theme.borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: theme.textSecondary),
                  SizedBox(width: 16),
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
