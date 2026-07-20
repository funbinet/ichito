import 'dart:convert';
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
import '../widgets/customer_components.dart';
import '../../../dashboard/presentation/widgets/dashboard_components.dart';
import '../../../../shared/widgets/auth_delete_dialog.dart';
import '../../../../shared/widgets/square_avatar.dart';
import '../../../security/services/security_service.dart';
import '../../../../shared/providers/customer_provider.dart';
import '../../../../shared/providers/order_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  
  String _topGarments = 'N/A';
  String _topFabrics = 'N/A';
  String _topDesigns = 'N/A';

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<CustomerProvider>(context, listen: false);
    final cust = provider.getCustomerById(widget.customerId);
    if (cust == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    
    // We would fetch stats and orders from repos here. Mocking some for MVP.
    final orders = await _orderRepo.getByCustomer(widget.customerId);
    
    // Calculate stats
    double totalBilled = 0;
    double totalPaid = 0;
    
    Map<String, int> garmentCounts = {};
    Map<String, int> fabricCounts = {};
    Map<String, int> designCounts = {};

    for (var o in orders) {
      totalBilled += o.totalAmount;
      totalPaid += o.paidAmount;
      if (o.garmentName != null) {
        garmentCounts[o.garmentName!] = (garmentCounts[o.garmentName!] ?? 0) + 1;
      }
      if (o.fabricName != null) {
        fabricCounts[o.fabricName!] = (fabricCounts[o.fabricName!] ?? 0) + 1;
      }
      // Assuming designName could be added, or fallback to designId for now. (The query might not join designs yet, we'll use designId if so)
      if (o.designId != null) {
        designCounts[o.designId!] = (designCounts[o.designId!] ?? 0) + 1;
      }
    }
    
    String getTop3(Map<String, int> counts) {
      if (counts.isEmpty) return 'N/A';
      var entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      return entries.take(3).map((e) => '${e.key} (${e.value})').join(', ');
    }
    
    setState(() {
      _customer = cust;
      _customer!.totalOrders = orders.length;
      _customer!.totalSpent = totalPaid;
      if (orders.isNotEmpty) {
        _customer!.averageOrderValue = totalPaid / orders.length;
      }
      _topGarments = getTop3(garmentCounts);
      _topFabrics = getTop3(fabricCounts);
      _topDesigns = getTop3(designCounts);
      
      _recentOrders = orders.take(10).toList();
      _isLoading = false;
    });
  }

  void _launchUrl(String scheme, String path) async {
    final Uri url = Uri(scheme: scheme, path: path);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
  
  Future<void> _updatePhoto() async {
    // Placeholder for photo update logic
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo update coming soon'.t(context))));
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
        body: Center(child: Text('Customer not found'.t(context))),
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
            icon: Icon(Icons.delete_outline, color: Colors.red),
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
        padding: EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          SizedBox(height: 24),
          _buildCustomerAnalytics(language),
          SizedBox(height: 24),
          _buildMeasurementTable(),
          SizedBox(height: 24),
          _buildOrderHistory(),
          SizedBox(height: 24),
          _buildFinancialSummary(language),
          SizedBox(height: 32),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    SquareAvatar(
                      size: 120,
                      base64Image: _customer!.photoPath,
                      fallbackText: _customer!.initials,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.accentColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.backgroundColor, width: 2),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: _updatePhoto,
                      ),
                    ),
                  ],
                ),  SizedBox(height: 16),
        Text(_customer!.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
        SizedBox(height: 16),
        
        // Contact Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_outlined, size: 16, color: theme.textSecondary),
            SizedBox(width: 4),
            Text(_customer!.phone, style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily)),
            SizedBox(width: 16),
            _buildActionChip('Call', Icons.call, () => _launchUrl('tel', _customer!.phone)),
            SizedBox(width: 8),
            _buildActionChip('SMS', Icons.sms, () => _launchUrl('sms', _customer!.phone)),
          ],
        ),
        
        if (_customer!.email != null && _customer!.email!.isNotEmpty) ...[
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 16, color: theme.textSecondary),
              SizedBox(width: 4),
              Text(_customer!.email!, style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily)),
              SizedBox(width: 16),
              _buildActionChip('Email', Icons.mail, () => _launchUrl('mailto', _customer!.email!)),
            ],
          ),
        ],
        
        if (_customer!.location != null && _customer!.location!.isNotEmpty) ...[
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: theme.textSecondary),
              SizedBox(width: 4),
              Text(_customer!.location!, style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily)),
            ],
          ),
        ],
        
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_customer!.gender.toLowerCase() == 'male' ? Icons.male : Icons.female, size: 16, color: theme.textSecondary),
            SizedBox(width: 4),
            Text(_customer!.gender.capitalize(), style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
            Text('  |  ', style: TextStyle(color: Colors.grey)),
            Text('${_customer!.totalOrders} Orders', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
            Text('  |  ', style: TextStyle(color: Colors.grey)),
            Text('3 Years'.t(context), style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)), // Mocked years
          ],
        ),
        SizedBox(height: 16),
        LoyaltyBadge(status: _customer!.loyaltyStatus),
      ],
    );
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: theme.borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: theme.accentColor),
            SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, color: theme.textPrimary, fontFamily: theme.fontFamily)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerAnalytics(LanguageProvider language) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.cornerRadius,
        border: Border.all(color: theme.borderColor, width: 0.5),
        boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
      ),
      child: Column(
        children: [
          _buildStatRow(Icons.account_balance_wallet_outlined, 'Total Spent', language.formatCurrency(_customer!.totalSpent, showSymbol: true)),
          SizedBox(height: 12),
          _buildStatRow(Icons.bar_chart_outlined, 'Average Order', language.formatCurrency(_customer!.averageOrderValue, showSymbol: true)),
          SizedBox(height: 12),
          _buildStatRow(Icons.checkroom_outlined, 'Top Garments', _topGarments),
          SizedBox(height: 12),
          _buildStatRow(Icons.texture_outlined, 'Top Fabrics', _topFabrics),
          SizedBox(height: 12),
          _buildStatRow(Icons.design_services_outlined, 'Top Designs', _topDesigns),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.textSecondary),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: theme.textSecondary, fontFamily: theme.fontFamily)),
        SizedBox(width: 16),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
        ),
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
            Text('Default Measurements'.t(context), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: _customer)),
                );
                if (result == true) _loadCustomerData();
              },
              child: Text('Edit'.t(context), style: TextStyle(color: theme.accentColor, fontFamily: theme.fontFamily)),
            ),
          ],
        ),
        if (_customer!.measurements == null || _customer!.measurements!.isEmpty)
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: theme.borderColor),
              borderRadius: theme.cornerRadius,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.straighten_outlined, size: 48, color: theme.textSecondary.withOpacity(0.5)),
                  SizedBox(height: 8),
                  Text('No Measurements'.t(context), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  Text('Default measurements have not been recorded.'.t(context), style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
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
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Text('Order History (${_customer!.totalOrders})'.t(context), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
            if (_customer!.totalOrders > 5)
              TextButton(
                onPressed: () {},
                child: Text('View All'.t(context), style: TextStyle(color: theme.accentColor, fontFamily: theme.fontFamily)),
              ),
          ],
        ),
        if (_recentOrders.isEmpty)
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No orders yet.'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
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
    double totalBilled = 0;
    double totalPaid = 0;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final allOrders = orderProvider.orders.where((o) => o.customerId == _customer!.id);
    for (var o in allOrders) {
      totalBilled += o.totalAmount;
      totalPaid += o.paidAmount;
    }
    double outstanding = totalBilled - totalPaid;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.cornerRadius,
        border: Border.all(color: theme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial Summary'.t(context), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
          SizedBox(height: 16),
          _buildStatRow(Icons.receipt_outlined, 'Total Billed:', language.formatCurrency(totalBilled, showSymbol: true)),
          SizedBox(height: 8),
          _buildStatRow(Icons.payments_outlined, 'Total Paid:', language.formatCurrency(totalPaid, showSymbol: true)),
          SizedBox(height: 8),
          _buildStatRow(Icons.money_off_outlined, 'Outstanding:', language.formatCurrency(outstanding, showSymbol: true)),
          SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => navigateTo('/customers/financials', arguments: _customer!.id),
              child: Text('View Payment Details'.t(context), style: TextStyle(color: theme.accentColor, fontFamily: theme.fontFamily)),
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
          Text('Created: ${_customer!.createdAt.toString().split('.t(context) ')[0]}', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          Text('Last Order: ${_customer!.lastOrderDate?.toString().split('.t(context) ')[0] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (ctx) => AuthDeleteDialog(
        itemName: _customer!.name,
        securityService: SecurityService(),
        onDelete: () async {
          final provider = Provider.of<CustomerProvider>(context, listen: false);
          await provider.deleteCustomer(_customer!.id!);
          if (mounted) Navigator.pop(context, true);
        },
      ),
    );
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}
