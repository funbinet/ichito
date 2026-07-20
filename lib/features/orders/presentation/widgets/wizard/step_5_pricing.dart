import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/adaptive_components.dart';
import '../../../../garments/data/models/garment.dart';
import '../../../../garments/data/models/materials.dart';
import '../../../../garments/data/repositories/garment_repository.dart';
import '../../../../garments/data/repositories/materials_repository.dart';

class Step5Pricing extends StatefulWidget {
  final String garmentId;
  final String? fabricId;
  final double initialFabricCost;
  final double initialLaborCost;
  final double initialTotalAmount;
  final double initialDeposit;
  final DateTime? initialDueDate;
  final DateTime? initialTrialDate;
  final String initialInstructions;
  final Function(double, double, double, double, DateTime, DateTime?, String) onPricingSaved;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step5Pricing({
    Key? key,
    required this.garmentId,
    this.fabricId,
    required this.initialFabricCost,
    required this.initialLaborCost,
    required this.initialTotalAmount,
    required this.initialDeposit,
    this.initialDueDate,
    this.initialTrialDate,
    required this.initialInstructions,
    required this.onPricingSaved,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<Step5Pricing> createState() => _Step5PricingState();
}

class _Step5PricingState extends State<Step5Pricing> with ThemeAwareMixin {
  late TextEditingController _fabricCostController;
  late TextEditingController _laborCostController;
  late TextEditingController _depositController;
  late TextEditingController _instructionsController;

  DateTime? _dueDate;
  DateTime? _trialDate;

  GarmentRepository _garmentRepo = GarmentRepository();
  FabricRepository _fabricRepo = FabricRepository();

  Garment? _garment;
  Fabric? _fabric;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fabricCostController = TextEditingController(text: widget.initialFabricCost > 0 ? widget.initialFabricCost.toStringAsFixed(0) : '');
    _laborCostController = TextEditingController(text: widget.initialLaborCost > 0 ? widget.initialLaborCost.toStringAsFixed(0) : '');
    _depositController = TextEditingController(text: widget.initialDeposit > 0 ? widget.initialDeposit.toStringAsFixed(0) : '');
    _instructionsController = TextEditingController(text: widget.initialInstructions);

    _dueDate = widget.initialDueDate;
    _trialDate = widget.initialTrialDate;

    _loadDefaults();

    _fabricCostController.addListener(_updateTotal);
    _laborCostController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _fabricCostController.dispose();
    _laborCostController.dispose();
    _depositController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaults() async {
    setState(() => _isLoading = true);
    try {
      _garment = await _garmentRepo.getById(widget.garmentId);
      if (widget.fabricId != null) {
        _fabric = await _fabricRepo.getById(widget.fabricId!);
      }

      if (_garment != null && widget.initialLaborCost == 0) {
        _laborCostController.text = (_garment!.defaultPrice ?? 0).toStringAsFixed(0);
      }
      
      if (_fabric != null && widget.initialFabricCost == 0) {
        // Assuming unit price per yard, and garment takes 2 yards on average
        _fabricCostController.text = (_fabric!.pricePerUnit * 2).toStringAsFixed(0);
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'.t(context))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateTotal() {
    setState(() {});
  }

  double get _totalAmount {
    final fabricCost = double.tryParse(_fabricCostController.text) ?? 0;
    final laborCost = double.tryParse(_laborCostController.text) ?? 0;
    return fabricCost + laborCost;
  }

  void _saveAndNext() {
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a Due Date'.t(context))));
      return;
    }

    final fabricCost = double.tryParse(_fabricCostController.text) ?? 0;
    final laborCost = double.tryParse(_laborCostController.text) ?? 0;
    final deposit = double.tryParse(_depositController.text) ?? 0;

    widget.onPricingSaved(
      fabricCost,
      laborCost,
      _totalAmount,
      deposit,
      _dueDate!,
      _trialDate,
      _instructionsController.text.trim(),
    );
    widget.onNext();
  }

  Future<void> _pickDate(bool isDue) async {
    final initial = isDue ? (_dueDate ?? DateTime.now().add(const Duration(days: 14))) : (_trialDate ?? DateTime.now().add(const Duration(days: 7)));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.accentColor,
              onPrimary: Colors.white,
              surface: theme.cardColor,
              onSurface: theme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isDue) {
          _dueDate = date;
        } else {
          _trialDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator(color: theme.accentColor)),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy');

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Step 5: Pricing & Scheduling'.t(context),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily),
            ),
            SizedBox(height: 16),
            
            // Financials
            Card(
              color: theme.cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.borderColor)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _laborCostController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Labor/Stitching Cost (KES)',
                        prefixIcon: Icon(Icons.cut),
                        filled: true,
                        fillColor: theme.backgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _fabricCostController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Material/Fabric Cost (KES)',
                        prefixIcon: Icon(Icons.texture),
                        filled: true,
                        fillColor: theme.backgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Expected'.t(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                        Text('KES ${_totalAmount.toStringAsFixed(0)}'.t(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.accentColor, fontFamily: theme.fontFamily)),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _depositController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Deposit Received (KES)',
                        prefixIcon: Icon(Icons.money),
                        filled: true,
                        fillColor: theme.backgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Scheduling
            Card(
              color: theme.cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.borderColor)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: theme.accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.event_available, color: theme.accentColor),
                      ),
                      title: Text('Due Date'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                      subtitle: Text(_dueDate != null ? dateFormat.format(_dueDate!) : 'Not set', style: TextStyle(color: _dueDate == null ? Colors.red : theme.textSecondary, fontFamily: theme.fontFamily)),
                      trailing: TextButton(onPressed: () => _pickDate(true), child: Text('Change'.t(context))),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.accessibility_new, color: Colors.purple),
                      ),
                      title: Text('Trial/Fitting Date'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                      subtitle: Text(_trialDate != null ? dateFormat.format(_trialDate!) : 'Not set', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                      trailing: TextButton(onPressed: () => _pickDate(false), child: Text('Change'.t(context))),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Instructions
            TextField(
              controller: _instructionsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Special Instructions',
                hintText: 'Any extra details, pockets, collar type...'.t(context),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AdaptiveButton(
                    text: 'Back',
                    onPressed: widget.onBack,
                    isPrimary: false,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AdaptiveButton(
                    text: 'Review Order',
                    onPressed: _saveAndNext,
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
