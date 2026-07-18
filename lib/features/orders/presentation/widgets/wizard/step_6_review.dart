import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/adaptive_components.dart';
import '../../../../customers/data/models/customer.dart';
import '../../../../garments/data/models/garment.dart';
import '../../../../customers/data/repositories/customer_repository.dart';
import '../../../../garments/data/repositories/garment_repository.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../pages/order_detail_screen.dart';

class Step6Review extends StatefulWidget {
  final String customerId;
  final String garmentId;
  final String? fabricId;
  final String? designId;
  final Map<String, double> measurements;
  final double fabricCost;
  final double laborCost;
  final double totalAmount;
  final double deposit;
  final DateTime dueDate;
  final DateTime? trialDate;
  final String instructions;
  final VoidCallback onBack;

  const Step6Review({
    Key? key,
    required this.customerId,
    required this.garmentId,
    this.fabricId,
    this.designId,
    required this.measurements,
    required this.fabricCost,
    required this.laborCost,
    required this.totalAmount,
    required this.deposit,
    required this.dueDate,
    this.trialDate,
    required this.instructions,
    required this.onBack,
  }) : super(key: key);

  @override
  State<Step6Review> createState() => _Step6ReviewState();
}

class _Step6ReviewState extends State<Step6Review> with ThemeAwareMixin {
  Customer? _customer;
  Garment? _garment;
  bool _isLoading = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _customer = await CustomerRepository().getById(widget.customerId);
      _garment = await GarmentRepository().getById(widget.garmentId);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createOrder() async {
    setState(() => _isCreating = true);
    try {
      final repo = OrderRepository();
      final customerRepo = CustomerRepository();
      final orderNumber = await repo.generateOrderNumber();
      
      final updatedCustomer = _customer!.copyWith(measurements: widget.measurements);
      await customerRepo.updateCustomer(updatedCustomer);
      
      final order = Order(
        orderNumber: orderNumber,
        customerId: widget.customerId,
        customerName: _customer?.name,
        garmentId: widget.garmentId,
        garmentName: _garment?.name,
        fabricId: widget.fabricId,
        designId: widget.designId,
        measurements: widget.measurements,
        status: 'pending',
        orderDate: DateTime.now(),
        totalAmount: widget.totalAmount,
        dueDate: widget.dueDate,
        trialDate: widget.trialDate,
        specialInstructions: widget.instructions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final orderId = await repo.createOrder(order);
      String createdOrderId = orderId;

      if (widget.deposit > 0) {
        await repo.addPayment(Payment(
          orderId: orderId,
          amount: widget.deposit,
          date: DateTime.now(),
          method: 'cash',
          createdAt: DateTime.now(),
        ));
      }

      if (mounted) {
        _showSuccessDialog(orderId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating order: $e')));
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 16),
            Text('Order Created!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
            const SizedBox(height: 8),
            Text('The order has been successfully recorded in the system.', textAlign: TextAlign.center, style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context); // Exit wizard to Home
                    },
                    child: const Text('Go Home'),
                  ),
                ),
                Expanded(
                  child: AdaptiveButton(
                    text: 'View Order',
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(orderId: orderId),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator(color: theme.accentColor)),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Step 6: Review & Confirm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily),
            ),
            const SizedBox(height: 16),
            
            // Client & Garment
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
                        Icon(Icons.person, size: 20, color: theme.textSecondary),
                        const SizedBox(width: 8),
                        Text(_customer?.name ?? 'Unknown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.checkroom, size: 20, color: theme.textSecondary),
                        const SizedBox(width: 8),
                        Text(_garment?.name ?? 'Unknown', style: TextStyle(fontSize: 16, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financials
            Card(
              color: theme.cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.borderColor)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Financials', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textSecondary, fontFamily: theme.fontFamily)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Labor Cost', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                        Text(currencyFormat.format(widget.laborCost), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Material Cost', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                        Text(currencyFormat.format(widget.fabricCost), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                        Text(currencyFormat.format(widget.totalAmount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.accentColor, fontFamily: theme.fontFamily)),
                      ],
                    ),
                    if (widget.deposit > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Deposit Received', style: TextStyle(color: Colors.green, fontFamily: theme.fontFamily)),
                          Text('-${currencyFormat.format(widget.deposit)}', style: TextStyle(color: Colors.green, fontFamily: theme.fontFamily)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Balance Due', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                          Text(currencyFormat.format(widget.totalAmount - widget.deposit), style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Schedule
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
                        Text('Due Date', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                        Text(dateFormat.format(widget.dueDate), style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                      ],
                    ),
                    if (widget.trialDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Trial Date', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                          Text(dateFormat.format(widget.trialDate!), style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AdaptiveButton(
                    text: 'Back',
                    onPressed: _isCreating ? null : widget.onBack,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _isCreating
                      ? Center(child: CircularProgressIndicator(color: theme.accentColor))
                      : AdaptiveButton(
                          text: 'Create Order',
                          onPressed: () => _createOrder(),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
