import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../data/models/garment.dart';

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}

class GarmentCard extends StatelessWidget {
  final Garment garment;
  final VoidCallback onTap;
  
  const GarmentCard({
    super.key,
    required this.garment,
    required this.onTap,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'men': return const Color(0xFF2196F3);
      case 'women': return const Color(0xFFE91E63);
      case 'unisex': return const Color(0xFF4CAF50);
      default: return const Color(0xFF9E9E9E);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
          border: Border.all(color: theme.borderColor, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Garment icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.checkroom_outlined, color: theme.accentColor, size: 28),
            ),
            SizedBox(height: 8),
            // Name
            Text(
              garment.name,
              style: TextStyle(
                fontSize: theme.fontSize * 0.81,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            // Measurement count
            Text(
              '${garment.measurementFields.length} measurements',
              style: TextStyle(fontSize: theme.fontSize * 0.69, color: theme.textSecondary, fontFamily: theme.fontFamily),
            ),
            // Category badge
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _getCategoryColor(garment.category).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                garment.category.capitalize(),
                style: TextStyle(
                  fontSize: theme.fontSize * 0.62,
                  color: _getCategoryColor(garment.category),
                  fontFamily: theme.fontFamily,
                ),
              ),
            ),
            SizedBox(height: 4),
            // Usage count
            Text(
              '${garment.usageCount ?? 0} orders',
              style: TextStyle(fontSize: theme.fontSize * 0.62, color: theme.textSecondary, fontFamily: theme.fontFamily),
            ),
          ],
        ),
      ),
    );
  }
}

class GarmentListTile extends StatelessWidget {
  final Garment garment;
  final VoidCallback onTap;
  
  const GarmentListTile({
    super.key,
    required this.garment,
    required this.onTap,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'men': return const Color(0xFF2196F3);
      case 'women': return const Color(0xFFE91E63);
      case 'unisex': return const Color(0xFF4CAF50);
      default: return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.borderColor, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.checkroom_outlined, color: theme.accentColor, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(garment.name,
                    style: TextStyle(fontSize: theme.fontSize * 0.94, fontWeight: FontWeight.w600, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  SizedBox(height: 2),
                  Text('${garment.measurementFields.length} measurements',
                    style: TextStyle(fontSize: theme.fontSize * 0.81, color: theme.textSecondary, fontFamily: theme.fontFamily)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(garment.category).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    garment.category.capitalize(),
                    style: TextStyle(
                      fontSize: theme.fontSize * 0.62,
                      color: _getCategoryColor(garment.category),
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text('${garment.usageCount ?? 0} orders',
                  style: TextStyle(fontSize: theme.fontSize * 0.69, color: theme.textSecondary, fontFamily: theme.fontFamily)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
