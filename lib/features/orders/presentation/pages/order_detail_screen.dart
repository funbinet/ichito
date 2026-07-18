import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import '../../../../shared/widgets/auth_delete_dialog.dart';
import '../../../security/services/security_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with ThemeAwareMixin, SingleTickerProviderStateMixin {
  final OrderRepository _repository = OrderRepository();
  Order? _order;
  List<Payment> _payments = [];
  bool _isLoading = true;
  late TabController _tabController;

  final List<String> _statusProgression = ['pending', 'in_progress', 'trial', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final order = await _repository.getOrderById(widget.orderId);
    final payments = await _repository.getPaymentsForOrder(widget.orderId);
    if (mounted) {
      setState(() {
        _order = order;
        _payments = payments;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    await _repository.updateOrderStatus(widget.orderId, newStatus);
    await _loadData();
  }

  void _showAddPaymentDialog() {
    final controller = TextEditingController(text: _order?.balance.toStringAsFixed(0) ?? '0');
    String method = 'cash';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Record Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount (KES)',
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: method,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: ['cash', 'mpesa', 'bank'].map((m) => DropdownMenuItem(value: m, child: Text(m.toUpperCase(), style: TextStyle(fontFamily: theme.fontFamily)))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => method = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  AdaptiveButton(
                    text: 'Save Payment',
                    onPressed: () async {
                      final amt = double.tryParse(controller.text) ?? 0;
                      if (amt > 0) {
                        await _repository.addPayment(Payment(
                          orderId: widget.orderId,
                          amount: amt,
                          date: DateTime.now(),
                          method: method,
                          createdAt: DateTime.now(),
                        ));
                        if (mounted) Navigator.pop(ctx);
                        _loadData();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _confirmDeleteOrder() {
    showDialog(
      context: context,
      builder: (ctx) => AuthDeleteDialog(
        itemName: _order!.orderNumber,
        securityService: SecurityService(),
        onDelete: () async {
          await _repository.deleteOrder(widget.orderId);
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildTimeline() {
    if (_order == null) return const SizedBox.shrink();
    
    // Simple horizontal timeline
    int currentIndex = _statusProgression.indexOf(_order!.status);
    if (currentIndex == -1) currentIndex = 4; // cancelled or something else
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: theme.cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_statusProgression.length, (index) {
          final status = _statusProgression[index];
          final isCompleted = index <= currentIndex;
          final isCurrent = index == currentIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isCurrent) _updateStatus(status);
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Container(height: 2, color: index == 0 ? Colors.transparent : (isCompleted ? theme.accentColor : theme.borderColor))),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCurrent ? theme.accentColor : (isCompleted ? theme.accentColor : theme.cardColor),
                          border: Border.all(color: isCompleted ? theme.accentColor : theme.borderColor, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted && !isCurrent
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      Expanded(child: Container(height: 2, color: index == _statusProgression.length - 1 ? Colors.transparent : (isCompleted && !isCurrent ? theme.accentColor : theme.borderColor))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status == 'in_progress' ? 'In Progress' : status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? theme.accentColor : (isCompleted ? theme.textPrimary : theme.textSecondary),
                      fontFamily: theme.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailsTab() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Client & Garment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
        const SizedBox(height: 8),
        Card(
          color: theme.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.borderColor)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: theme.textSecondary),
                    const SizedBox(width: 8),
                    Text(_order!.customerName ?? 'Unknown', style: TextStyle(fontSize: 16, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.checkroom_outlined, size: 20, color: theme.textSecondary),
                    const SizedBox(width: 8),
                    Text(_order!.garmentName ?? 'Unknown', style: TextStyle(fontSize: 16, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Due Date:', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                    Text(dateFormat.format(_order!.dueDate), style: TextStyle(fontWeight: FontWeight.bold, color: _order!.isOverdue ? Colors.red : theme.textPrimary, fontFamily: theme.fontFamily)),
                  ],
                ),
                if (_order!.trialDate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Trial Date:', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                      Text(dateFormat.format(_order!.trialDate!), style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        Text('Measurements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
        const SizedBox(height: 8),
        Card(
          color: theme.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.borderColor)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              children: _order!.measurements.entries.map((e) => SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key, style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
                    Text(e.value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  ],
                ),
              )).toList(),
            ),
          ),
        ),
        
        if (_order!.specialInstructions != null && _order!.specialInstructions!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Special Instructions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
          const SizedBox(height: 8),
          Card(
            color: theme.cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.borderColor)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_order!.specialInstructions!, style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildFinancialsTab() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Financial Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
        const SizedBox(height: 8),
        Card(
          color: theme.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.borderColor)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                    Text('KES ${_order!.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Paid', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                    Text('KES ${_order!.paidAmount.toStringAsFixed(0)}', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Balance Due', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                    Text(
                      'KES ${_order!.balance.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _order!.isFullyPaid ? Colors.green : Colors.red,
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Payment History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
            if (!_order!.isFullyPaid)
              TextButton.icon(
                onPressed: _showAddPaymentDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Record'),
                style: TextButton.styleFrom(foregroundColor: theme.accentColor),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_payments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text('No payments recorded yet.', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
            ),
          )
        else
          ..._payments.map((p) => Card(
            color: theme.cardColor,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: theme.borderColor)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: theme.accentColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(p.method == 'cash' ? Icons.money : Icons.account_balance_wallet, color: theme.accentColor, size: 20),
              ),
              title: Text('KES ${p.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
              subtitle: Text(dateFormat.format(p.date), style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
              trailing: Text(p.method.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textSecondary, fontFamily: theme.fontFamily)),
            ),
          )).toList(),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: theme.backgroundColor, body: Center(child: CircularProgressIndicator(color: theme.accentColor)));
    }
    if (_order == null) {
      return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(backgroundColor: theme.backgroundColor, elevation: 0),
        body: Center(child: Text('Order not found', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily))),
      );
    }

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(_order!.orderNumber, style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
        backgroundColor: theme.cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
            onPressed: _confirmDeleteOrder,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTimeline(),
          Container(
            color: theme.cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.accentColor,
              unselectedLabelColor: theme.textSecondary,
              indicatorColor: theme.accentColor,
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Financials'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildFinancialsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
