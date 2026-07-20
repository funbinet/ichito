import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../shared/providers/notification_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../data/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with ThemeAwareMixin, NavigationMixin {

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final notifications = notifProvider.notifications;

    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Notifications'.t(context), style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        actions: [
          if (notifProvider.unreadCount > 0)
            TextButton.icon(
              onPressed: () => notifProvider.markAllAsRead(),
              icon: Icon(Icons.done_all, color: theme.accentColor, size: 18),
              label: Text(
                'Mark All Read'.t(context),
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 12,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 100),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _NotificationTile(
                    notification: notifications[index],
                    onTap: () => _handleNotificationTap(notifications[index]),
                    onDismiss: () => notifProvider.deleteNotification(notifications[index].id),
                  );
                },
              ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    if (!notification.isRead) {
      notifProvider.markAsRead(notification.id);
    }
    // Navigate to the referenced entity if it's an order notification
    if (notification.type == 'order_due' && notification.referenceId != null) {
      navigateTo('/orders/detail', arguments: notification.referenceId);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.accentLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none, size: 40, color: theme.accentColor),
            ),
            SizedBox(height: 24),
            Text(
              'No Notifications'.t(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'.t(context)re all caught up! Notifications about upcoming orders will appear here.',
              style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  IconData _getIcon() {
    switch (notification.type) {
      case 'order_due':
        return Icons.schedule;
      case 'order_paid':
        return Icons.payment;
      case 'order_updated':
        return Icons.update;
      case 'system':
        return Icons.info_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(ThemeProvider theme) {
    switch (notification.type) {
      case 'order_due':
        if (notification.title.contains('Overdue')) return const Color(0xFFF44336);
        if (notification.title.contains('Today')) return const Color(0xFFFF9800);
        return theme.accentColor;
      case 'order_paid':
        return const Color(0xFF4CAF50);
      case 'order_updated':
        return const Color(0xFF2196F3);
      default:
        return theme.accentColor;
    }
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return '${date.day}/${date.month}/${date.year}';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final iconColor = _getIconColor(theme);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF44336).withOpacity(0.15),
          borderRadius: theme.cornerRadius,
        ),
        child: Icon(Icons.delete_outline, color: Color(0xFFF44336)),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead
                ? theme.cardColor
                : theme.accentColor.withOpacity(0.06),
            borderRadius: theme.cornerRadius,
            border: Border.all(
              color: notification.isRead
                  ? theme.accentColor.withOpacity(0.15)
                  : theme.accentColor.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIcon(), color: iconColor, size: 22),
              ),
              SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              color: theme.textPrimary,
                              fontFamily: theme.fontFamily,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                        fontFamily: theme.fontFamily,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary.withOpacity(0.7),
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
