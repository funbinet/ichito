import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/profile_provider.dart';
import '../../../../shared/providers/notification_provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/widgets/themed_logo.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final profile = Provider.of<ProfileProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);
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
                  const ThemedLogo(size: 24),
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
                '${language.t("greeting")}, ${profile.businessName.isNotEmpty ? profile.businessName : "Tailor"}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textSecondary,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Notification bell with dynamic badge
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: theme.textSecondary,
                ),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: BoxDecoration(
                      color: theme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notifProvider.unreadCount > 99 ? '99+' : '${notifProvider.unreadCount}',
                      style: TextStyle(
                        color: theme.onAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          
          // Profile avatar — navigates to /profile
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.accentColor.withOpacity(0.4), width: 1.5),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.accentLight,
                backgroundImage: profile.profilePhotoBytes != null
                  ? MemoryImage(profile.profilePhotoBytes!)
                  : null,
                child: profile.profilePhotoBytes == null
                  ? Icon(Icons.person_outlined, color: theme.accentColor, size: 20)
                  : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
