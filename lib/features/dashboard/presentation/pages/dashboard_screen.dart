import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/radial_menu_fab.dart';
import '../../../../shared/data/local/settings_repository.dart';
import '../../../orders/data/repositories/order_repository.dart';
import '../../../orders/presentation/pages/order_wizard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with ThemeAwareMixin, NavigationMixin {
  final SettingsRepository _settings = SettingsRepository();
  final OrderRepository _orderRepo = OrderRepository();
  
  String _businessName = '';
  int _activeOrders = 0;
  double _monthlyRevenue = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    _businessName = _settings.getBusinessName();
    
    // Calculate simple stats
    final orders = await _orderRepo.getAllOrders();
    _activeOrders = orders.where((o) => o.status != 'completed' && o.status != 'cancelled').length;
    
    // In a real implementation this would use the SQL sum aggregation
    _monthlyRevenue = orders
        .where((o) => o.orderDate.month == DateTime.now().month)
        .fold(0.0, (sum, o) => sum + o.paidAmount);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_businessName, style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: theme.textPrimary),
            onPressed: () => navigateTo('/settings'),
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: theme.accentColor))
        : RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: theme.accentColor,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(lang.t('welcome_back'), style: subtitleStyle),
                const SizedBox(height: 24),
                _buildQuickStats(),
                const SizedBox(height: 32),
                _buildQuickActions(),
                const SizedBox(height: 32),
                Text(lang.t('recent_orders'), style: headingStyle.copyWith(fontSize: 20)),
                const SizedBox(height: 16),
                _buildRecentOrdersOrEmptyState(),
              ],
            ),
          ),
      floatingActionButton: RadialMenuFAB(
        onNewOrder: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderWizardScreen()));
          if (result == true) _loadDashboardData();
        },
        onAddCustomer: () => navigateTo('/customers'),
        onAddNote: () => navigateTo('/notes'),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Active Orders', _activeOrders.toString(), Icons.pending_actions_outlined, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Revenue (This Mth)', lang.formatCurrency(_monthlyRevenue, showSymbol: false), Icons.payments_outlined, Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.cornerRadius,
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 16),
          Text(value, style: headingStyle.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text(title, style: subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lang.t('quick_actions'), style: headingStyle.copyWith(fontSize: 20)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(Icons.people_outline, lang.t('customers'), () => navigateTo('/customers')),
            _buildActionItem(Icons.checkroom_outlined, 'Garments', () => navigateTo('/garments')),
            _buildActionItem(Icons.inventory_2_outlined, 'Fabrics', () {}),
            _buildActionItem(Icons.bar_chart_outlined, 'Reports', () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: theme.cornerRadius,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.accentLight,
            child: Icon(icon, color: theme.accentColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: bodyStyle.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersOrEmptyState() {
    if (_activeOrders == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: theme.textSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('No active orders right now', style: subtitleStyle),
            ],
          ),
        ),
      );
    }
    // List logic omitted for brevity; this would fetch from OrderRepository
    return Center(child: Text('View All Orders', style: TextStyle(color: theme.accentColor)));
  }
}
