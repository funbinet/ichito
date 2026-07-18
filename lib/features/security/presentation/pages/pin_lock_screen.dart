import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/widgets/themed_logo.dart';
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
  bool _isPasswordMode = false;
  final _passwordController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _checkMode();
    _tryBiometric();
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkMode() async {
    // In a real app we'd check if the user set a PIN or Password.
    // For now we assume PIN mode is default.
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
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            ThemedLogo(size: 80, color: theme.accentColor),
            const SizedBox(height: 24),
            Text(
              'Enter ${_isPasswordMode ? 'Password' : 'PIN'}',
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
                'Incorrect ${_isPasswordMode ? 'Password' : 'PIN'}. Try again.',
                style: TextStyle(color: Colors.red, fontFamily: theme.fontFamily),
              )
            else
              const SizedBox(height: 16),
            const Spacer(),
            
            if (_isPasswordMode)
              _buildPasswordInput()
            else
              _buildPinDots(),
              
            const Spacer(),
            
            if (!_isPasswordMode)
              _buildKeypad(),
              
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _tryBiometric,
                  child: Text('Use Biometrics', style: TextStyle(color: theme.accentColor)),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to forgot PIN/password screen
                  },
                  child: Text('Forgot?', style: TextStyle(color: theme.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
          margin: const EdgeInsets.symmetric(horizontal: 12),
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
  
  Widget _buildPasswordInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
            decoration: InputDecoration(
              hintText: 'Password',
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('Unlock', style: TextStyle(color: theme.onAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('4'),
              _buildKeypadButton('5'),
              _buildKeypadButton('6'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('7'),
              _buildKeypadButton('8'),
              _buildKeypadButton('9'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('pw', icon: Icons.keyboard, onPressed: () => setState(() => _isPasswordMode = true)),
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
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: theme.textPrimary,
                  fontFamily: theme.fontFamily,
                ),
              ),
      ),
    );
  }
}
