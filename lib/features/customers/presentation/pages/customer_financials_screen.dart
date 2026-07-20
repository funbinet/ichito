import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../shared/providers/customer_provider.dart';
import '../../../../shared/providers/order_provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../orders/data/models/order.dart';

class CustomerFinancialsScreen extends StatefulWidget {
  final String customerId;

  const CustomerFinancialsScreen({super.key, required this.customerId});

  @override
  State<CustomerFinancialsScreen> createState() => _CustomerFinancialsScreenState();
}

class _CustomerFinancialsScreenState extends State<CustomerFinancialsScreen> with ThemeAwareMixin, NavigationMixin {
  List<Payment> _filteredPayments = [];
  List<Payment> _allPayments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    // Get all orders for this customer
    final customerOrders = orderProvider.orders.where((o) => o.customerId == widget.customerId).map((o) => o.id).toList();
    
    // Get all payments that belong to these orders
    _allPayments = orderProvider.payments.where((p) => customerOrders.contains(p.orderId)).toList();
    
    _applyFilters();
    
    setState(() {
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredPayments = _allPayments.where((p) {
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          matchesSearch = (p.id?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                          (p.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        }
        
        bool matchesDate = true;
        if (_selectedDate != null) {
          final paymentDate = p.date;
          matchesDate = paymentDate.year == _selectedDate!.year &&
                        paymentDate.month == _selectedDate!.month &&
                        paymentDate.day == _selectedDate!.day;
        }
        
        return matchesSearch && matchesDate;
      }).toList();
      
      // Sort newest first
      _filteredPayments.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.accentColor,
              onPrimary: theme.onAccent,
              surface: theme.cardColor,
              onSurface: theme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _applyFilters();
    }
  }

  void _showTransactionDetails(Payment payment, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
          title: Text('Transaction Details'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Transaction ID', payment.id ?? 'N/A'),
              SizedBox(height: 8),
              _buildDetailRow('Amount', lang.formatCurrency(payment.amount, showSymbol: true)),
              SizedBox(height: 8),
              _buildDetailRow('Date', DateFormat('dd MMM yyyy, HH:mm').format(payment.date)),
              SizedBox(height: 8),
              _buildDetailRow('Method', payment.method.toUpperCase()),
              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                SizedBox(height: 8),
                _buildDetailRow('Notes', payment.notes!),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                navigateTo('/orders/detail', arguments: payment.orderId);
              },
              child: Text('View Order'.t(context), style: TextStyle(color: theme.accentColor, fontFamily: theme.fontFamily)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily)),
        Expanded(child: Text(value, style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final customer = Provider.of<CustomerProvider>(context, listen: false).getCustomerById(widget.customerId);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(customer != null ? '${customer.name} - Financials' : 'Financials', style: headingStyle),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: theme.accentColor))
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search transactions...'.t(context),
                          hintStyle: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily),
                          prefixIcon: Icon(Icons.search, color: theme.textSecondary),
                          filled: true,
                          fillColor: theme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: theme.cornerRadius,
                            borderSide: BorderSide(color: theme.borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: theme.cornerRadius,
                            borderSide: BorderSide(color: theme.borderColor),
                          ),
                        ),
                        style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
                        onChanged: (val) {
                          _searchQuery = val;
                          _applyFilters();
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _selectedDate == null ? Icons.calendar_today : Icons.event_available,
                        color: _selectedDate == null ? theme.textSecondary : theme.accentColor,
                      ),
                      onPressed: () => _selectDate(context),
                      tooltip: 'Filter by Date'.t(context),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                          _applyFilters();
                        },
                        tooltip: 'Clear Date Filter'.t(context),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _filteredPayments.isEmpty
                    ? Center(child: Text('No transactions found.'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)))
                    : ListView.builder(
                        itemCount: _filteredPayments.length,
                        itemBuilder: (context, index) {
                          final payment = _filteredPayments[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: theme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: theme.cornerRadius,
                              side: BorderSide(color: theme.borderColor, width: 0.5),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.accentLight.withOpacity(0.3),
                                child: Icon(Icons.payments_outlined, color: theme.accentColor),
                              ),
                              title: Text(lang.formatCurrency(payment.amount, showSymbol: true), style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily)),
                              subtitle: Text(DateFormat('dd MMM yyyy').format(payment.date), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                              trailing: Text(payment.method.toUpperCase(), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily, fontSize: 12)),
                              onTap: () => _showTransactionDetails(payment, lang),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
    );
  }
}
