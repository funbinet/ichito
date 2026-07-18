import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../shared/providers/app_state_provider.dart';
import '../../../../../core/widgets/ichito_scaffold.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> with ThemeAwareMixin {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Security', style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                  title: Text('Enable App Lock (PIN)', style: bodyStyle),
                  subtitle: Text('Require PIN or Biometrics on startup', style: subtitleStyle),
                  value: appState.isAppLockEnabled,
                  activeColor: theme.accentColor,
                  onChanged: (val) {
                    appState.setAppLockEnabled(val);
                    if (val) {
                      Navigator.pushNamed(context, '/setup_pin');
                    }
                  },
                ),
                if (appState.isAppLockEnabled) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text('Enable Biometrics', style: bodyStyle),
                    subtitle: Text('Use fingerprint or face unlock', style: subtitleStyle),
                    value: appState.isBiometricEnabled,
                    activeColor: theme.accentColor,
                    onChanged: (val) {
                      appState.setBiometricEnabled(val);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text('Change PIN or Password', style: bodyStyle),
                    trailing: Icon(Icons.chevron_right, color: theme.textSecondary),
                    onTap: () {
                      Navigator.pushNamed(context, '/setup_pin');
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: theme.cornerRadius,
              side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
            ),
            child: ListTile(
              title: Text('Account Recovery', style: bodyStyle),
              subtitle: Text('Set memorable date for password reset', style: subtitleStyle),
              trailing: Icon(Icons.chevron_right, color: theme.textSecondary),
              onTap: () {
                // Navigate to recovery setup
              },
            ),
          ),
        ],
      ),
    );
  }
}
