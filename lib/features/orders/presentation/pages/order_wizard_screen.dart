import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';

class OrderWizardScreen extends StatefulWidget {
  const OrderWizardScreen({super.key});

  @override
  State<OrderWizardScreen> createState() => _OrderWizardScreenState();
}

class _OrderWizardScreenState extends State<OrderWizardScreen> with ThemeAwareMixin, NavigationMixin {
  final OrderRepository _repository = OrderRepository();
  int _currentStep = 0;

  // Wizard State
  String? _selectedCustomerId;
  String? _selectedGarmentId;
  String? _selectedFabricId;
  DateTime? _dueDate;
  DateTime? _trialDate;
  double _totalAmount = 0.0;
  double _depositAmount = 0.0;
  final Map<String, double> _measurements = {};
  String _notes = '';

  @override
  bool hasUnsavedChanges() {
    return _selectedCustomerId != null || _selectedGarmentId != null;
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _submitOrder();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitOrder() async {
    // Basic validation
    if (_selectedCustomerId == null || _selectedGarmentId == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    final order = Order(
      orderNumber: 'ICHITO-${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
      customerId: _selectedCustomerId!,
      garmentId: _selectedGarmentId!,
      fabricId: _selectedFabricId,
      orderDate: DateTime.now(),
      dueDate: _dueDate!,
      trialDate: _trialDate,
      status: 'pending',
      totalAmount: _totalAmount,
      paidAmount: _depositAmount,
      measurements: _measurements,
      notes: _notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final orderId = await _repository.createOrder(order);
    
    if (_depositAmount > 0) {
      await _repository.addPayment(Payment(
        orderId: orderId,
        amount: _depositAmount,
        date: DateTime.now(),
        method: 'cash',
        createdAt: DateTime.now(),
      ));
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang.t('new_order'), style: headingStyle),
          backgroundColor: theme.backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.textPrimary),
        ),
        body: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepCancel: _prevStep,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: AdaptiveButton(
                      text: _currentStep == 5 ? 'Confirm Order' : 'Next',
                      onPressed: details.onStepContinue!,
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: AdaptiveButton(
                        text: 'Back',
                        isPrimary: false,
                        onPressed: details.onStepCancel!,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Customer'),
              content: _buildCustomerSelection(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Garment'),
              content: _buildGarmentSelection(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Measurements'),
              content: _buildMeasurementsInput(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Dates'),
              content: _buildDateSelection(),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Payment'),
              content: _buildPaymentInput(),
              isActive: _currentStep >= 4,
              state: _currentStep > 4 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Review'),
              content: _buildReview(),
              isActive: _currentStep >= 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSelection() {
    return AdaptiveCard(
      child: Column(
        children: [
          Text('Select Customer', style: bodyStyle),
          // TODO: Implement searchable dropdown or list
          TextButton(
            onPressed: () {
              // Dummy logic for now
              setState(() => _selectedCustomerId = 'dummy_id');
            },
            child: const Text('Pick Customer (Mock)'),
          ),
          if (_selectedCustomerId != null)
            const Text('Customer Selected!', style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildGarmentSelection() {
    return AdaptiveCard(
      child: Column(
        children: [
          Text('Select Garment & Fabric', style: bodyStyle),
          TextButton(
            onPressed: () {
              setState(() => _selectedGarmentId = 'dummy_garment');
            },
            child: const Text('Pick Garment (Mock)'),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsInput() {
    return AdaptiveCard(
      child: Column(
        children: [
          Text('Input Measurements', style: bodyStyle),
          const Text('Fields dynamic based on Garment selection.'),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return AdaptiveCard(
      child: Column(
        children: [
          Text('Select Dates', style: bodyStyle),
          ListTile(
            title: const Text('Due Date'),
            subtitle: Text(_dueDate?.toString() ?? 'Not Set'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _dueDate = date);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInput() {
    return AdaptiveCard(
      child: Column(
        children: [
          Text('Pricing & Deposit', style: bodyStyle),
          // Simple TextFields for amounts
        ],
      ),
    );
  }

  Widget _buildReview() {
    return AdaptiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Order Details', style: headingStyle),
          const Divider(),
          Text('Customer ID: $_selectedCustomerId'),
          Text('Garment ID: $_selectedGarmentId'),
          Text('Due Date: $_dueDate'),
          Text('Total: $_totalAmount'),
        ],
      ),
    );
  }
}
