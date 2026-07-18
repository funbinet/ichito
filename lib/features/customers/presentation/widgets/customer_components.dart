import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../shared/providers/theme_provider.dart';
import '../../data/models/customer.dart';

class LoyaltyBadge extends StatelessWidget {
  final String status;
  
  const LoyaltyBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    Color badgeColor;
    IconData badgeIcon;
    switch (status.toUpperCase()) {
      case 'VIP':
        badgeColor = const Color(0xFFFFD700); // Gold
        badgeIcon = Icons.workspace_premium_outlined;
        break;
      case 'REGULAR':
        badgeColor = const Color(0xFF4CAF50); // Green
        badgeIcon = Icons.star_outlined;
        break;
      case 'LOYAL':
        badgeColor = const Color(0xFF2196F3); // Blue
        badgeIcon = Icons.star_outlined;
        break;
      default: // New
        badgeColor = theme.textSecondary;
        badgeIcon = Icons.star_outlined;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 10, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            status,
            style: TextStyle(
              fontSize: 10, 
              color: badgeColor, 
              fontWeight: FontWeight.w600,
              fontFamily: theme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final bool isSelected;
  
  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    this.isSelected = false,
  });

  void _showQuickActions(BuildContext context) {
    // Implement popup menu here
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showQuickActions(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? theme.accentColor.withOpacity(0.05) : theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
          border: isSelected 
              ? Border.all(color: theme.accentColor, width: 2)
              : Border.all(color: theme.borderColor, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.accentLight,
              backgroundImage: customer.photoPath != null
                ? FileImage(File(customer.photoPath!))
                : null,
              child: customer.photoPath == null
                ? Text(
                    customer.initials,
                    style: TextStyle(
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: theme.fontFamily,
                    ),
                  )
                : null,
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              customer.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Orders + loyalty
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_outlined, size: 14, color: theme.accentColor),
                const SizedBox(width: 2),
                Text(
                  '${customer.totalOrders}',
                  style: TextStyle(fontSize: 11, color: theme.textSecondary, fontFamily: theme.fontFamily),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Loyalty badge
            LoyaltyBadge(status: customer.loyaltyStatus),
          ],
        ),
      ),
    );
  }
}

class CustomerListTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  
  const CustomerListTile({
    super.key,
    required this.customer,
    required this.onTap,
  });

  void _showQuickActions(BuildContext context) {
    // Implement popup menu here
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showQuickActions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.borderColor, width: 0.5)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.accentLight,
              backgroundImage: customer.photoPath != null
                ? FileImage(File(customer.photoPath!)) : null,
              child: customer.photoPath == null
                ? Text(customer.initials,
                    style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily))
                : null,
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: theme.textSecondary),
                      const SizedBox(width: 4),
                      Text(customer.phone,
                        style: TextStyle(fontSize: 13, color: theme.textSecondary, fontFamily: theme.fontFamily)),
                    ],
                  ),
                ],
              ),
            ),
            // Loyalty + orders
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LoyaltyBadge(status: customer.loyaltyStatus),
                const SizedBox(height: 4),
                Text('${customer.totalOrders} orders',
                  style: TextStyle(fontSize: 11, color: theme.textSecondary, fontFamily: theme.fontFamily)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
