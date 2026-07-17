import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../data/models/customer.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> with ThemeAwareMixin, NavigationMixin {
  final _formKey = GlobalKey<FormState>();
  final CustomerRepository _repository = CustomerRepository();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  String _selectedGender = 'unisex';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _locationController = TextEditingController(text: widget.customer?.location ?? '');
    if (widget.customer != null) {
      _selectedGender = widget.customer!.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  bool hasUnsavedChanges() {
    return _nameController.text != (widget.customer?.name ?? '') ||
           _phoneController.text != (widget.customer?.phone ?? '');
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      id: widget.customer?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      gender: _selectedGender,
      location: _locationController.text.trim(),
      measurements: widget.customer?.measurements, // Keep existing if editing
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.customer == null) {
      await _repository.createCustomer(customer);
    } else {
      await _repository.updateCustomer(customer);
    }

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.customer == null ? lang.t('add_customer') : lang.t('edit_customer'), style: headingStyle),
          backgroundColor: theme.backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.textPrimary),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              AdaptiveTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
              ),
              AdaptiveTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Phone is required' : null,
              ),
              AdaptiveTextField(
                controller: _emailController,
                label: 'Email Address (Optional)',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              AdaptiveTextField(
                controller: _locationController,
                label: 'Location/Address (Optional)',
                prefixIcon: Icons.location_on_outlined,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(borderRadius: theme.cornerRadius),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'men', child: Text('Male')),
                    DropdownMenuItem(value: 'women', child: Text('Female')),
                    DropdownMenuItem(value: 'unisex', child: Text('Unisex')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGender = val);
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AdaptiveButton(
                  text: lang.t('save'),
                  icon: Icons.save_outlined,
                  onPressed: _saveCustomer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
