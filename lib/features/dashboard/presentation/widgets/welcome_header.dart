import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/providers/language_provider.dart';

class WelcomeHeader extends StatelessWidget {
  final int notificationCount;
  final VoidCallback onNotificationTap;

  const WelcomeHeader({
    super.key,
    required this.notificationCount,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final appState = Provider.of<AppStateProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // Logo + App name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    theme.isLightMode
                      ? 'assets/images/logo_black.png'
                      : 'assets/images/logo_white.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ICHITO',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                      letterSpacing: 2,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${language.t("greeting")}, ${appState.userName}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textSecondary,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Notification bell with badge
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: theme.textSecondary,
                ),
                onPressed: onNotificationTap,
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: TextStyle(
                        color: theme.onAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Profile avatar
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.accentLight,
              backgroundImage: appState.profilePhotoPath != null
                ? FileImage(File(appState.profilePhotoPath!))
                : null,
              child: appState.profilePhotoPath == null
                ? Icon(Icons.person_outlined, color: theme.accentColor, size: 20)
                : null,
            ),
          ),
        ],
      ),
    );
  }
}
