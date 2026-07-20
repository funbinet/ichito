import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../services/security_service.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/app_state_provider.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> with ThemeAwareMixin {
  final SecurityService _securityService = SecurityService();
  bool _isPasswordMode = false;
  
  String _firstInput = '';
  String _secondInput = '';
  bool _isConfirming = false;
  bool _isError = false;
  
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _onDigitPressed(String digit) {
    if (!_isConfirming && _firstInput.length < 4) {
      setState(() {
        _firstInput += digit;
        _isError = false;
      });
      if (_firstInput.length == 4) {
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() => _isConfirming = true);
        });
      }
    } else if (_isConfirming && _secondInput.length < 4) {
      setState(() {
        _secondInput += digit;
        _isError = false;
      });
      if (_secondInput.length == 4) {
        _verifySetup();
      }
    }
  }

  void _onBackspacePressed() {
    if (!_isConfirming && _firstInput.isNotEmpty) {
      setState(() {
        _firstInput = _firstInput.substring(0, _firstInput.length - 1);
        _isError = false;
      });
    } else if (_isConfirming && _secondInput.isNotEmpty) {
      setState(() {
        _secondInput = _secondInput.substring(0, _secondInput.length - 1);
        _isError = false;
      });
    } else if (_isConfirming && _secondInput.isEmpty) {
      setState(() {
        _isConfirming = false;
        _firstInput = ''; // Reset entirely if they backspace from empty confirm
      });
    }
  }

  Future<void> _verifySetup() async {
    if (_firstInput == _secondInput) {
      await _securityService.setPin(_firstInput);
      if (await _securityService.canUseBiometrics()) {
        final useBiometrics = await _securityService.authenticateWithBiometrics('Enable Biometrics for quicker access');
        if (useBiometrics && mounted) {
          Provider.of<AppStateProvider>(context, listen: false).setBiometricEnabled(true);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PIN setup successfully!'.t(context), style: TextStyle(color: theme.onAccent)), backgroundColor: theme.accentColor));
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _isError = true;
        _secondInput = '';
      });
    }
  }
  
  Future<void> _savePassword() async {
    final p1 = _passwordController.text;
    final p2 = _confirmPasswordController.text;
    
    if (p1.isEmpty || p1.length < 6) {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters'.t(context))));
      return;
    }
    
    if (p1 == p2) {
      await _securityService.setPin(p1);
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'.t(context))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Setup Security'.t(context), style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isPasswordMode = !_isPasswordMode;
                _firstInput = '';
                _secondInput = '';
                _isConfirming = false;
                _isError = false;
                _passwordController.clear();
                _confirmPasswordController.clear();
              });
            },
            child: Text(
              _isPasswordMode ? 'Use PIN' : 'Use Password', 
              style: TextStyle(color: theme.accentColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 32),
            Text(
              _isPasswordMode 
                ? 'Create a Secure Password'
                : (_isConfirming ? 'Confirm your PIN' : 'Create a 4-digit PIN'),
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
                'Does not match. Try again.'.t(context),
                style: TextStyle(color: Colors.red, fontFamily: theme.fontFamily),
              )
            else
              SizedBox(height: 16),
            const Spacer(),
            
            if (_isPasswordMode)
              _buildPasswordInput()
            else
              _buildPinDots(),
              
            const Spacer(),
            
            if (!_isPasswordMode)
              _buildKeypad(),
              
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    final currentInput = _isConfirming ? _secondInput : _firstInput;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isFilled = index < currentInput.length;
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
  
  Widget _buildPasswordInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: theme.textSecondary),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(borderRadius: theme.cornerRadius),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: TextStyle(color: theme.textSecondary),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(borderRadius: theme.cornerRadius),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _savePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
            ),
            child: Text('Save Password'.t(context), style: TextStyle(color: theme.onAccent)),
          ),
        ],
      ),
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
