import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../orders/data/repositories/order_repository.dart';
import '../../../orders/data/models/order.dart';
import '../../../../shared/services/export_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with ThemeAwareMixin {
  final OrderRepository _orderRepo = OrderRepository();
  bool _isLoading = true;

  double _totalRevenue = 0;
  double _pendingBalances = 0;
  int _totalOrders = 0;
  int _completedOrders = 0;

  List<FlSpot> _revenueData = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    final orders = await _orderRepo.getAllOrders();
    final allPayments = <Payment>[];
    
    double revenue = 0;
    double pending = 0;
    int completed = 0;

    for (var o in orders) {
      if (o.status == 'completed') completed++;
      revenue += o.paidAmount;
      pending += o.balance;
      
      final payments = await _orderRepo.getPaymentsForOrder(o.id!);
      allPayments.addAll(payments);
    }

    // Group payments by month for chart (dummy logic for simple 6 months)
    final now = DateTime.now();
    final Map<int, double> monthlySums = {};
    for (int i = 5; i >= 0; i--) {
      monthlySums[now.month - i] = 0.0; // initialize past 6 months
    }

    for (var p in allPayments) {
      if (monthlySums.containsKey(p.date.month)) {
        monthlySums[p.date.month] = monthlySums[p.date.month]! + p.amount;
      }
    }

    int xIndex = 0;
    final spots = <FlSpot>[];
    monthlySums.forEach((month, amount) {
      spots.add(FlSpot(xIndex.toDouble(), amount));
      xIndex++;
    });

    setState(() {
      _totalOrders = orders.length;
      _completedOrders = completed;
      _totalRevenue = revenue;
      _pendingBalances = pending;
      _revenueData = spots;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      appBar: AppBar(
        title: Text('Analytics & Reports'.t(context), style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF'.t(context),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generating PDF Report...'.t(context))));
              await ExportService.exportStatsToPDF(
                title: 'Analytics Report'.t(context),
                fileNamePrefix: 'analytics_report',
                stats: {
                  'Total Revenue': lang.formatCurrency(_totalRevenue, showSymbol: true),
                  'Pending Balances': lang.formatCurrency(_pendingBalances, showSymbol: true),
                  'Total Orders': _totalOrders.toString(),
                  'Completed Orders': _completedOrders.toString(),
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.table_chart_outlined),
            tooltip: 'Export CSV'.t(context),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exporting CSV...'.t(context))));
              await ExportService.exportStatsToCSV(
                title: 'Analytics Report'.t(context),
                fileNamePrefix: 'analytics_report',
                stats: {
                  'Total Revenue': _totalRevenue.toStringAsFixed(2),
                  'Pending Balances': _pendingBalances.toStringAsFixed(2),
                  'Total Orders': _totalOrders.toString(),
                  'Completed Orders': _completedOrders.toString(),
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.accentColor))
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _buildSummaryCards(),
                SizedBox(height: 24),
                Text('Revenue Trend (Last 6 Months)'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
                SizedBox(height: 16),
                _buildRevenueChart(),
              ],
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildCard('Total Revenue', lang.formatCurrency(_totalRevenue, showSymbol: true), Colors.green)),
            SizedBox(width: 16),
            Expanded(child: _buildCard('Pending Bal.', lang.formatCurrency(_pendingBalances, showSymbol: true), Colors.red)),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildCard('Total Orders', _totalOrders.toString(), theme.accentColor)),
            SizedBox(width: 16),
            Expanded(child: _buildCard('Completed', _completedOrders.toString(), Colors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: headingStyle.copyWith(fontSize: theme.fontSize * 1.25, color: color)),
            SizedBox(height: 8),
            Text(title, style: subtitleStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.cornerRadius,
        border: Border.all(color: theme.accentColor.withOpacity(0.3), width: 1),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _revenueData,
              isCurved: true,
              color: theme.accentColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.accentColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
