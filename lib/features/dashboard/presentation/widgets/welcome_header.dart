import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/profile_provider.dart';
import '../../../../shared/providers/notification_provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/widgets/themed_logo.dart';
import '../../../../shared/widgets/square_avatar.dart';

class WelcomeHeader extends StatelessWidget {
  final VoidCallback? onExportCSV;
  final VoidCallback? onExportPDF;

  const WelcomeHeader({
    super.key, 
    this.onExportCSV, 
    this.onExportPDF,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final profile = Provider.of<ProfileProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // Logo + App name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ThemedLogo(size: 24),
                  SizedBox(width: 8),
                  Text(
                    'ICHITO'.t(context),
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
              SizedBox(height: 4),
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
          
          // CSV Export
          if (onExportCSV != null)
            IconButton(
              icon: Icon(Icons.table_chart_outlined, color: theme.textSecondary, size: 20),
              onPressed: onExportCSV,
              tooltip: 'Export CSV'.t(context),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          SizedBox(width: 8),

          // PDF Export
          if (onExportPDF != null)
            IconButton(
              icon: Icon(Icons.picture_as_pdf_outlined, color: theme.textSecondary, size: 20),
              onPressed: onExportPDF,
              tooltip: 'Export PDF'.t(context),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          SizedBox(width: 8),

          // Settings
          IconButton(
            icon: Icon(Icons.settings_outlined, color: theme.textSecondary, size: 22),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings'.t(context),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: 8),
          
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
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
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
            child: SquareAvatar(
              size: 36,
              base64Image: profile.profilePhotoBase64, // Needs to use base64 String
            ),
          ),
        ],
      ),
    );
  }
}
