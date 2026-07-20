import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../orders/data/models/order.dart';

class QuickActionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  
  const QuickActionTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
          border: Border.all(color: theme.accentColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.accentColor, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: theme.textSecondary,
                fontFamily: theme.fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
              fontFamily: theme.fontFamily,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.accentColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  final String status;
  
  const StatusDot({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'in_progress':
      case 'fitting':
        color = Colors.blue;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ActivityFeedItem extends StatelessWidget {
  final Order order;
  
  const ActivityFeedItem({super.key, required this.order});

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/orders/detail',
        arguments: order.id,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            StatusDot(status: order.status),
            SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: theme.accentColor,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ${order.orderNumber}'.t(context),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Client ID: ${order.customerId} - ${language.formatCurrency(order.totalAmount, showSymbol: true)}'.t(context),
                    style: TextStyle(fontSize: 13, color: theme.textSecondary, fontFamily: theme.fontFamily),
                  ),
                  Text(
                    'Garment ID: ${order.garmentId}'.t(context),
                    style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimeAgo(order.orderDate), // using orderDate as fallback for createdAt
                  style: TextStyle(fontSize: 11, color: theme.textSecondary, fontFamily: theme.fontFamily),
                ),
                SizedBox(height: 4),
                Icon(Icons.arrow_forward, size: 16, color: theme.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
