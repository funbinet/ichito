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
        border: Border.all(color: theme.accentColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.accentColor, size: 28),
          const Spacer(),
          Text(title,
            style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          const SizedBox(height: 4),
          Text(value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              fontFamily: theme.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (trendPercentage != null) ...[
            const SizedBox(height: 6),
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
                Flexible(
                  child: Text(
                    '${trendPositive ? "+" : ""}${trendPercentage!.toStringAsFixed(0)}% this month',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: trendPositive
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                      fontFamily: theme.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
