import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../data/models/customer.dart';
import '../../data/repositories/customer_repository.dart';
import 'customer_form_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> with ThemeAwareMixin {
  final CustomerRepository _repository = CustomerRepository();
  Customer? _customer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    setState(() => _isLoading = true);
    final cust = await _repository.getCustomerById(widget.customerId);
    setState(() {
      _customer = cust;
      _isLoading = false;
    });
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
        appBar: AppBar(backgroundColor: theme.backgroundColor, elevation: 0),
        body: const Center(child: Text('Customer not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_customer!.name, style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: _customer)),
              );
              if (result == true) _loadCustomer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildContactInfo(),
          const SizedBox(height: 24),
          _buildMeasurementsCard(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.accentLight,
            child: Text(_customer!.initials, style: headingStyle.copyWith(color: theme.accentColor, fontSize: 32)),
          ),
          const SizedBox(height: 16),
          Text(_customer!.name, style: headingStyle),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _customer!.loyaltyStatus,
              style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Info', style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              leading: Icon(Icons.phone_outlined, color: theme.accentColor),
              title: Text(_customer!.phone, style: bodyStyle),
              dense: true,
            ),
            if (_customer!.email != null && _customer!.email!.isNotEmpty)
              ListTile(
                leading: Icon(Icons.email_outlined, color: theme.accentColor),
                title: Text(_customer!.email!, style: bodyStyle),
                dense: true,
              ),
            if (_customer!.location != null && _customer!.location!.isNotEmpty)
              ListTile(
                leading: Icon(Icons.location_on_outlined, color: theme.accentColor),
                title: Text(_customer!.location!, style: bodyStyle),
                dense: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsCard() {
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
                Text('Measurements', style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    // Navigate to Measurements Editor
                  },
                  child: Text('Edit', style: TextStyle(color: theme.accentColor)),
                ),
              ],
            ),
            const Divider(),
            if (_customer!.measurements == null || _customer!.measurements!.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No measurements recorded yet.', style: subtitleStyle),
              )
            else
              ..._customer!.measurements!.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: bodyStyle),
                    Text('${e.value} ${lang.measurementUnit}', style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer?'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteCustomer(_customer!.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }
}
