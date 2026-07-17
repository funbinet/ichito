import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double? trendPercentage;
  final bool trendPositive;
  
  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trendPercentage,
    this.trendPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.cornerRadius,
        boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
        border: Border.all(color: theme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.accentColor, size: 28),
          const SizedBox(height: 12),
          Text(title,
            style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          const SizedBox(height: 4),
          Text(value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              fontFamily: theme.fontFamily,
            )),
          if (trendPercentage != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  trendPositive
                    ? Icons.trending_up_outlined
                    : Icons.trending_down_outlined,
                  size: 16,
                  color: trendPositive
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
                ),
                const SizedBox(width: 4),
                Text(
                  '${trendPositive ? "+" : ""}${trendPercentage!.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendPositive
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
