import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../shared/providers/app_state_provider.dart';
import '../../../../../core/widgets/ichito_scaffold.dart';
import '../../../../security/services/security_service.dart';
import '../../../../security/presentation/pages/recovery_setup_screen.dart';
import '../../../../../shared/data/local/settings_repository.dart';
import '../../../../security/presentation/pages/pin_lock_screen.dart';
import '../../../../security/presentation/pages/password_lock_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> with ThemeAwareMixin {
  Future<void> _showLockTypeSelectionDialog(AppStateProvider appState) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text('Select Lock Type'.t(context), style: TextStyle(color: theme.textPrimary)),
          content: Text('How would you like to secure your app?'.t(context), style: TextStyle(color: theme.textSecondary)),
          actions: [
            TextButton(
              onPressed: () {
                appState.setAppLockEnabled(false);
                Navigator.pop(context);
              },
              child: Text('Cancel'.t(context), style: TextStyle(color: theme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/setup_pin');
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
              child: Text('Use PIN'.t(context), style: TextStyle(color: theme.onAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/setup_password');
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
              child: Text('Use Password'.t(context), style: TextStyle(color: theme.onAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requireAuthToChange() async {
    final lockType = SettingsRepository().getLockType();
    
    // Simplistic auth requirement logic: 
    // Wait for the user to unlock the app using the same lock screen.
    // This is basically achieved by locking the app now and navigating to the setup screen upon unlock.
    // Alternatively, we can use SecurityService to authenticate.
    
    bool authenticated = false;
    final securityService = SecurityService();
    
    if (await securityService.canUseBiometrics()) {
      authenticated = await securityService.authenticateWithBiometrics('Authenticate to change credentials');
    }
    
    // If biometrics fail or aren't available, we would typically show a PIN/Password prompt.
    // For simplicity, we assume the user is authenticated if they have the app unlocked, 
    // but the requirement is "Change PIN/password must require current authentication first".
    
    // Let's implement a manual check using the lock screens:
    if (!authenticated) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => lockType == 'password' 
              ? PasswordLockScreen(onUnlocked: () => Navigator.pop(context, true))
              : PinLockScreen(onUnlocked: () => Navigator.pop(context, true)),
        ),
      ).then((val) {
        if (val == true) authenticated = true;
      });
    }
    
    if (authenticated && mounted) {
      if (lockType == 'password') {
        Navigator.pushNamed(context, '/setup_password');
      } else {
        Navigator.pushNamed(context, '/setup_pin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Security'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
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
          Card(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: theme.cornerRadius,
              side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Enable App Lock'.t(context), style: bodyStyle),
                  subtitle: Text('Require PIN, Password or Biometrics on startup'.t(context), style: subtitleStyle),
                  value: appState.isAppLockEnabled,
                  activeColor: theme.accentColor,
                  onChanged: (val) {
                    appState.setAppLockEnabled(val);
                    if (val) {
                      _showLockTypeSelectionDialog(appState);
                    }
                  },
                ),
                if (appState.isAppLockEnabled) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text('Enable Biometrics'.t(context), style: bodyStyle),
                    subtitle: Text('Use fingerprint or face unlock'.t(context), style: subtitleStyle),
                    value: appState.isBiometricEnabled,
                    activeColor: theme.accentColor,
                    onChanged: (val) async {
                      if (val) {
                        final success = await SecurityService().authenticateWithBiometrics('Confirm to enable biometrics');
                        if (success) {
                          appState.setBiometricEnabled(true);
                        }
                      } else {
                        appState.setBiometricEnabled(false);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text('Change PIN or Password'.t(context), style: bodyStyle),
                    trailing: Icon(Icons.chevron_right, color: theme.textSecondary),
                    onTap: () {
                      _requireAuthToChange();
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Auto-Lock Timeout'.t(context), style: bodyStyle),
                        DropdownButton<int>(
                          value: appState.autoLockSeconds,
                          dropdownColor: theme.cardColor,
                          style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
                          underline: SizedBox(),
                          items: [
                            DropdownMenuItem(value: 5, child: Text('5 seconds'.t(context))),
                            DropdownMenuItem(value: 10, child: Text('10 seconds'.t(context))),
                            DropdownMenuItem(value: 20, child: Text('20 seconds'.t(context))),
                            DropdownMenuItem(value: 30, child: Text('30 seconds'.t(context))),
                            DropdownMenuItem(value: 60, child: Text('1 minute'.t(context))),
                            DropdownMenuItem(value: 300, child: Text('5 minutes'.t(context))),
                            DropdownMenuItem(value: -1, child: Text('Never'.t(context))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              appState.setAutoLockSeconds(val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text('Lock App Now'.t(context), style: bodyStyle.copyWith(color: theme.accentColor)),
                    trailing: Icon(Icons.lock_outline, color: theme.accentColor),
                    onTap: () {
                      appState.lock();
                    },
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 24),
          Card(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: theme.cornerRadius,
              side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
            ),
            child: ListTile(
              title: Text('Account Recovery'.t(context), style: bodyStyle),
              subtitle: Text('Set memorable date for password reset'.t(context), style: subtitleStyle),
              trailing: Icon(Icons.chevron_right, color: theme.textSecondary),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RecoverySetupScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
