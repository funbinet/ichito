import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import 'order_wizard_screen.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with ThemeAwareMixin, NavigationMixin {
  final OrderRepository _repository = OrderRepository();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _repository.getAllOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'trial': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return theme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('orders'), style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: theme.accentColor))
        : _orders.isEmpty 
          ? _buildEmptyState() 
          : _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderWizardScreen()),
          );
          if (result == true) _loadOrders();
        },
        backgroundColor: theme.accentColor,
        foregroundColor: theme.onAccent,
        child: const Icon(Icons.add_outlined),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: theme.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No orders yet', style: subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        final isOverdue = order.isOverdue;
        
        return Card(
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: theme.cornerRadius,
            side: isOverdue ? const BorderSide(color: Colors.red, width: 1) : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNumber, style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(color: _getStatusColor(order.status), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Customer: ${order.customerName ?? 'Unknown'}', style: bodyStyle),
                Text('Due: ${lang.formatDate(order.dueDate)}', style: isOverdue ? bodyStyle.copyWith(color: Colors.red) : subtitleStyle),
                const SizedBox(height: 4),
                Text(
                  'Balance: ${lang.formatCurrency(order.balance)}',
                  style: subtitleStyle.copyWith(
                    color: order.isFullyPaid ? Colors.green : theme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id!)),
              );
              _loadOrders();
            },
          ),
        );
      },
    );
  }
}
