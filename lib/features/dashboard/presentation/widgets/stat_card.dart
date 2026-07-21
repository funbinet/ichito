import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import 'package:fl_chart/fl_chart.dart';

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
      margin: EdgeInsets.symmetric(horizontal: 6),
      padding: EdgeInsets.all(16),
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
            style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          SizedBox(height: 4),
          Text(value,
            style: TextStyle(
              fontSize: theme.fontSize * 1.38,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              fontFamily: theme.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (trendPercentage != null) ...[
            SizedBox(height: 6),
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
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${trendPositive ? "+" : ""}${trendPercentage!.toStringAsFixed(0)}% this month',
                    style: TextStyle(
                      fontSize: theme.fontSize * 0.69,
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

enum ChartType { line, bar }

class ChartStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double? trendPercentage;
  final bool trendPositive;
  final ChartType chartType;
  final List<double> data;
  
  const ChartStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trendPercentage,
    this.trendPositive = true,
    required this.chartType,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.cornerRadius,
        boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
        border: Border.all(color: theme.accentColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.accentColor, size: 28),
              ),
              if (trendPercentage != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: trendPositive
                        ? const Color(0xFF4CAF50).withOpacity(0.15)
                        : const Color(0xFFF44336).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendPositive ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: trendPositive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${trendPositive ? "+" : ""}${trendPercentage!.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: theme.fontSize * 0.75,
                          fontWeight: FontWeight.bold,
                          color: trendPositive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                          fontFamily: theme.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Text(title,
            style: TextStyle(fontSize: theme.fontSize * 0.88, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          SizedBox(height: 4),
          Text(value,
            style: TextStyle(
              fontSize: theme.fontSize * 1.75,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              fontFamily: theme.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16),
          Expanded(
            child: _buildChart(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeProvider theme) {
    if (data.isEmpty) return SizedBox();

    if (chartType == ChartType.line) {
      List<FlSpot> spots = [];
      for (int i = 0; i < data.length; i++) {
        spots.add(FlSpot(i.toDouble(), data[i]));
      }
      return LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.accentColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.accentColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      );
    } else {
      List<BarChartGroupData> groups = [];
      for (int i = 0; i < data.length; i++) {
        groups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                color: theme.accentColor,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }
      return BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: groups,
        ),
      );
    }
  }
}

