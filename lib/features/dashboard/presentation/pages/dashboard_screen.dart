import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../orders/data/repositories/order_repository.dart';
import '../../../orders/data/models/order.dart';
import '../widgets/welcome_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/dashboard_components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with ThemeAwareMixin, NavigationMixin {
  final OrderRepository _orderRepo = OrderRepository();
  
  int _activeOrdersCount = 0;
  double _monthlyRevenue = 0.0;
  List<Order> _recentOrders = [];
  bool _isLoading = true;
  int _currentStatPage = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    final orders = await _orderRepo.getAllOrders();
    _activeOrdersCount = orders.where((o) => o.status != 'completed' && o.status != 'cancelled').length;
    
    _monthlyRevenue = orders
        .where((o) => o.orderDate.month == DateTime.now().month)
        .fold(0.0, (sum, o) => sum + o.paidAmount);

    // Sort by order date descending
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    _recentOrders = orders.take(5).toList();

    setState(() => _isLoading = false);
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
                      notificationCount: 3, // Dummy for now
                      onNotificationTap: () {},
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildStatisticsCarousel(),
                  ),
                  SliverToBoxAdapter(
                    child: const SizedBox(height: 16),
                  ),
                  SliverToBoxAdapter(
                    child: _buildQuickActionGrid(),
                  ),
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Recent Activity',
                      actionLabel: 'View All',
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
    final statCards = [
      StatCard(
        icon: Icons.shopping_bag_outlined,
        title: 'Orders This Month',
        value: '$_activeOrdersCount',
        trendPercentage: 12,
        trendPositive: true,
      ),
      StatCard(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Revenue This Month',
        value: language.formatCurrency(_monthlyRevenue, showSymbol: true),
        trendPercentage: 8,
        trendPositive: true,
      ),
      const StatCard(
        icon: Icons.people_outlined,
        title: 'Active Customers',
        value: '24',
        trendPercentage: 5,
        trendPositive: true,
      ),
      const StatCard(
        icon: Icons.checkroom_outlined,
        title: 'Top Garment',
        value: 'Dresses',
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            onPageChanged: (index) => setState(() => _currentStatPage = index),
            itemCount: (statCards.length / 2).ceil(),
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * 2;
              return Row(
                children: [
                  Expanded(child: statCards[startIndex]),
                  if (startIndex + 1 < statCards.length)
                    Expanded(child: statCards[startIndex + 1])
                  else
                    Expanded(child: Container()), // Empty placeholder
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            (statCards.length / 2).ceil(),
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
            label: 'New Order',
            subtitle: 'Create',
            icon: Icons.add_shopping_cart_outlined,
            onTap: () => navigateTo('/orders/new'),
          ),
          QuickActionTile(
            label: 'Customers',
            subtitle: 'Manage',
            icon: Icons.people_outlined,
            onTap: () => navigateTo('/customers'),
          ),
          QuickActionTile(
            label: 'Garments',
            subtitle: 'Types',
            icon: Icons.checkroom_outlined,
            onTap: () => navigateTo('/garments'),
          ),
          QuickActionTile(
            label: 'Fabrics',
            subtitle: 'Library',
            icon: Icons.texture_outlined,
            onTap: () => navigateTo('/fabrics'),
          ),
          QuickActionTile(
            label: 'Designs',
            subtitle: 'Gallery',
            icon: Icons.palette_outlined,
            onTap: () => navigateTo('/designs'),
          ),
          QuickActionTile(
            label: 'Notes',
            subtitle: 'Tasks',
            icon: Icons.note_outlined,
            onTap: () => navigateTo('/notes'),
          ),
          QuickActionTile(
            label: 'Statistics',
            subtitle: 'View',
            icon: Icons.bar_chart_outlined,
            onTap: () => navigateTo('/analytics'),
          ),
          QuickActionTile(
            label: 'Settings',
            subtitle: 'Configure',
            icon: Icons.settings_outlined,
            onTap: () => navigateTo('/settings'),
          ),
        ],
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
