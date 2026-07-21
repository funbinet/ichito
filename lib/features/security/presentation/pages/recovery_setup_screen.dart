import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../services/security_service.dart';

class RecoverySetupScreen extends StatefulWidget {
  const RecoverySetupScreen({super.key});

  @override
  State<RecoverySetupScreen> createState() => _RecoverySetupScreenState();
}

class _RecoverySetupScreenState extends State<RecoverySetupScreen> with ThemeAwareMixin {
  final _codeController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveRecovery() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a code and select date of birth'.t(context)), backgroundColor: Colors.red),
      );
      return;
    }
    
    await SecurityService().setupRecoveryInfo(
      code,
      _selectedDate!.toIso8601String().split('T')[0],
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recovery info saved'.t(context)), backgroundColor: theme.accentColor),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Account Recovery Setup'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Set up recovery details to regain access if you forget your PIN or Password.'.t(context), style: subtitleStyle),
            SizedBox(height: 32),
            TextField(
              controller: _codeController,
              style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
              decoration: InputDecoration(
                labelText: 'Security Code',
                labelStyle: TextStyle(color: theme.textSecondary),
                prefixIcon: Icon(Icons.security, color: theme.textSecondary),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(borderRadius: theme.cornerRadius),
              ),
            ),
            SizedBox(height: 24),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: theme.cornerRadius,
                  border: Border.all(color: theme.borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: theme.textSecondary),
                    SizedBox(width: 16),
                    Text(
                      _selectedDate == null ? 'Select Date of Birth' : _selectedDate!.toIso8601String().split('T')[0],
                      style: TextStyle(color: _selectedDate == null ? theme.textSecondary : theme.textPrimary, fontSize: theme.fontSize),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveRecovery,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accentColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
              ),
              child: Text('Save Recovery Details'.t(context), style: TextStyle(color: theme.onAccent, fontSize: theme.fontSize, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
