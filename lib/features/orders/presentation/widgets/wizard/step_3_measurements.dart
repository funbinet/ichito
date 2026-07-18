import 'package:flutter/material.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/adaptive_components.dart';
import '../../../../customers/data/models/customer.dart';
import '../../../../customers/data/repositories/customer_repository.dart';
import '../../../../garments/data/models/garment.dart';
import '../../../../garments/data/repositories/garment_repository.dart';

class Step3Measurements extends StatefulWidget {
  final String customerId;
  final String garmentId;
  final Map<String, double> initialMeasurements;
  final Function(Map<String, double>) onMeasurementsSaved;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3Measurements({
    Key? key,
    required this.customerId,
    required this.garmentId,
    required this.initialMeasurements,
    required this.onMeasurementsSaved,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<Step3Measurements> createState() => _Step3MeasurementsState();
}

class _Step3MeasurementsState extends State<Step3Measurements> with ThemeAwareMixin {
  late CustomerRepository _customerRepo;
  late GarmentRepository _garmentRepo;
  Customer? _customer;
  Garment? _garment;
  bool _isLoading = true;
  
  final Map<String, TextEditingController> _controllers = {};
  bool _saveAsDefault = true;

  @override
  void initState() {
    super.initState();
    _customerRepo = CustomerRepository();
    _garmentRepo = GarmentRepository();
    _loadData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _customer = await _customerRepo.getById(widget.customerId);
      _garment = await _garmentRepo.getById(widget.garmentId);

      if (_garment != null) {
        for (final field in _garment!.measurementFields) {
          double? val;
          if (widget.initialMeasurements.containsKey(field)) {
            val = widget.initialMeasurements[field];
          } else if (_customer?.measurements != null && _customer!.measurements!.containsKey(field)) {
            val = _customer!.measurements![field];
          }
          
          _controllers[field] = TextEditingController(
            text: val != null ? val.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '') : '',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAndNext() async {
    final Map<String, double> measurements = {};
    for (final entry in _controllers.entries) {
      final text = entry.value.text.trim();
      if (text.isNotEmpty) {
        final val = double.tryParse(text);
        if (val != null) {
          measurements[entry.key] = val;
        }
      }
    }
    
    widget.onMeasurementsSaved(measurements);

    if (_saveAsDefault && _customer != null) {
      final Map<String, double> updatedMeasurements = Map.from(_customer!.measurements ?? {});
      updatedMeasurements.addAll(measurements);
      
      final updatedCustomer = _customer!.copyWith(measurements: updatedMeasurements);
      await _customerRepo.updateCustomer(updatedCustomer);
    }
    
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator(color: theme.accentColor)),
      );
    }

    if (_garment == null) {
      return const Center(child: Text('Garment not found'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Step 3: Measurements for ${_garment!.name}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              fontFamily: theme.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter measurements in inches. Existing profile data has been loaded automatically.',
            style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: _garment!.measurementFields.length,
              itemBuilder: (context, index) {
                final field = _garment!.measurementFields[index];
                final bool isProfileValue = _customer?.measurements != null && _customer!.measurements!.containsKey(field);
                return TextField(
                  controller: _controllers[field],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontWeight: isProfileValue ? FontWeight.bold : FontWeight.normal,
                    color: isProfileValue ? theme.accentColor : theme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: field,
                    suffixText: 'in',
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: Text(
              'Save these measurements to ${_customer?.name ?? "customer"}\'s profile as defaults.',
              style: TextStyle(fontSize: 14, color: theme.textPrimary, fontFamily: theme.fontFamily),
            ),
            value: _saveAsDefault,
            onChanged: (val) {
              if (val != null) {
                setState(() => _saveAsDefault = val);
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: theme.accentColor,
            checkColor: Colors.white,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  text: 'Back',
                  onPressed: widget.onBack,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AdaptiveButton(
                  text: 'Next Step',
                  onPressed: _saveAndNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
