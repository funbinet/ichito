import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../orders/data/repositories/order_repository.dart';
import '../../../orders/data/models/order.dart';
import '../widgets/welcome_header.dart';
import '../widgets/dashboard_components.dart';
import '../widgets/stat_card.dart';
import '../../../../shared/services/export_service.dart';
import '../../../customers/data/repositories/customer_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with ThemeAwareMixin, NavigationMixin {
  final OrderRepository _orderRepo = OrderRepository();
  final CustomerRepository _customerRepo = CustomerRepository();
  
  int _activeOrdersCount = 0;
  double _monthlyRevenue = 0.0;
  int _activeClientsCount = 0;
  String _topGarment = 'None';
  
  List<double> _ordersChartData = List.filled(7, 0);
  List<double> _revenueChartData = List.filled(7, 0);
  
  List<Order> _recentOrders = [];
  List<Order> _upcomingDeadlines = [];
  bool _isLoading = true;
  int _currentStatPage = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final orders = await _orderRepo.getAllOrders();
      final customers = await _customerRepo.getAllCustomers();
      
      _activeClientsCount = customers.length;
      
      _activeOrdersCount = orders.where((o) => o.status != 'completed' && o.status != 'cancelled').length;
      
      final now = DateTime.now();
      _monthlyRevenue = orders
          .where((o) => o.orderDate.month == now.month && o.orderDate.year == now.year)
          .fold(0.0, (sum, o) => sum + o.paidAmount);

      // Calculate Top Garment
      final garmentCounts = <String, int>{};
      for (var o in orders) {
        if (o.garmentName != null && o.garmentName!.isNotEmpty) {
          garmentCounts[o.garmentName!] = (garmentCounts[o.garmentName!] ?? 0) + 1;
        }
      }
      if (garmentCounts.isNotEmpty) {
        var top = garmentCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
        _topGarment = top.key;
      } else {
        _topGarment = 'None';
      }

      // Generate Chart Data (past 7 days)
      List<double> dailyOrders = List.filled(7, 0);
      List<double> dailyRevenue = List.filled(7, 0);
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: 6 - i));
        final dayOrders = orders.where((o) => 
            o.orderDate.year == date.year && 
            o.orderDate.month == date.month && 
            o.orderDate.day == date.day);
            
        dailyOrders[i] = dayOrders.length.toDouble();
        dailyRevenue[i] = dayOrders.fold(0.0, (sum, o) => sum + o.paidAmount);
      }
      _ordersChartData = dailyOrders;
      _revenueChartData = dailyRevenue;

      // Upcoming deadlines: active orders due within 7 days
      _upcomingDeadlines = orders
          .where((o) => o.status != 'completed' && o.status != 'cancelled')
          .where((o) {
            final daysUntil = o.dueDate.difference(now).inDays;
            return daysUntil <= 7 && daysUntil >= 0;
          })
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

      // Sort by order date descending for recent
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      _recentOrders = orders.take(5).toList();
    } catch (e) {
      // Handle gracefully — tables might have no data yet
      _activeOrdersCount = 0;
      _monthlyRevenue = 0.0;
      _recentOrders = [];
      _upcomingDeadlines = [];
    }

    setState(() => _isLoading = false);
  }

  Future<void> _exportToPDF() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF Report...')));
    await ExportService.exportStatsToPDF(
      title: 'Dashboard Overview',
      fileNamePrefix: 'dashboard_stats',
      stats: {
        'Active Orders': _activeOrdersCount.toString(),
        'Monthly Revenue': lang.formatCurrency(_monthlyRevenue, showSymbol: true),
      },
    );
  }

  Future<void> _exportToCSV() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting CSV...')));
    await ExportService.exportStatsToCSV(
      title: 'Dashboard Overview',
      fileNamePrefix: 'dashboard_stats',
      stats: {
        'Active Orders': _activeOrdersCount.toString(),
        'Monthly Revenue': _monthlyRevenue.toStringAsFixed(2),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: _isLoading 
          ? Center(child: CircularProgressIndicator(color: theme.accentColor))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: theme.accentColor,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: WelcomeHeader(
                      onExportCSV: _exportToCSV,
                      onExportPDF: _exportToPDF,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildStatisticsCarousel(),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  SliverToBoxAdapter(
                    child: _buildQuickActionGrid(),
                  ),
                  // Upcoming Deadlines Section
                  if (_upcomingDeadlines.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: language.t('upcoming_deadlines') ?? 'Upcoming Deadlines',
                        actionLabel: language.t('view_all'),
                        onActionTap: () => navigateTo('/orders'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildUpcomingDeadlines(),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: language.t('recent_activity') ?? 'Recent Activity',
                      actionLabel: language.t('view_all'),
                      onActionTap: () => navigateTo('/orders'),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (_recentOrders.isEmpty) {
                          return _buildEmptyState();
                        }
                        return ActivityFeedItem(order: _recentOrders[index]);
                      },
                      childCount: _recentOrders.isEmpty ? 1 : _recentOrders.length,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80), // Padding for RadialMenu
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildStatisticsCarousel() {
    final language = Provider.of<LanguageProvider>(context);
    
    // Check if chart data is all zeros
    final bool hasOrderData = _ordersChartData.any((v) => v > 0);
    final bool hasRevenueData = _revenueChartData.any((v) => v > 0);
    
    final statCards = [
      ChartStatCard(
        icon: Icons.shopping_bag_outlined,
        title: language.t('orders'), // 'Active Orders'
        value: '$_activeOrdersCount',
        trendPercentage: 0.0,
        trendPositive: true,
        chartType: ChartType.bar,
        data: hasOrderData ? _ordersChartData : const [0, 0, 0, 0, 0, 0, 0],
      ),
      ChartStatCard(
        icon: Icons.account_balance_wallet_outlined,
        title: language.t('total_amount'), // 'Revenue This Month' -> Using 'Total' for now or add new string
        value: language.formatCurrency(_monthlyRevenue, showSymbol: true),
        trendPercentage: 0.0,
        trendPositive: true,
        chartType: ChartType.line,
        data: hasRevenueData ? _revenueChartData : const [0, 0, 0, 0, 0, 0, 0],
      ),
      ChartStatCard(
        icon: Icons.people_outlined,
        title: language.t('customers'), // 'Active Clients'
        value: '$_activeClientsCount',
        trendPercentage: 0.0,
        trendPositive: true,
        chartType: ChartType.bar,
        data: const [0, 0, 0, 0, 0, 0, 0],
      ),
      ChartStatCard(
        icon: Icons.sell_outlined,
        title: language.t('garments'), // 'Top Garment'
        value: _topGarment,
        trendPercentage: 0.0,
        trendPositive: true,
        chartType: ChartType.bar,
        data: const [0, 0, 0, 0, 0, 0, 0],
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 220, // Increased for large card with chart
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.90),
            onPageChanged: (index) => setState(() => _currentStatPage = index),
            itemCount: statCards.length,
            itemBuilder: (context, index) {
              return statCards[index];
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            statCards.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentStatPage
                  ? theme.accentColor
                  : theme.textSecondary.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildQuickActionGrid() {
    final language = Provider.of<LanguageProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.80,
        children: [
          QuickActionTile(
            label: language.t('new_order'),
            subtitle: language.t('create'),
            icon: Icons.add_shopping_cart_outlined,
            onTap: () => navigateTo('/order_wizard'),
          ),
          QuickActionTile(
            label: language.t('customers'),
            subtitle: language.t('add'),
            icon: Icons.people_outlined,
            onTap: () => navigateTo('/customers'),
          ),
          QuickActionTile(
            label: language.t('garments'),
            subtitle: language.t('view_all'),
            icon: Icons.checkroom_outlined,
            onTap: () => navigateTo('/garments'),
          ),
          QuickActionTile(
            label: language.t('fabrics'),
            subtitle: language.t('view_all'),
            icon: Icons.texture_outlined,
            onTap: () => navigateTo('/fabrics'),
          ),
          QuickActionTile(
            label: language.t('designs'),
            subtitle: language.t('view_all'),
            icon: Icons.palette_outlined,
            onTap: () => navigateTo('/designs'),
          ),
          QuickActionTile(
            label: language.t('notes'),
            subtitle: language.t('view_all'),
            icon: Icons.note_outlined,
            onTap: () => navigateTo('/notes'),
          ),
          QuickActionTile(
            label: language.t('statistics'),
            subtitle: language.t('view_all'),
            icon: Icons.bar_chart_outlined,
            onTap: () => navigateTo('/analytics'),
          ),
          QuickActionTile(
            label: language.t('settings'),
            subtitle: language.t('view_all'),
            icon: Icons.settings_outlined,
            onTap: () => navigateTo('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _upcomingDeadlines.length,
        itemBuilder: (context, index) {
          final order = _upcomingDeadlines[index];
          final daysLeft = order.dueDate.difference(DateTime.now()).inDays;
          final isOverdue = daysLeft < 0;
          final isToday = daysLeft == 0;

          return GestureDetector(
            onTap: () => navigateTo('/orders/detail', arguments: order.id),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: theme.cornerRadius,
                border: Border.all(
                  color: isOverdue
                      ? const Color(0xFFF44336).withOpacity(0.5)
                      : isToday
                          ? const Color(0xFFFF9800).withOpacity(0.5)
                          : theme.accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                      fontFamily: theme.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (order.customerName != null)
                    Text(
                      order.customerName!,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                        fontFamily: theme.fontFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? const Color(0xFFF44336).withOpacity(0.15)
                          : isToday
                              ? const Color(0xFFFF9800).withOpacity(0.15)
                              : theme.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOverdue
                          ? '${-daysLeft}d overdue'
                          : isToday
                              ? 'Due today!'
                              : '${daysLeft}d left',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOverdue
                            ? const Color(0xFFF44336)
                            : isToday
                                ? const Color(0xFFFF9800)
                                : theme.accentColor,
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.precision_manufacturing_outlined, size: 64, color: theme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'Welcome to ICHITO!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding your first customer and creating an order.',
              style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
