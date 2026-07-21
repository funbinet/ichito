import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/adaptive_components.dart';

import '../widgets/wizard/step_1_client.dart';
import '../widgets/wizard/step_2_garment.dart';
import '../widgets/wizard/step_3_measurements.dart';
import '../widgets/wizard/step_4_materials.dart';
import '../widgets/wizard/step_5_pricing.dart';
import '../widgets/wizard/step_6_review.dart';

class OrderWizardScreen extends StatefulWidget {
  const OrderWizardScreen({Key? key}) : super(key: key);

  @override
  State<OrderWizardScreen> createState() => _OrderWizardScreenState();
}

class _OrderWizardScreenState extends State<OrderWizardScreen> with ThemeAwareMixin, NavigationMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  // Wizard State
  String? _selectedCustomerId;
  String? _selectedGarmentId;
  Map<String, double> _measurements = {};
  String? _selectedFabricId;
  String? _selectedDesignId;
  double _fabricCost = 0.0;
  double _laborCost = 0.0;
  double _depositAmount = 0.0;
  DateTime? _dueDate;
  DateTime? _trialDate;
  String? _specialInstructions;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _confirmDiscard();
    }
  }

  void _confirmDiscard() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Discard Order?'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
        content: Text('Are you sure you want to discard this order? All progress will be lost.'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'.t(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Discard'.t(context), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.textPrimary),
          onPressed: _confirmDiscard,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Order'.t(context),
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: theme.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: theme.fontFamily,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _totalSteps,
                    backgroundColor: theme.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
                    minHeight: 4,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${((_currentStep + 1) / _totalSteps * 100).toInt()}%',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: theme.fontSize * 0.75,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping
        onPageChanged: (index) {
          setState(() {
            _currentStep = index;
          });
        },
        children: [
          Step1Client(
            selectedCustomerId: _selectedCustomerId,
            onCustomerSelected: (id) {
              setState(() => _selectedCustomerId = id);
            },
            onNext: _nextStep,
          ),
          Step2Garment(
            customerId: _selectedCustomerId,
            selectedGarmentId: _selectedGarmentId,
            onGarmentSelected: (id) {
              setState(() => _selectedGarmentId = id);
            },
            onNext: _nextStep,
            onBack: _previousStep,
          ),
          Step3Measurements(
            customerId: _selectedCustomerId ?? '',
            garmentId: _selectedGarmentId ?? '',
            initialMeasurements: _measurements,
            onMeasurementsSaved: (measurements) {
              setState(() => _measurements = measurements);
            },
            onNext: _nextStep,
            onBack: _previousStep,
          ),
          Step4Materials(
            garmentId: _selectedGarmentId ?? '',
            selectedFabricId: _selectedFabricId,
            selectedDesignId: _selectedDesignId,
            onMaterialsSelected: (fabricId, designId) {
              setState(() {
                _selectedFabricId = fabricId;
                _selectedDesignId = designId;
              });
            },
            onNext: _nextStep,
            onBack: _previousStep,
          ),
          Step5Pricing(
            garmentId: _selectedGarmentId ?? '',
            fabricId: _selectedFabricId,
            initialFabricCost: _fabricCost,
            initialLaborCost: _laborCost,
            initialTotalAmount: 0.0, // calculated inside
            initialDeposit: _depositAmount,
            initialDueDate: _dueDate,
            initialTrialDate: _trialDate,
            initialInstructions: _specialInstructions ?? '',
            onPricingSaved: (fabric, labor, total, deposit, due, trial, instructions) {
              setState(() {
                _fabricCost = fabric;
                _laborCost = labor;
                _depositAmount = deposit;
                _dueDate = due;
                _trialDate = trial;
                _specialInstructions = instructions;
              });
            },
            onNext: _nextStep,
            onBack: _previousStep,
          ),
          Step6Review(
            customerId: _selectedCustomerId ?? '',
            garmentId: _selectedGarmentId ?? '',
            measurements: _measurements,
            fabricId: _selectedFabricId,
            designId: _selectedDesignId,
            fabricCost: _fabricCost,
            laborCost: _laborCost,
            totalAmount: _fabricCost + _laborCost,
            deposit: _depositAmount,
            dueDate: _dueDate ?? DateTime.now(),
            trialDate: _trialDate,
            instructions: _specialInstructions ?? '',
            onBack: _previousStep,
          ),
        ],
      ),
    );
  }
}
