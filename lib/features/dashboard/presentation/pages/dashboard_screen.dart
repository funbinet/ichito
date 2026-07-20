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
import '../widgets/stat_card.dart';
import '../../../../shared/services/export_service.dart';
import '../../../../shared/providers/customer_provider.dart';
import '../../../../shared/providers/order_provider.dart';
import '../../../../shared/widgets/square_avatar.dart';
import '../widgets/dashboard_components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with ThemeAwareMixin, NavigationMixin {
  int _currentStatPage = 0;

  @override
  void initState() {
    super.initState();
    // Load data initially just in case, though main.dart already loads it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
      Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
    });
  }


  Future<void> _exportToPDF() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final activeOrdersCount = orderProvider.orders.length;
    final now = DateTime.now();
    final monthlyRevenue = orderProvider.orders
        .where((o) => o.orderDate.month == now.month && o.orderDate.year == now.year)
        .fold(0.0, (sum, o) => sum + o.paidAmount);

    final lang = Provider.of<LanguageProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF Report...'.t(context))));
    await ExportService.exportStatsToPDF(
      title: 'Dashboard Overview'.t(context),
      fileNamePrefix: 'dashboard_stats',
      stats: {
        'Active Orders': activeOrdersCount.toString(),
        'Monthly Revenue': lang.formatCurrency(monthlyRevenue, showSymbol: true),
      },
    );
  }

  Future<void> _exportToCSV() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final activeOrdersCount = orderProvider.orders.length;
    final now = DateTime.now();
    final monthlyRevenue = orderProvider.orders
        .where((o) => o.orderDate.month == now.month && o.orderDate.year == now.year)
        .fold(0.0, (sum, o) => sum + o.paidAmount);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting CSV...'.t(context))));
    await ExportService.exportStatsToCSV(
      title: 'Dashboard Overview'.t(context),
      fileNamePrefix: 'dashboard_stats',
      stats: {
        'Active Orders': activeOrdersCount.toString(),
        'Monthly Revenue': monthlyRevenue.toStringAsFixed(2),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);

    // Calculate dynamic stats
    final orders = orderProvider.orders;
    final customers = customerProvider.customers;
    
    final activeClientsCount = customers.length;
    // Count ALL orders per user request
    final activeOrdersCount = orders.length; 
    
    final now = DateTime.now();
    final monthlyRevenue = orders
        .where((o) => o.orderDate.month == now.month && o.orderDate.year == now.year)
        .fold(0.0, (sum, o) => sum + o.paidAmount);

    String topGarment = 'None';
    final garmentCounts = <String, int>{};
    for (var o in orders) {
      if (o.garmentName != null && o.garmentName!.isNotEmpty) {
        garmentCounts[o.garmentName!] = (garmentCounts[o.garmentName!] ?? 0) + 1;
      }
    }
    if (garmentCounts.isNotEmpty) {
      var top = garmentCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      topGarment = top.key;
    }

    List<double> ordersChartData = List.filled(7, 0);
    List<double> revenueChartData = List.filled(7, 0);
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayOrders = orders.where((o) => 
          o.orderDate.year == date.year && 
          o.orderDate.month == date.month && 
          o.orderDate.day == date.day);
          
      ordersChartData[i] = dayOrders.length.toDouble();
      revenueChartData[i] = dayOrders.fold(0.0, (sum, o) => sum + o.paidAmount);
    }

    final upcomingDeadlines = orders
        .where((o) => o.status != 'completed' && o.status != 'cancelled')
        .where((o) {
          final daysUntil = o.dueDate.difference(now).inDays;
          return daysUntil <= 7 && daysUntil >= 0;
        })
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final recentOrders = List<Order>.from(orders)
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    final displayRecentOrders = recentOrders.take(5).toList();
    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: (orderProvider.isLoading && orders.isEmpty) || (customerProvider.isLoading && customers.isEmpty)
          ? Center(child: CircularProgressIndicator(color: theme.accentColor))
          : RefreshIndicator(
              onRefresh: () async {
                await orderProvider.loadOrders();
                await customerProvider.loadCustomers();
              },
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
                    child: _buildStatisticsCarousel(
                      activeOrdersCount: activeOrdersCount,
                      monthlyRevenue: monthlyRevenue,
                      activeClientsCount: activeClientsCount,
                      topGarment: topGarment,
                      ordersChartData: ordersChartData,
                      revenueChartData: revenueChartData,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  SliverToBoxAdapter(
                    child: _buildQuickActionGrid(),
                  ),
                  // Upcoming Deadlines Section
                  if (upcomingDeadlines.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: language.t('upcoming_deadlines') ?? 'Upcoming Deadlines',
                        actionLabel: language.t('view_all'),
                        onActionTap: () => navigateTo('/orders'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildUpcomingDeadlines(upcomingDeadlines),
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
                        if (displayRecentOrders.isEmpty) {
                          return _buildEmptyState();
                        }
                        return ActivityFeedItem(order: displayRecentOrders[index]);
                      },
                      childCount: displayRecentOrders.isEmpty ? 1 : displayRecentOrders.length,
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

  Widget _buildStatisticsCarousel({
    required int activeOrdersCount,
    required double monthlyRevenue,
    required int activeClientsCount,
    required String topGarment,
    required List<double> ordersChartData,
    required List<double> revenueChartData,
  }) {
    final language = Provider.of<LanguageProvider>(context);
    
    // Check if chart data is all zeros
    final bool hasOrderData = ordersChartData.any((v) => v > 0);
    final bool hasRevenueData = revenueChartData.any((v) => v > 0);
    
    final statCards = [
      ChartStatCard(
        icon: Icons.shopping_bag_outlined,
        title: language.t('orders'), // 'Active Orders'
        value: '$activeOrdersCount',
        trendPercentage: 0.0,
        trendPositive: true,
        chartType: ChartType.bar,
        data: hasOrderData ? ordersChartData : const [0, 0, 0, 0, 0, 0, 0],
      ),
      ChartStatCard(
        icon: Icons.account_balance_wallet_outlined,
        title: language.t('total_amount'), // 'Revenue This Month'
        value: language.formatCurrency(monthlyRevenue, showSymbol: true),
        trendPercentage: 0.0,
        trendPositive: true,
        chartType: ChartType.line,
        data: hasRevenueData ? revenueChartData : const [0, 0, 0, 0, 0, 0, 0],
      ),
      ChartStatCard(
        icon: Icons.people_outlined,
        title: language.t('customers'), // 'Active Clients'
        value: '$activeClientsCount',
        trendPercentage: 0.0,
        trendPositive: true,
        chartType: ChartType.bar,
        data: const [0, 0, 0, 0, 0, 0, 0],
      ),
      ChartStatCard(
        icon: Icons.sell_outlined,
        title: language.t('garments'), // 'Top Garment'
        value: topGarment,
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
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            statCards.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
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
      padding: EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildUpcomingDeadlines(List<Order> upcomingDeadlines) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: upcomingDeadlines.length,
        itemBuilder: (context, index) {
          final order = upcomingDeadlines[index];
          final daysLeft = order.dueDate.difference(DateTime.now()).inDays;
          final isOverdue = daysLeft < 0;
          final isToday = daysLeft == 0;

          return GestureDetector(
            onTap: () => navigateTo('/orders/detail', arguments: order.id),
            child: Container(
              width: 160,
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.all(12),
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
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.precision_manufacturing_outlined, size: 64, color: theme.textSecondary.withOpacity(0.3)),
            SizedBox(height: 16),
            Text(
              'Welcome to ICHITO!'.t(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Start by adding your first customer and creating an order.'.t(context),
              style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
