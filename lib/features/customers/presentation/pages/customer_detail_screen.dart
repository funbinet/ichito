import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../data/models/customer.dart';
import '../../data/repositories/customer_repository.dart';
import '../../../orders/data/models/order.dart';
import '../../../orders/data/repositories/order_repository.dart';
import 'customer_form_screen.dart';
import 'widgets/customer_components.dart';
import '../../../dashboard/presentation/widgets/dashboard_components.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> with ThemeAwareMixin, NavigationMixin {
  final CustomerRepository _customerRepo = CustomerRepository();
  final OrderRepository _orderRepo = OrderRepository();
  
  Customer? _customer;
  List<Order> _recentOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    setState(() => _isLoading = true);
    final cust = await _customerRepo.getCustomerById(widget.customerId);
    if (cust == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    
    // We would fetch stats and orders from repos here. Mocking some for MVP.
    final orders = await _orderRepo.getByCustomer(widget.customerId);
    
    // Calculate stats
    double totalBilled = 0;
    double totalPaid = 0;
    for (var o in orders) {
      totalBilled += o.totalAmount;
      totalPaid += o.paidAmount;
    }
    
    setState(() {
      _customer = cust;
      // Injecting mocked/calculated stats into customer model for UI
      _customer!.totalOrders = orders.length;
      _customer!.totalSpent = totalPaid;
      if (orders.isNotEmpty) {
        _customer!.averageOrderValue = totalPaid / orders.length;
      }
      _recentOrders = orders.take(5).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(backgroundColor: theme.backgroundColor, elevation: 0),
        body: Center(child: CircularProgressIndicator(color: theme.accentColor)),
      );
    }

    if (_customer == null) {
      return Scaffold(
        backgroundColor: theme.backgroundColor,
        body: const Center(child: Text('Customer not found')),
      );
    }

    final language = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_customer!.name, style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.textPrimary),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: _customer)),
              );
              if (result == true) _loadCustomerData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _confirmDelete,
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: theme.textPrimary),
            onPressed: () {
              // Share logic
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildCustomerAnalytics(language),
          const SizedBox(height: 24),
          _buildMeasurementTable(),
          const SizedBox(height: 24),
          _buildOrderHistory(),
          const SizedBox(height: 24),
          _buildFinancialSummary(language),
          const SizedBox(height: 32),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: theme.accentLight,
          backgroundImage: _customer!.photoPath != null ? FileImage(File(_customer!.photoPath!)) : null,
          child: _customer!.photoPath == null
              ? Text(_customer!.initials, style: TextStyle(color: theme.accentColor, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily))
              : null,
        ),
        const SizedBox(height: 16),
        Text(_customer!.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
        const SizedBox(height: 16),
        
        // Contact Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_outlined, size: 16, color: theme.textSecondary),
            const SizedBox(width: 4),
            Text(_customer!.phone, style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily)),
            const SizedBox(width: 16),
            _buildActionChip('Call', Icons.call, () {}),
            const SizedBox(width: 8),
            _buildActionChip('SMS', Icons.sms, () {}),
          ],
        ),
        
        if (_customer!.email != null && _customer!.email!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 16, color: theme.textSecondary),
              const SizedBox(width: 4),
              Text(_customer!.email!, style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily)),
              const SizedBox(width: 16),
              _buildActionChip('Email', Icons.mail, () {}),
            ],
          ),
        ],
        
        if (_customer!.location != null && _customer!.location!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: theme.textSecondary),
              const SizedBox(width: 4),
              Text(_customer!.location!, style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily)),
            ],
          ),
        ],
        
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_customer!.gender.toLowerCase() == 'male' ? Icons.male : Icons.female, size: 16, color: theme.textSecondary),
            const SizedBox(width: 4),
            Text(_customer!.gender.capitalize(), style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
            const Text('  |  ', style: TextStyle(color: Colors.grey)),
            Text('${_customer!.totalOrders} Orders', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
            const Text('  |  ', style: TextStyle(color: Colors.grey)),
            Text('3 Years', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)), // Mocked years
          ],
        ),
        const SizedBox(height: 16),
        LoyaltyBadge(status: _customer!.loyaltyStatus),
      ],
    );
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: theme.borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: theme.accentColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, color: theme.textPrimary, fontFamily: theme.fontFamily)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerAnalytics(LanguageProvider language) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.cornerRadius,
        border: Border.all(color: theme.borderColor, width: 0.5),
        boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
      ),
      child: Column(
        children: [
          _buildStatRow(Icons.account_balance_wallet_outlined, 'Total Spent', language.formatCurrency(_customer!.totalSpent, showSymbol: true)),
          const SizedBox(height: 12),
          _buildStatRow(Icons.bar_chart_outlined, 'Average Order', language.formatCurrency(_customer!.averageOrderValue, showSymbol: true)),
          const SizedBox(height: 12),
          _buildStatRow(Icons.checkroom_outlined, 'Most Ordered', _customer!.preferredGarments.isNotEmpty ? '${_customer!.preferredGarments.first} (${_customer!.totalOrders})' : 'N/A'),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
      ],
    );
  }

  Widget _buildMeasurementTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Default Measurements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: _customer)),
                );
                if (result == true) _loadCustomerData();
              },
              child: Text('Edit', style: TextStyle(color: theme.accentColor, fontFamily: theme.fontFamily)),
            ),
          ],
        ),
        if (_customer!.measurements == null || _customer!.measurements!.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: theme.borderColor),
              borderRadius: theme.cornerRadius,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.straighten_outlined, size: 48, color: theme.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text('No Measurements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  Text('Default measurements have not been recorded.', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.borderColor),
              borderRadius: theme.cornerRadius,
            ),
            child: Column(
              children: _customer!.measurements!.entries.map((entry) {
                final isLast = entry.key == _customer!.measurements!.keys.last;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: isLast ? null : Border(bottom: BorderSide(color: theme.borderColor, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _formatMeasurementName(entry.key),
                        style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.value} cm', // Use lang settings for unit in future
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textPrimary, fontFamily: theme.fontFamily),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String _formatMeasurementName(String key) {
    return key.split('_').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  Widget _buildOrderHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order History (${_customer!.totalOrders})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
            if (_customer!.totalOrders > 5)
              TextButton(
                onPressed: () {},
                child: Text('View All', style: TextStyle(color: theme.accentColor, fontFamily: theme.fontFamily)),
              ),
          ],
        ),
        if (_recentOrders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('No orders yet.', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.borderColor),
              borderRadius: theme.cornerRadius,
            ),
            child: Column(
              children: _recentOrders.asMap().entries.map((entry) {
                final index = entry.key;
                final order = entry.value;
                final isLast = index == _recentOrders.length - 1;
                
                return Column(
                  children: [
                    ActivityFeedItem(order: order),
                    if (!isLast) Divider(color: theme.borderColor, height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildFinancialSummary(LanguageProvider language) {
    // Mocking calculation, actual is above
    double totalBilled = _customer!.totalSpent;
    double totalPaid = _customer!.totalSpent * 0.8; // mock 80% paid
    double outstanding = totalBilled - totalPaid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.cornerRadius,
        border: Border.all(color: theme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
          const SizedBox(height: 16),
          _buildStatRow(Icons.receipt_outlined, 'Total Billed:', language.formatCurrency(totalBilled, showSymbol: true)),
          const SizedBox(height: 8),
          _buildStatRow(Icons.payments_outlined, 'Total Paid:', language.formatCurrency(totalPaid, showSymbol: true)),
          const SizedBox(height: 8),
          _buildStatRow(Icons.money_off_outlined, 'Outstanding:', language.formatCurrency(outstanding, showSymbol: true)),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text('View Payment Details', style: TextStyle(color: theme.accentColor, fontFamily: theme.fontFamily)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text('Created: ${_customer!.createdAt.toString().split(' ')[0]}', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          Text('Last Order: ${_customer!.lastOrderDate?.toString().split(' ')[0] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Delete Customer?', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
        content: Text('This action cannot be undone. Are you sure you want to delete ${_customer!.name}?', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(fontFamily: theme.fontFamily)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _customerRepo.deleteCustomer(_customer!.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}
