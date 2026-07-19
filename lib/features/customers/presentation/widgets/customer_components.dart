import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
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

  void _showImagePreview(BuildContext context, String base64Image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Image.memory(base64Decode(base64Image), fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? theme.accentColor.withOpacity(0.05) : theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
          border: isSelected 
              ? Border.all(color: theme.accentColor, width: 2)
              : Border.all(color: theme.borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Area
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: customer.photoPath != null 
                    ? () => _showImagePreview(context, customer.photoPath!) 
                    : onTap,
                child: Container(
                  color: theme.accentLight.withOpacity(0.3),
                  child: customer.photoPath != null
                      ? Image.memory(
                          base64Decode(customer.photoPath!),
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            customer.initials,
                            style: TextStyle(
                              color: theme.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              fontFamily: theme.fontFamily,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            // Details Area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                        fontFamily: theme.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 12, color: theme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${customer.totalOrders} Orders',
                          style: TextStyle(fontSize: 11, color: theme.textSecondary, fontFamily: theme.fontFamily),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LoyaltyBadge(status: customer.loyaltyStatus),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerListTile extends StatefulWidget {
  final Customer customer;
  final VoidCallback onTap;
  
  const CustomerListTile({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  State<CustomerListTile> createState() => _CustomerListTileState();
}

class _CustomerListTileState extends State<CustomerListTile> {
  bool _isExpanded = false;

  void _showImagePreview(BuildContext context, String base64Image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Image.memory(base64Decode(base64Image), fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Image/Avatar
                  GestureDetector(
                    onTap: widget.customer.photoPath != null 
                        ? () => _showImagePreview(context, widget.customer.photoPath!) 
                        : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.accentLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.borderColor, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.customer.photoPath != null
                          ? Image.memory(
                              base64Decode(widget.customer.photoPath!),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Text(
                                widget.customer.initials,
                                style: TextStyle(
                                  color: theme.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: theme.fontFamily,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.customer.name,
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600, 
                            color: theme.textPrimary, 
                            fontFamily: theme.fontFamily
                          )
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: theme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              widget.customer.phone,
                              style: TextStyle(
                                fontSize: 13, 
                                color: theme.textSecondary, 
                                fontFamily: theme.fontFamily
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Loyalty
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      LoyaltyBadge(status: widget.customer.loyaltyStatus),
                      const SizedBox(height: 8),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: theme.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.backgroundColor.withOpacity(0.5),
                  border: Border(top: BorderSide(color: theme.borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Orders: ${widget.customer.totalOrders}', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Role: ${widget.customer.role}', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: widget.onTap, // onTap passed from parent means view details
                          icon: Icon(Icons.edit_outlined, size: 16, color: theme.accentColor),
                          label: Text('Edit/View', style: TextStyle(color: theme.accentColor)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.accentColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
