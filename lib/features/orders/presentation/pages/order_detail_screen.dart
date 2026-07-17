import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with ThemeAwareMixin {
  final OrderRepository _repository = OrderRepository();
  Order? _order;
  List<Payment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final order = await _repository.getOrderById(widget.orderId);
    final payments = await _repository.getPaymentsForOrder(widget.orderId);
    setState(() {
      _order = order;
      _payments = payments;
      _isLoading = false;
    });
  }

  void _showAddPaymentDialog() {
    final controller = TextEditingController(text: _order?.balance.toString() ?? '0');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Payment', style: headingStyle),
        backgroundColor: theme.cardColor,
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final amt = double.tryParse(controller.text) ?? 0;
              if (amt > 0) {
                await _repository.addPayment(Payment(
                  orderId: widget.orderId,
                  amount: amt,
                  date: DateTime.now(),
                  method: 'cash',
                  createdAt: DateTime.now(),
                ));
                if (mounted) Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    await _repository.updateOrderStatus(widget.orderId, newStatus);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: theme.backgroundColor, body: const Center(child: CircularProgressIndicator()));
    }
    if (_order == null) {
      return Scaffold(backgroundColor: theme.backgroundColor, body: const Center(child: Text('Order not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_order!.orderNumber, style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusTracker(),
          const SizedBox(height: 24),
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildPaymentsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusTracker() {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Current Status: ${_order!.status.toUpperCase()}', style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['pending', 'in_progress', 'trial', 'completed'].map((s) {
                final isCurrent = _order!.status == s;
                return ChoiceChip(
                  label: Text(s.toUpperCase()),
                  selected: isCurrent,
                  onSelected: (selected) {
                    if (selected && !isCurrent) _updateStatus(s);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${_order!.customerName ?? "Unknown"}', style: bodyStyle),
            const SizedBox(height: 8),
            Text('Garment: ${_order!.garmentName ?? "Unknown"}', style: bodyStyle),
            const SizedBox(height: 8),
            Text('Due Date: ${lang.formatDate(_order!.dueDate)}', style: bodyStyle),
            const SizedBox(height: 8),
            Text('Total Amount: ${lang.formatCurrency(_order!.totalAmount)}', style: bodyStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsCard() {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payments', style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                if (!_order!.isFullyPaid)
                  TextButton(
                    onPressed: _showAddPaymentDialog,
                    child: const Text('Add Payment'),
                  ),
              ],
            ),
            const Divider(),
            if (_payments.isEmpty)
              const Text('No payments recorded.')
            else
              ..._payments.map((p) => ListTile(
                title: Text(lang.formatCurrency(p.amount)),
                subtitle: Text('${lang.formatDate(p.date)} • ${p.method.toUpperCase()}'),
              )),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Balance Due: ${lang.formatCurrency(_order!.balance)}',
                style: bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _order!.isFullyPaid ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
