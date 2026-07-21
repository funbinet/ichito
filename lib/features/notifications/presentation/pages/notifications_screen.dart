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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';

  final List<String> _types = ['All', 'Client', 'Order', 'Fabric', 'Design', 'Garment', 'System'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      Provider.of<NotificationProvider>(context, listen: false).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    Provider.of<NotificationProvider>(context, listen: false)
        .loadNotifications(query: value, type: _selectedType);
  }

  void _onTypeChanged(String? newValue) {
    if (newValue != null) {
      setState(() => _selectedType = newValue);
      Provider.of<NotificationProvider>(context, listen: false)
          .loadNotifications(query: _searchController.text, type: _selectedType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final notifications = notifProvider.notifications;

    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Audit Trail'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
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
                  fontSize: theme.fontSize * 0.75,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily, fontSize: theme.fontSize),
                      decoration: InputDecoration(
                        hintText: 'Search audit trail...',
                        hintStyle: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily, fontSize: theme.fontSize),
                        prefixIcon: Icon(Icons.search, color: theme.textSecondary),
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: theme.cornerRadius,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: theme.cornerRadius,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          dropdownColor: theme.cardColor,
                          style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily, fontSize: theme.fontSize),
                          icon: Icon(Icons.filter_list, color: theme.textSecondary),
                          onChanged: _onTypeChanged,
                          items: _types.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notifications.isEmpty && !notifProvider.isLoading
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 100),
                      itemCount: notifications.length + (notifProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == notifications.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(color: theme.accentColor),
                            ),
                          );
                        }
                        return _NotificationTile(
                          notification: notifications[index],
                          onTap: () => _handleNotificationTap(notifications[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    if (!notification.isRead) {
      notifProvider.markAsRead(notification.id);
    }
    // Navigate based on type
    if (notification.type == 'Order' && notification.referenceId != null) {
      navigateTo('/orders/detail', arguments: notification.referenceId);
    } else if (notification.type == 'Client' && notification.referenceId != null) {
      navigateTo('/customers/detail', arguments: notification.referenceId);
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
              child: Icon(Icons.history, size: 40, color: theme.accentColor),
            ),
            SizedBox(height: 24),
            Text(
              'No Audit Logs Found'.t(context),
              style: TextStyle(
                fontSize: theme.fontSize * 1.12,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'System events will appear here permanently.',
              style: TextStyle(fontSize: theme.fontSize * 0.88, color: theme.textSecondary, fontFamily: theme.fontFamily),
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

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (notification.type) {
      case 'Order':
        return Icons.receipt_long;
      case 'Client':
        return Icons.person;
      case 'Fabric':
        return Icons.layers;
      case 'Garment':
        return Icons.checkroom;
      case 'Design':
        return Icons.brush;
      case 'System':
        return Icons.info_outline;
      default:
        return Icons.history;
    }
  }

  Color _getIconColor(ThemeProvider theme) {
    switch (notification.action) {
      case 'Created':
        return const Color(0xFF4CAF50); // Green
      case 'Updated':
        return const Color(0xFF2196F3); // Blue
      case 'Deleted':
        return const Color(0xFFF44336); // Red
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

    return GestureDetector(
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
                            fontSize: theme.fontSize * 0.88,
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
                      fontSize: theme.fontSize * 0.81,
                      color: theme.textSecondary,
                      fontFamily: theme.fontFamily,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: theme.fontSize * 0.69,
                          color: theme.textSecondary.withOpacity(0.7),
                          fontFamily: theme.fontFamily,
                        ),
                      ),
                      if (notification.clientName != null)
                        Text(
                          notification.clientName!,
                          style: TextStyle(
                            fontSize: theme.fontSize * 0.69,
                            color: theme.accentColor.withOpacity(0.8),
                            fontFamily: theme.fontFamily,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
